//
//  APIResponse.swift
//  NewsApp
//
//  Created by Pavel Avlasov on 19.08.2021.
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
