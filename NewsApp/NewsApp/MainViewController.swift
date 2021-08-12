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
    
    private func getTopStories() {
        
        APICaller.shared.getTopStories { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"))
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
        
        APICaller.shared.getActualNews { [weak self] result in
            switch result {
            case .success(let articles):
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"))
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
        let formatter = DateFormatter()
        //2016-12-08 03:37:22 +0000
        formatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let dateString = formatter.string(from:now)
        var dateForCall = "&from="
        dateForCall += dateString
        getActualNews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        newsTableView.register(nib, forCellReuseIdentifier: "NewsTableViewCell")
        //2. Выставляешь источник для данных и методы делегатов для таблицы
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        searchField.delegate = self
        
        getTopStories()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.deselectRow(at: indexPath, animated: true)
        
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        getSearchStories()
        
    }
    
    private func getSearchStories() {
        
        guard let text = searchField.text, !text.isEmpty else {
            getTopStories()
            return
        }
        
        APICaller.shared.getSearchStories(with: text) { [weak self] result in
                switch result {
                case .success(let articles):
                    
                    self?.viewModels = articles.compactMap({
                        NewsModel(title: $0.title, subTitle: $0.description ?? "No description", imageURL: URL(string: $0.urlToImage ?? "https://shmector.com/_ph/18/412122157.png"))
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

