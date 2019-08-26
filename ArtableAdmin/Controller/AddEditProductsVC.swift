//
//  AddEditProductsVC.swift
//  ArtableAdmin
//
//  Created by Michael Sidoruk on 25/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditProductsVC: UIViewController {
    
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var productPriceTxt: UITextField!
    @IBOutlet weak var productDescTxt: UITextView!
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: RoundedButton!
    
    var selectedCategory: Category!
    var productToEdit: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tap.numberOfTapsRequired = 1
        productImage.isUserInteractionEnabled = true
        productImage.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if we are editing, productToEdit will != nill
        if let product = productToEdit {
            productNameTxt.text = product.name
            productPriceTxt.text = String(product.price)
            productDescTxt.text = product.productDescription
            addBtn.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: product.imageUrl) {
                productImage.contentMode = .scaleAspectFill
                productImage.kf.setImage(with: url)
            }
        }
    }
    
    @objc func imageTapped() {
        launchImagePicker()
    }
    
    func uploadImageThenDocument() {
        guard let image = productImage.image,
            let productName = productNameTxt.text, productName.isNotEmpty,
            let productPrice = productPriceTxt.text, productPrice.isNotEmpty,
            let productDescription = productDescTxt.text, productDescription.isNotEmpty else {
                simpleAlert(title: "Error", message: "Please fill out all required fields")
                activityIndicator.stopAnimating()
                return
        }
        
        guard let _ = Double(productPrice) else {
            simpleAlert(title: "Error", message: "Only digits are available for price")
            activityIndicator.stopAnimating()
            return
        }
        
        activityIndicator.startAnimating()

        //step1. turn the image into Data
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        
        //step2. create a storage image reference -> A location in Firestore for it to be stored
        let imageRef = Storage.storage().reference().child("/productImages/\(productName).jpg")
        
        //step3. set the meta data
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        //step4. upload the data
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            
            if let error = error {
                self.handleError(error: error, message: "Unable to upload image")
                return
            }
            
            //step5. one the imagge is upload, retrieve the dowload url
            imageRef.downloadURL(completion: { (url, error) in
                
                if let error = error {
                    self.handleError(error: error, message: "Unable to download image")
                    return
                }
                
                guard let url = url else { return }
                //step6. upload new category document to the firestore categories collection
                self.uploadDocument(url: url.absoluteString)
            })
        }
    }
    
    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        guard let price = Double(productPriceTxt.text!) else { return }
        var product = Product(name: productNameTxt.text!,
                              id: "",
                              category: selectedCategory.id,
                              price: price,
                              productDescription: productDescTxt.text!,
                              imageUrl: url,
                              timeStamp: Timestamp())
        
        if let productToEdit = productToEdit {
            // we are editing
            docRef = Firestore.firestore().collection("products").document(productToEdit.id)
            product.id = productToEdit.id
        } else {
            //new category
            docRef = Firestore.firestore().collection("products").document()
            product.id = docRef.documentID
        }
        
        let data = Product.modelToData(product: product)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error: error, message: "Unable to upload new product")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func handleError(error: Error, message: String) {
        debugPrint(error.localizedDescription)
        simpleAlert(title: "Error", message: message)
        activityIndicator.stopAnimating()
    }
    
    @IBAction func addClicked(_ sender: Any) {
        uploadImageThenDocument()
    }
}

extension AddEditProductsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true) {
            guard let image = info[.originalImage] as? UIImage else { return }
            self.productImage.contentMode = .scaleToFill
            self.productImage.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
