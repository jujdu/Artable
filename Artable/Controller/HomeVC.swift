//
//  HomeVC.swift
//  Artable
//
//  Created by Michael Sidoruk on 18/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit
import Firebase

class HomeVC: UIViewController {
    
    @IBOutlet weak var loginOutBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var categories = [Category]()
    var selectedCategory: Category!
    var db: Firestore!
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupNavigationBar()
        setupCollectionView()
        setupInitialAnonymousUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setCategoriesListener()
        
        if let user = Auth.auth().currentUser, !user.isAnonymous {
            loginOutBtn.title = "Logout"
        } else {
            loginOutBtn.title = "Login"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
        categories.removeAll()
        collectionView.reloadData()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Identifiers.CategoryCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.CategoryCell)
    }
    
    func setupInitialAnonymousUser() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (_, error) in
                if let error = error {
                    Auth.auth().handleFireAuthError(error: error, vc: self)
                    debugPrint(error)
                }
            }
        }
    }
    
    func setupNavigationBar() {
        guard let font = UIFont(name: "futura", size: 26) else { return }
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }

    func setCategoriesListener() {
        listener = db.categories.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let category = Category(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, category: category)
                case .modified:
                    self.onDocumentModified(change: change, category: category)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
        })
    }
    
    func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardID.LoginVC)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func loginOutBtnClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }
        
        if user.isAnonymous {
            presentLoginController()
        } else {
            do {
                try Auth.auth().signOut()
                Auth.auth().signInAnonymously { (_, error) in
                    if let error = error {
                        Auth.auth().handleFireAuthError(error: error, vc: self)
                        debugPrint(error)
                    }
                    self.presentLoginController()
                }
            } catch {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint(error)
            }
        }
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func onDocumentAdded(change: DocumentChange, category: Category) {
        let newIndex = Int(change.newIndex)
        categories.insert(category, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
    }
    
    func onDocumentModified(change: DocumentChange, category: Category) {
        if change.newIndex == change.oldIndex {
            //item changed, but in the same position(index)
            let oldIndex = Int(change.oldIndex)
            categories[oldIndex] = category
            collectionView.reloadItems(at: [IndexPath(item: oldIndex, section: 0)])
        } else {
            // item changed and position also
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            
            categories.remove(at: oldIndex)
            categories.insert(category, at: newIndex)
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0),
                                    to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        categories.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CategoryCell, for: indexPath) as? CategoryCell {
            cell.configureCell(category: categories[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let cellWidth = (width - 30) / 2
        let cellHeight = cellWidth * 1.5
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        
        performSegue(withIdentifier: Segues.ToProductsVC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ToProductsVC {
            if let destination = segue.destination as? ProductsVC {
                destination.category = selectedCategory
            }
        }
    }
}












// for only one and collections

//    func fetchDocument() {
//        let docRef = db.collection("categories").document("gh2GjgXfRmrWr1HLL9Li")
//
//        docRef.addSnapshotListener { (snap, error) in
//            self.categories.removeAll()
//            guard let data = snap?.data() else { return }
//            let newCategory = Category(data: data)
//            self.categories.append(newCategory)
//            self.collectionView.reloadData()
//        }
//        docRef.getDocument { (snap, error) in
//            guard let data = snap?.data() else { return }
//            let newCategory = Category(data: data)
//            self.categories.append(newCategory)
//            self.collectionView.reloadData()
//        }
//    }

//    func fetchConnection() {
//        let collectionRef = db.collection("categories")
//        listener = collectionRef.addSnapshotListener { (snap, error) in
//            guard let documents = snap?.documents else { return }
//
//            snap?.documentChanges
//            self.categories.removeAll()
//            for document in documents {
//                let data = document.data()
//                let newCategory = Category(data: data)
//                self.categories.append(newCategory)
//            }
//            self.collectionView.reloadData()
//        }

//        collectionRef.getDocuments { (snap, error) in
//            guard let documents = snap?.documents else { return }
//            for document in documents {
//                let data = document.data()
//                let newCategory = Category(data: data)
//                self.categories.append(newCategory)
//            }
//            self.collectionView.reloadData()
//        }
//    }
