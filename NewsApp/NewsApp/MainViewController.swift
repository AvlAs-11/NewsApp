//
//  ViewController.swift
//  NewsApp
//
//  Created by Pavel Avlasov on 10.08.2021.
//

import UIKit
import SafariServices

class MainViewController: UIViewController {

    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var refreshDateButton: UIButton!
    
    private var articles = [Article]()
    private var viewModels = [NewsModel]()
    var now: String?
    var endDate = Date()
    var lastSeenOnlineDate = Date()
    
    private func getActualNews() {
        let actualDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        var actualDateToString = "&from="
        actualDateToString += formatter.string(from: actualDate)
        actualDateToString += "&to="
        actualDateToString += formatter.string(from: actualDate)
        APICaller.shared.getActualNews(with: actualDateToString) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"), publishedAt: $0.publishedAt)
                })
                DispatchQueue.main.async {
                    self?.newsTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func refreshDate(_ sender: Any) {
        newsTableView.setContentOffset(.zero, animated:true)
        var text = "&from="
        let actualDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let actualDateToString = formatter.string(from: actualDate)
        text += actualDateToString
        text += "&to="
        text += actualDateToString
        now = formatter.string(from: actualDate)
        let calendar = Calendar.current
        endDate = Date()
        endDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        let defaults = UserDefaults.standard
        defaults.set(actualDateToString, forKey: "DateKey")
        APICaller.shared.getActualNews(with: text) { [weak self] result in
            if text == "endOfWeek" {
                print("EndOfWeek")
                return
            }
            switch result {
                case .success(let articles):
                    self?.articles = articles
                    self?.viewModels = articles.compactMap({
                        NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"), publishedAt: $0.publishedAt)
                    })
                    DispatchQueue.main.async {
                        self?.newsTableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    private func getPrevDay() -> String {
        
        var dateForCall : String
        dateForCall = "&from="
        let formatter = DateFormatter()
        let calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        var nowToDate = formatter.date(from: now!)
        nowToDate = calendar.date(byAdding: .day, value: -1, to: nowToDate!)
        now = formatter.string(from: nowToDate!)
        if nowToDate! <= endDate {
            return "endOfWeek"
        }
        let nowToString = formatter.string(from: nowToDate!)
        dateForCall += nowToString
        let dateTo = "&&to="
        dateForCall += dateTo
        dateForCall += nowToString
        return dateForCall
    }
    
    private func checkForFirstEntry() {
        let defaults = UserDefaults.standard
        var dateForCheck = defaults.string(forKey: "DateKey")
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let calendar = Calendar.current
        
        guard let date = dateForCheck, !date.isEmpty else {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd"
                let actualDate = Date()
                dateForCheck = formatter.string(from: actualDate)
                defaults.set(dateForCheck, forKey: "DateKey")
                let calendar = Calendar.current
                now = dateForCheck
                endDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
                getActualNews()
                return
            }
        defaults.set(date, forKey: "DateKey")
        now = defaults.string(forKey: "DateKey")
        endDate = formatter.date(from: date)!
        endDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        getLastSeenNews(with: date)
    }
    
    private func getLastSeenNews(with date: String) {
        var dateForCall = "&from="
        dateForCall += date
        dateForCall += "&to="
        dateForCall += date
        APICaller.shared.getActualNews(with: dateForCall) { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"), publishedAt: $0.publishedAt)
                })
                DispatchQueue.main.async {
                    self?.newsTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        newsTableView.register(nib, forCellReuseIdentifier: "NewsTableViewCell")
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        searchField.delegate = self
        
        checkForFirstEntry()
        
        addSwipeforKeyboard()
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell") as! NewsTableViewCell
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]

        guard let url = URL(string: article.url ?? "") else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset
            let bounds = scrollView.bounds
            let size = scrollView.contentSize
            let inset = scrollView.contentInset
            let y = offset.y + bounds.size.height - inset.bottom
            let h = size.height
      
        guard let text = searchField.text else {
            return
        }
        
        if y == h && text.isEmpty {
                print("load more rows")
                let text = getPrevDay()
                APICaller.shared.getPrevStories(with: text) { [weak self] result in
                    if text == "endOfWeek" {
                        print("EndOfWeek")
                        return
                    }
                    switch result {
                        case .success(let articles):
                            self?.articles += articles
                            self?.viewModels += articles.compactMap({
                                NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"), publishedAt: $0.publishedAt)
                            })
                            DispatchQueue.main.async {
                                self?.newsTableView.reloadData()
                            }
                        case .failure(let error):
                            print(error)
                        }
                }
              
                  print("EndUpdate")
            }
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchField.endEditing(true)
        getSearchStories()
    }
    
    private func getSearchStories() {
        
        guard let text = searchField.text, !text.isEmpty else {
            checkForFirstEntry()
            return
        }
        
        APICaller.shared.getSearchStories(with: text) { [weak self] result in
                switch result {
                case .success(let articles):
                    self?.articles = articles
                    self?.viewModels = articles.compactMap({
                        NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"), publishedAt: $0.publishedAt)
                    })
                    DispatchQueue.main.async {
                        self?.newsTableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
}

extension MainViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func addSwipeforKeyboard() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipe))
        swipeDown.delegate = self
        swipeDown.direction =  UISwipeGestureRecognizer.Direction.down
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.hideKeyboardOnSwipe))
        swipeUp.delegate = self
        swipeUp.direction = UISwipeGestureRecognizer.Direction.up
        self.newsTableView.addGestureRecognizer(swipeDown)
        self.newsTableView.addGestureRecognizer(swipeUp)
    }
    
    @objc func hideKeyboardOnSwipe() {
            view.endEditing(true)
        }
    
}

