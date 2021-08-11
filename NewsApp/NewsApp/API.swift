
//
//  Model.swift
//  PhotoTest
//
//  Created by Pavel Avlasov on 10.08.2021.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constans {
        static let  topHeadLinesURL = URL(string: "https://newsapi.org/v2/top-headlines?country=us&apiKey=d7c8194f9692481ab74e05727b68121f")
        static let searchURL = "https://newsapi.org/v2/everything?sortedBy=popylarity&apiKey=d7c8194f9692481ab74e05727b68121f&q="
    }
    
    private init() {}
    
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constans.topHeadLinesURL else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Atricles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    public func getSearchStories(with request: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !request.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let searchRequest = Constans.searchURL + request
        guard let url = URL(string: searchRequest) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Atricles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

struct APIResponse: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let pablishedAt: String?
    let source: Source
}

struct SourcesResponse: Codable {
    let status: String
    let sources: [Source]
}

struct Source: Codable {
    let id: String?
    let name: String?
    let description: String?
    let country: String?
    let category: String?
    let url: String?
}
