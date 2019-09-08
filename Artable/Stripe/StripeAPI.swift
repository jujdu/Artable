//
//  StripeAPI.swift
//  Artable
//
//  Created by Michael Sidoruk on 08/09/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import Foundation
import Stripe
import FirebaseFunctions

class _StripeAPI: NSObject, STPCustomerEphemeralKeyProvider {
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let data = [
            "stripe_version": apiVersion
            "customer_id": UserService.user.stripeId
        ]
        
        Functions.functions().httpsCallable("createEphemeralKey").call(data) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let key = result?.data as? [String: Any] else {
                completion(nil, nil)
                return
            }
            
            completion(key, nil)
        }
    }
    
}
