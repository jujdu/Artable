//
//  StripeCart.swift
//  Artable
//
//  Created by Michael Sidoruk on 03/09/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import Foundation

let StripeCart = _StripeCart()

final class _StripeCart {
    
    var cartItems = [Product]()
    private let stripeCreditCartCut = 0.029
    private let flatFeeCents = 30
    var shippingFees = 0
    
    var subtotal: Int {
        var amount = 0
        for item in cartItems {
            let pricePennies = Int(item.price * 100)
            amount += pricePennies
        }
        return amount
    }
    
    var processingFees: Int {
        if subtotal == 0 {
            return 0
        }
        
        let sub = Double(subtotal)
        let feesAndSubb = Int(sub * stripeCreditCartCut) + flatFeeCents
        return feesAndSubb
    }
    
    var total: Int {
        return subtotal + processingFees + shippingFees
    }
    
    func addItemToCart(item: Product) {
        cartItems.append(item)
    }
    
    func removeItemFromCart(item: Product) {
        if let index = cartItems.firstIndex(of: item) {
            cartItems.remove(at: index)
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
}
