//
//  NewsModel.swift
//  NewsApp
//
//  Created by Pavel Avlasov on 11.08.2021.
//

import Foundation


class NewsModel {
    let title: String
    let subTitle: String
    let imageURL: URL?
    var imageData: Data?
    let publishedAt: String
    
    init(title: String, subTitle: String, imageURL: URL?, publishedAt: String) {
        self.title = title
        self.subTitle = subTitle
        self.imageURL = imageURL
        self.publishedAt = publishedAt
        //self.publishedAt =
//        self.publishedAt = formatter.string(from: publishedAt)
        //self.publishedAt = publishedAt
    }
}
