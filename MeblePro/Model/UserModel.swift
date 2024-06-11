//
//  UserModel.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 21/12/2023.
//

import Foundation

struct User: Hashable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var companyName: String
    var companyKey:String
}
