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
    var imageData: Data? = nil
    
    init(title: String, subTitle: String, imageURL: URL?) {
        self.title = title
        self.subTitle = subTitle
        self.imageURL = imageURL
    }
}
