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
        
        print(self.descriptionLabel.numberOfVisibleLines)
        print(self.descriptionLabel.maxNumberOfLines)
        let text = self.descriptionLabel.text
        //self.descriptionLabel.sizeToFit()
        let tableview = superview as? UITableView
//        tableview?.reloadData()
        print("text: \(text!)")
        self.descriptionLabel.text = text
        print("Height: \(self.descriptionLabel.frame.size.height)")
        tableview?.beginUpdates()
//        self.descriptionLabel.sizeToFit()
        self.descriptionLabel.numberOfLines = 0
        
        self.showMoreButton.isHidden = true
        self.descriptionLabel.text = text
        //self.descriptionLabel.numberOfLines = 0
        //print("Description: \(self.descriptionLabel.text)")
        
        tableview?.endUpdates()
        print("Nubmer of lines: \(self.descriptionLabel.numberOfLines)")
        //self.descriptionLabel.frame.size.height = 100
        print("Height: \(self.descriptionLabel.frame.size.height)")
        //self.descriptionLabel.frame.size.height = 100
        print("Height: \(self.descriptionLabel.frame.size.height)")
//        tableview?.reloadData()
//        tableview?.estimatedRowHeight = 300
//        tableview?.sizeToFit()
//        tableview?.rowHeight = UITableView.automaticDimension
//        tableview?.frame.size.height = UITableView.automaticDimension
        
        
       
    }
    
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
//        titleLabel.numberOfLines = 0
//        descriptionLabel.numberOfLines = 3
        
        print("First height: \(descriptionLabel.frame.size.height)")
//        descriptionLabel.sizeToFit()
        setShadowForImage()
//        titleLabel.sizeToFit()
//        descriptionLabel.sizeToFit()
    }
    
    func configure(with viewModel: NewsModel) {
        
        titleLabel.text = viewModel.title
        titleLabel.numberOfLines = 0
        descriptionLabel.text = viewModel.subTitle
//        descriptionLabel.numberOfLines = 0
        print("First height: \(descriptionLabel.frame.size.height)")
        descriptionLabel.numberOfLines = 3
        print("Second Height height: \(descriptionLabel.frame.size.height)")
        if (descriptionLabel.maxNumberOfLines < 4) {
            showMoreButton.isHidden = true
        }
        
        print()
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
            let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
            let lineHeight = font.lineHeight
            return Int(ceil(textHeight / lineHeight))
        }
}
