//
//  Category.swift
//  Artable
//
//  Created by Michael Sidoruk on 20/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import FirebaseFirestore

struct Category {
    
    var name: String
    var id: String
    var imageUrl: String
    var isActive: Bool = true
    var timeStamp: Timestamp
    
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.isActive = data["isActive"] as? Bool ?? true
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
    }
    
    init(name: String, id: String, imageUrl: String, isActive: Bool = true, timeStamp: Timestamp) {
        self.name = name
        self.id = id
        self.imageUrl = imageUrl
        self.isActive = isActive
        self.timeStamp = timeStamp
    }
    
    static func modelToData(category: Category) -> [String: Any] {
        let data: [String: Any] = [
            "name": category.name,
            "id": category.id,
            "imageUrl": category.imageUrl,
            "isActive": category.isActive,
            "timeStamp": category.timeStamp
        ]
        return data
    }
}
