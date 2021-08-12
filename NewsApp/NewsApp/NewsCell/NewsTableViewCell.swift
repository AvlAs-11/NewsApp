//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Pavel Avlasov on 10.08.2021.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0
        setShadowForImage()
//        titleLabel.sizeToFit()
//        descriptionLabel.sizeToFit()
    }
    
    func configure(with viewModel: NewsModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.subTitle
        
        if let data = viewModel.imageData {
            newsImage.image = UIImage(data: data)
        }
        else if let url = viewModel.imageURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                viewModel.imageData = data
                DispatchQueue.main.async {
                    self?.newsImage.image = UIImage(data: data)
                }
            }.resume()
        }
    }
    
    func setShadowForImage() {
        
        newsImage.layer.shadowColor = UIColor.black.cgColor
        newsImage.layer.cornerRadius = 10
        newsImage.clipsToBounds = true
        newsImage.layer.shadowRadius = 10
        newsImage.layer.shadowOpacity = 1
        newsImage.layer.shadowOffset = CGSize(width: -5, height: -5)
    }
}
