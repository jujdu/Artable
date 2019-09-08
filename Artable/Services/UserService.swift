//
//  UserService.swift
//  Artable
//
//  Created by Michael Sidoruk on 26/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let UserService = _UserServices()

final class _UserServices {
    
    var user = User()
    var favorites = [Product]()
    let auth = Auth.auth()
    let db = Firestore.firestore()
    var userListener: ListenerRegistration? = nil
    var favsListener: ListenerRegistration? = nil
    
    var isGuest: Bool {
        
        guard let authUser = auth.currentUser else { return true }
        
        if authUser.isAnonymous {
            return true
        } else {
            return false
        }
    }
    
    func getCurrentUser() {
        guard let authUser = auth.currentUser else { return }
        let userRef = db.collection("users").document(authUser.uid)
        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            guard let data = snap?.data() else { return }
            self.user = User(data: data)
            
        })
        
        let favsRef = userRef.collection("favorites")
        favsListener = favsRef.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documents.forEach({ (document) in
                let favorite = Product(data: document.data())
                self.favorites.append(favorite)
            })
        })
    }
    
    func logoutUser() {
        userListener?.remove()
        userListener = nil
        favsListener?.remove()
        favsListener = nil
        user = User()
        favorites.removeAll()
    }
    
    func favoriteSelected(product: Product) {
        let favsRef = Firestore.firestore().collection("users").document(user.id).collection("favorites")
        if favorites.contains(product) {
            //we remove it as a favorite
            favorites.removeAll { $0 == product }
            favsRef.document(product.id).delete()
        } else {
            //add
            favorites.append(product)
            let data = Product.modelToData(product: product)
            favsRef.document(product.id).setData(data)
        }
    }
}
