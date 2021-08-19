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
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var refreshDateButton: UIButton!
    
    private var articles = [Article]()
    private var viewModels = [NewsModel]()
    var now: String?
    var endDate = Date()
    var lastSeenOnlineDate = Date()
    
    private func getActualNews() {
        let actualDate = getDate()
        APICaller.getActualNews(with: actualDate) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let articles):
                self.articles = articles
                self.viewModels = articles.compactMap({
                    NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? ""), publishedAt: $0.publishedAt)
                })
                DispatchQueue.main.async {
                    self.newsTableView.reloadData()
                }
            case .failure(let error):
                self.showMessage(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    private func getDate() -> String{
        var date = "&from="
        let actualDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let actualDateToString = formatter.string(from: actualDate)
        date += actualDateToString
        date += "&to="
        date += actualDateToString
        now = actualDateToString
        let calendar = Calendar.current
        endDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        let defaults = UserDefaults.standard
        defaults.set(actualDateToString, forKey: "DateKey")
        return date
    }
    @IBAction func refreshDate(_ sender: Any) {
        newsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        getActualNews()
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
            return ""
        }
        let nowToString = formatter.string(from: nowToDate!)
        dateForCall += nowToString
        let dateTo = "&to="
        dateForCall += dateTo
        dateForCall += nowToString
        return dateForCall
    }
    
    private func checkForFirstEntry() {
        let defaults = UserDefaults.standard
        let dateForCheck = defaults.string(forKey: "DateKey")
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let calendar = Calendar.current
        
        guard let date = dateForCheck, !date.isEmpty else {
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
        APICaller.getActualNews(with: dateForCall) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let articles):
                self.articles = articles
                self.viewModels = articles.compactMap({
                    NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? ""), publishedAt: $0.publishedAt)
                })
                DispatchQueue.main.async {
                    self.newsTableView.reloadData()
                }
            case .failure(let error):
                self.showMessage(title: "Error", message: error.localizedDescription)
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
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        
        guard let articleURL = article.url, let url = URL(string: articleURL) else {
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
            let prevDate = getPrevDay()
            APICaller.getPrevStories(with: prevDate) { [weak self] result in
                if prevDate.isEmpty {
                    return
                }
                guard let self = self else { return }
                switch result {
                case .success(let articles):
                    self.articles += articles
                    self.viewModels += articles.compactMap({
                        NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"), publishedAt: $0.publishedAt)
                    })
                    DispatchQueue.main.async {
                        self.newsTableView.reloadData()
                    }
                case .failure(let error):
                    self.showMessage(title: "Error", message: error.localizedDescription)
                }
            }
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
        
        APICaller.getSearchStories(with: text) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let articles):
                self.articles = articles
                self.viewModels = articles.compactMap({
                    NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"), publishedAt: $0.publishedAt)
                })
                DispatchQueue.main.async {
                    self.newsTableView.reloadData()
                }
            case .failure(let error):
                self.showMessage(title: "Error", message: error.localizedDescription)
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

