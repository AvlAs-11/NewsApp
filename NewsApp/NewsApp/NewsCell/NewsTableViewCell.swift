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
    @IBOutlet weak var showMoreButton: UIButton!
    
    @IBAction func showMore(_ sender: Any) {
        
        let text = self.descriptionLabel.text
        let tableview = superview as? UITableView
        self.descriptionLabel.text = text
        
        tableview?.beginUpdates()
        self.descriptionLabel.numberOfLines = 0
        self.showMoreButton.isHidden = true
        self.descriptionLabel.text = text
        tableview?.endUpdates()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(with viewModel: NewsModel) {
        
        titleLabel.text = viewModel.title
        titleLabel.numberOfLines = 0
        descriptionLabel.text = viewModel.subTitle
        descriptionLabel.numberOfLines = 3
        
        if (descriptionLabel.maxNumberOfLines < 4) {
            showMoreButton.isHidden = true
        }
        else {
            showMoreButton.isHidden = false
        }
        
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
}

extension UILabel {
    
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let textHeight = sizeThatFits(maxSize).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
    
    var maxNumberOfLines: Int {
            let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
            let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font!], context: nil).height
            let lineHeight = font.lineHeight
            return Int(ceil(textHeight / lineHeight))
        }
}
