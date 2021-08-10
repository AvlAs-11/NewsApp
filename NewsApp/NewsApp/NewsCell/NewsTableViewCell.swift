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
        //self.sizeToFit()
    }
    
    func configure(with viewModel: NewsModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.subTitle
        
        if let data = viewModel.imageData {
            newsImage.image = UIImage(data: data)
        }
        else {
            
        }
    }
}