//
//  DeletedKomponentsModel.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 21/12/2023.
//

import Foundation

struct DeletedKomponent: Hashable, Identifiable {
    var id: String
    var text: String
    var dlugosc: Int
    var szerokosc: Int
    var ilosc: Int
    var grubosc: Int
    var jednostka: String
    var kolor : String
    var uwagi: String
    var dateCreated: Date
    var isCompleted: Bool
    var lastUpdated: Date?
}
