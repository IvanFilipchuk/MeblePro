//
//  EditKomponentView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct EditKomponentView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @Environment(\.dismiss) var dismiss
    @State var komponentMaterial = ""
    @State var komponentDlugosc: Int = 0
    @State var komponentSzerokosc: Int = 0
    @State var komponentGrubosc: Int = 0
    @State var komponentIlosc: Int = 0
    @State var komponentJednostka = ""
    @State var komponentKolor = ""
    @State var komponentUwagi = ""
    var komponent: Komponent?
    
    var body: some View {
           List {
               Section(header: Text("Materiał")) {
                   TextField("Typ Materiału", text: $komponentMaterial)
               }

               Section(header: Text("Wymiary")) {
                   HStack {
                       Text("Długość")
                           .frame(width: 100, alignment: .leading)
                       Divider()
                       TextField("Podaj długość w mm", value: $komponentDlugosc, formatter: NumberFormatter())
                   }
                   HStack {
                       Text("Szerokość")
                           .frame(width: 100, alignment: .leading)
                       Divider()
                       TextField("Podaj szerokość w mm", value: $komponentSzerokosc, formatter: NumberFormatter())
                   }
                   
                   HStack {
                       Text("Grubość")
                           .frame(width: 100, alignment: .leading)
                       Divider()
                       TextField("Podaj grubość w mm", value: $komponentGrubosc, formatter: NumberFormatter())
                   }
                   
                   HStack {
                       Text("Ilość")
                           .frame(width: 100, alignment: .leading)
                       Divider()
                       TextField("Podaj ilość w sztukach", value: $komponentIlosc, formatter: NumberFormatter())
                   }   
                   HStack {
                       Text("Jednostka")
                           .frame(width: 100, alignment: .leading)
                       Divider()
                       TextField("Podaj jednostkę w mm", text: $komponentJednostka)
                   }
               }

               Section(header: Text("Dekor")) {
                  TextField("Dekor", text: $komponentKolor)
                
               }
               Section(header: Text("Uwagi")) {
                   TextField("Uwagi", text: $komponentUwagi)
               }

               Section(header: Text("")) {
                   Button {
                       if let komponent = komponent {
                           let newKomponent = Komponent(
                               id: komponent.id,
                               text: komponentMaterial,
                               dlugosc: komponentDlugosc,
                               szerokosc: komponentSzerokosc,
                               ilosc: komponentIlosc,
                               grubosc: komponentGrubosc,
                               jednostka: komponentJednostka,
                               kolor: komponentKolor,
                               uwagi: komponentUwagi,
                               dateCreated: komponent.dateCreated,
                               isCompleted: komponent.isCompleted
                           )
                           myAppVM.updateKomponent(updateKomponent: newKomponent)
                       }
                   } label: {
                       Text("Aktualizuj Komponent")
                   }
               }
           }
           .toolbar {
               ToolbarItem(placement: .navigationBarTrailing) {
                   Button("Zamknij") {
                       dismiss()
                   }
               }
           }
           .navigationTitle("Aktualizuj Komponent")
       }
   }
struct EditKomponentView_Previews: PreviewProvider {
    static var previews: some View {
        EditKomponentView()
    }
}
