//
//  NewsTableViewCell.swift
//  NewsApp
//
//  Created by Pavel Avlasov on 10.08.2021.
//

import UIKit
import Kingfisher

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var backImageView: UIView!
    var showMore: (()->())?
    
    @IBAction func showMore(_ sender: Any) {
        if let action = showMore {
            action()
        }
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setShadow()
    }
    
    func configure(with viewModel: NewsModel) {
        
        titleLabel.text = viewModel.title
        titleLabel.numberOfLines = 0
        descriptionLabel.text = viewModel.subTitle
        descriptionLabel.numberOfLines = 3
        showMoreButton.isHidden = descriptionLabel.maxNumberOfLines < 4
        newsImage.kf.setImage(with: viewModel.imageURL, placeholder: UIImage(named: "placeholderImage"))
    }
    
    func setShadow() {
        backImageView.backgroundColor = .clear
        backImageView.layer.shadowRadius = 10
        backImageView.layer.shadowOffset = CGSize(width: -2, height: 15)
        backImageView.layer.shadowOpacity = 0.7
    }
}

extension UILabel {
    
    var maxNumberOfLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font!], context: nil).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}
