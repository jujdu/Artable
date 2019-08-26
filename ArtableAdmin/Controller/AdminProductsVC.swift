//
//  AdminProductsVC.swift
//  ArtableAdmin
//
//  Created by Michael Sidoruk on 25/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit

class AdminProductsVC: ProductsVC {
    
    var selectedProduct: Product?

    override func viewDidLoad() {
        super.viewDidLoad()

        let editCategoryBtn = UIBarButtonItem(title: "Edit Category", style: .plain, target: self, action: #selector(editCategory))
        let newProductBtn = UIBarButtonItem(title: "+ Product", style: .plain, target: self, action: #selector(newProduct))
        navigationItem.setRightBarButtonItems([editCategoryBtn,newProductBtn], animated: false)
    }
    
    @objc func editCategory() {
        performSegue(withIdentifier: Segues.ToEditCategory, sender: self)
    }
    
    @objc func newProduct() {
        selectedProduct = nil
        performSegue(withIdentifier: Segues.ToAddEditProduct, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // editing product
        selectedProduct = products[indexPath.row]
        performSegue(withIdentifier: Segues.ToAddEditProduct, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToAddEditProduct {
            if let vc = segue.destination as? AddEditProductsVC {
                vc.selectedCategory = category
                vc.productToEdit = selectedProduct
            }
        } else if segue.identifier == Segues.ToEditCategory {
            if let vc = segue.destination as? AddEditCategoryVC {
                vc.categoryToEdit = category
            }
        }
    }
}
