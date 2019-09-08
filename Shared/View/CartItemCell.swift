//
//  CartItemCell.swift
//  Artable
//
//  Created by Michael Sidoruk on 03/09/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit

protocol CartItemDelegate: class {
    func removeItem(product: Product)
}

class CartItemCell: UITableViewCell {
    
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var removeItemBtn: UIButton!    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private var item: Product!
    weak var delegate: CartItemDelegate?
    
    func setupCell(product: Product) {
        
        self.item = product
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber) {
            productTitleLbl.text = "\(product.name) \(price)"
        }
        
        if let url = URL(string: product.imageUrl) {
            productImage.kf.setImage(with: url)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func removeItemBtnClicked(_ sender: Any) {
        delegate?.removeItem(product: item)
    }
    
}
