//
//  Constants.swift
//  Artable
//
//  Created by Michael Sidoruk on 18/08/2019.
//  Copyright © 2019 Michael Sidoruk. All rights reserved.
//

import UIKit

struct Storyboard {
    static let LoginStoryboard = "LoginStoryboard"
    static let Main = "Main"
}

struct StoryboardID {
    static let LoginVC = "loginVC"
}

struct NibNames {
    static let ForgotPasswordVC = "ForgotPasswordVC"
}

struct AppImages {
    static let GreenCheck = "green_check"
    static let RedCheck = "red_check"
    static let FilledStar = "filled_star"
    static let EmptyStar = "empty_star"
    static let Placeholder = "placeholder"
}

struct AppColors {
    static let Blue = #colorLiteral(red: 0.2183115184, green: 0.2036479712, blue: 0.3163332343, alpha: 1)
    static let Red = #colorLiteral(red: 0.8739202619, green: 0.4776076674, blue: 0.385545969, alpha: 1)
    static let Offwhite = #colorLiteral(red: 0.9626371264, green: 0.959995091, blue: 0.9751287103, alpha: 1)
}

struct Identifiers {
    static let CategoryCell = "CategoryCell"
    static let ProductCell = "ProductCell"
    static let CartItemCell = "CartItemCell"
}

struct Segues {
    static let ToProductsVC = "toProductsVC"
    static let ToAddEditCategoryVC = "toAddEditCategoryVC"
    static let ToEditCategory = "toEditCategory"
    static let ToAddEditProduct = "toAddEditProduct"
    static let ToFavorites = "toFavorites"
}
