//
//  CompanyModel.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 21/12/2023.
//

import Foundation

struct Company: Hashable,Identifiable {
    var id: String
    var name: String
    var secureCode: String
}
