//
//  AddEditCategoryVC.swift
//  ArtableAdmin
//
//  Created by Michael Sidoruk on 24/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AddEditCategoryVC: UIViewController {
    
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var categoryImage: RoundedImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: UIButton!
    
    var categoryToEdit: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tap.numberOfTapsRequired = 1
        categoryImage.isUserInteractionEnabled = true
        categoryImage.addGestureRecognizer(tap)
        
        //if we are editing, categoryToEdit will != nill
        if let category = categoryToEdit {
            nameTxt.text = category.name
            addBtn.setTitle("Save Changes", for: .normal)
            
            if let url = URL(string: category.imageUrl) {
                categoryImage.contentMode = .scaleAspectFill
                categoryImage.kf.setImage(with: url)
            }
        }
    }
    
    @objc func imageTapped() {
        launchImagePicker()
    }
    
    func uploadImageThenDocument() {
       
        guard let image = categoryImage.image,
            let categoryName = nameTxt.text, categoryName.isNotEmpty else {
                simpleAlert(title: "Error", message: "Must add category image and name")
                return
        }
        
        activityIndicator.startAnimating()
        
         //step1. turn the image into Data
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        
        //step2. create a storage image reference -> A location in Firestore for it to be stored
        let imageRef = Storage.storage().reference().child("/categoryImages/\(categoryName).jpg")
        
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
                print(url)
                
                   //step6. upload new category document to the firestore categories collection
                self.uploadDocument(url: url.absoluteString)
            })
        }
    }
    
    func uploadDocument(url: String) {
        var docRef: DocumentReference!
        var category = Category(name: nameTxt.text!,
                                id: "",
                                imageUrl: url,
                                timeStamp: Timestamp())
        
        if let categoryToEdit = categoryToEdit {
          // we are editing
            docRef = Firestore.firestore().collection("categories").document(categoryToEdit.id)
            category.id = categoryToEdit.id
        } else {
            //new category
            docRef = Firestore.firestore().collection("categories").document()
            category.id = docRef.documentID
        }
        
        let data = Category.modelToData(category: category)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error: error, message: "Unable to upload new category")
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
    
    @IBAction func addCategoryClicked(_ sender: Any) {
        uploadImageThenDocument()
    }
    
}

extension AddEditCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func launchImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        categoryImage.contentMode = .scaleToFill
        categoryImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
