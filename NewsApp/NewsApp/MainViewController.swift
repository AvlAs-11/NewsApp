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
    
    private var articles = [Article]()
    private var viewModels = [NewsModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        newsTableView.register(nib, forCellReuseIdentifier: "NewsTableViewCell")
        //2. Выставляешь источник для данных и методы делегатов для таблицы
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        searchField.delegate = self
        
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
        tableView.deselectRow(at: indexPath, animated: true)
        print("indexPath: \(indexPath.row)")
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
        guard let text = searchField.text, !text.isEmpty else {
            return
        }
        APICaller.shared.getSearchStories(with: text) { [weak self] result in
                switch result {
                case .success(let articles):
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
}

