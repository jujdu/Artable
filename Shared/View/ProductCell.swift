//
//  ProductCell.swift
//  Artable
//
//  Created by Michael Sidoruk on 22/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit
import Kingfisher

protocol ProductCellDelegate: class {
    func productFavorited(product: Product)
    func productAddToCart(product: Product)
}

class ProductCell: UITableViewCell {
    
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    
    weak var delegate: ProductCellDelegate?
    private var product: Product!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(product: Product) {
        self.product = product
        
        productTitle.text = product.name
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber) {
            productPrice.text = price
        }
        
        if let url = URL(string: product.imageUrl) {
            let placeholder = UIImage(named: AppImages.Placeholder)
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.1))]
            productImage.kf.indicatorType = .activity
            productImage.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
        
        if UserService.favorites.contains(product) {
            favoriteBtn.setImage(UIImage(named: AppImages.FilledStar), for: .normal)
        } else {
            favoriteBtn.setImage(UIImage(named: AppImages.EmptyStar), for: .normal)
        }
    }

    @IBAction func addToCartClicked(_ sender: Any) {
        delegate?.productAddToCart(product: product)
    }
    
    @IBAction func favoriteClicked(_ sender: Any) {
        delegate?.productFavorited(product: product)
    }
    
}
