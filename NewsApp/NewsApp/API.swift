
//
//  Model.swift
//  PhotoTest
//
//  Created by Pavel Avlasov on 10.08.2021.
//

import Foundation

struct APIResponse: Codable {
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
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

final class APICaller {
    static let shared = APICaller()
    
    // first key: d7c8194f9692481ab74e05727b68121f
    // second key:23490e0bf45d40cdb6fc78a2e307a444
    // third key: ebc1e0f856c54a4ba273198f7140cc94
    
    struct Constans {
        static let sampleURL =  "https://newsapi.org/v2/everything?domains=wsj.com,techcrunch.com,thenextweb.com&sortBy=publishedAt&language=en&apiKey=ebc1e0f856c54a4ba273198f7140cc94&pageSize=20&page=1"
        
        static let searchURL = "https://newsapi.org/v2/everything?sortedBy=publishedAt&apiKey=ebc1e0f856c54a4ba273198f7140cc94&pageSize=80&qInTitle="
        
        static let actualNewsURL = "https://newsapi.org/v2/everything?domains=wsj.com,techcrunch.com,thenextweb.com&sortBy=publishedAt&language=en&apiKey=ebc1e0f856c54a4ba273198f7140cc94&pageSize=20"
    }
    
    private init() {}
    
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
                    print("TotalResults: \(result.totalResults)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    public func getPrevStories(with request: String, completion: @escaping (Result<[Article], Error>) -> Void) {

        guard !request.isEmpty else {
            return
        }
        
        let searchRequest = Constans.sampleURL + request
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
                    print("TotalResults: \(result.totalResults)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    public func getActualNews(with actualDate: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        
        let urlRequest = Constans.actualNewsURL + actualDate
        
        guard let url = URL(string: urlRequest) else {
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
