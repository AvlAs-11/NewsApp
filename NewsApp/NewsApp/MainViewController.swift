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
    
    private func getTopStories() {
        
        APICaller.shared.getTopStories { [weak self] result in
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
        print("pressed")
        var text = "&from="
        let actualDate = Date()
        print(actualDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let actualDateToString = formatter.string(from: actualDate)
        print(actualDateToString)
        text += actualDateToString
        text += "&to="
        text += actualDateToString
        now = formatter.string(from: actualDate)
        print("now: \(now!)")
        let calendar = Calendar.current
        print(endDate)
        endDate = Date()
        endDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        
        print("endDate: \(endDate)")
        let defaults = UserDefaults.standard
        defaults.set(actualDateToString, forKey: "DateKey")
        //2016-12-08 03:37:22 +0000
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
//                        self?.newsTableView.beginUpdates()
                        
                        self?.newsTableView.reloadData()
//                       self?.newsTableView.endUpdates()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    private func getPrevDay() -> String {
        
//        let defaults = UserDefaults.standard
//        let date = defaults.string(forKey: "DateKey")
        var dateForCall : String
        dateForCall = "&from="
        let formatter = DateFormatter()
        let calendar = Calendar.current
        formatter.dateFormat = "yyyy-MM-dd"
        var nowToDate = formatter.date(from: now!)
        nowToDate = calendar.date(byAdding: .day, value: -1, to: nowToDate!)
        print(now!)
        now = formatter.string(from: nowToDate!)
        
        print(endDate)
        if nowToDate! <= endDate {
            return "endOfWeek"
        }
        let nowToString = formatter.string(from: nowToDate!)
        dateForCall += nowToString
        let dateTo = "&&to="
        dateForCall += dateTo
        dateForCall += nowToString
        print(nowToDate!)
        print(endDate)
        return dateForCall
    }
    
    private func checkForFirstEntry() {
        let defaults = UserDefaults.standard
        var dateForCheck = defaults.string(forKey: "DateKey")
//        if dateForCheck == "" {
//            print("EEEE")
//            let formatter = DateFormatter()
//            formatter.dateFormat = "YYYY-MM-dd"
//            let actualDate = Date()
//            dateForCheck = formatter.string(from: actualDate)
//            defaults.set(dateForCheck, forKey: "DateKey")
//            let calendar = Calendar.current
//            endDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
//            getActualNews()
//        }
//        else {
            print(dateForCheck!)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy/MM/dd HH:mm"
//            let someDateTime = formatter.date(from: "2016/10/08 22:31")
            let calendar = Calendar.current
        //dateForCheck = "2021-08-10"
        guard let date = dateForCheck, !date.isEmpty else {
                print("EEEE")
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
        //date = "2021-08-10"
        defaults.set(date, forKey: "DateKey")
        now = defaults.string(forKey: "DateKey")
        endDate = formatter.date(from: date)!
        endDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
        print(endDate)
        //let endDateToString = formatter.string(from: endDate)
        getLastSeenNews(with: date)
        //}
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
//        let x = UserDefaults.standard
//        x.set("", forKey: "DateKey")
       
//        let calendar = Calendar.current
//        endDate = calendar.date(byAdding: .day, value: -7, to: endDate)!
    }


}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
   public func reload() {
    
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell") as! NewsTableViewCell
//        let viewModel = viewModels[indexPath.row]
//        if (viewModel.publishedAt != "2021-07-27T") {
//            return cell
//        }
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
        print("PublishedAt: \(article.publishedAt)")
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
//            let reload_distance:CGFloat = 50.0
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
        //                        self?.newsTableView.beginUpdates()
                                
                                self?.newsTableView.reloadData()
        //                       self?.newsTableView.endUpdates()
                            }
                        case .failure(let error):
                            print(error)
                        }
                }
                //viewModels = 
                  print("EndUpdate")
            }
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
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
//                        self?.newsTableView.beginUpdates()
                        
                        self?.newsTableView.reloadData()
//                       self?.newsTableView.endUpdates()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
}

