//
//  PremiumProduct.swift
//  Captains Choice
//
//  Created by John Malatras on 6/6/18.
//  Copyright © 2018 John Malatras. All rights reserved.
//

import Foundation

public struct PremiumProduct {
    
    public static let PremiumIdentifier = "com.malatras.CaptainsChoice.premium"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [PremiumProduct.PremiumIdentifier]
    
    public static let store = IAPHelper(productIds: PremiumProduct.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
