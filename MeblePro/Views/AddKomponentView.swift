//
//  AddKomponentView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 26/10/2023.
//

import SwiftUI

struct AddKomponentView: View {
    
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State private var komponentMaterial = ""
    @State private var komponentDlugosc: Int = 0
    @State private var komponentSzerokosc: Int = 0
    @State private var komponentGrubosc: Int = 0
    @State private var komponentIlosc: Int = 0
    @State private var komponentJednostka = ""
    @State private var komponentKolor = ""
    @State private var komponentUwagi = ""
    @State private var selectedMaterial: String = "MDF laminowane"
    @State private var selectedUnit: String = "mm"
    @State private var searchText: String = ""

    let allMaterials = ["MDF surowe", "MDF laminowane", "Płyty wiórowe: OBS i MFP", "Płyty paździerzowe", "Płyty melaminowe", "Sklejki", "Płyty pilśniowe", "Szkło", "Lustro"]
    let allUnits = ["mm", "cm", "m"]

    var body: some View {
        Form {
            Section(header: Text("Materiał")) {
                Picker("Typ Materiału", selection: $selectedMaterial) {
                    ForEach(allMaterials, id: \.self) { material in
                        Text(material)
                    }
                }
                .onChange(of: selectedMaterial, perform: { value in
                    komponentKolor = value
                })
            }
            Section(header: Text("Wymiary")) {
                HStack {
                    Text("Długość")
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    TextFieldV03(value: $komponentDlugosc, placeholder: "Podaj długość w mm")
                }
                
                HStack {
                    Text("Szerokość")
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    TextFieldV03(value: $komponentSzerokosc, placeholder: "Podaj szerokość w mm")
                }
                
                HStack {
                    Text("Grubość")
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    TextFieldV03(value: $komponentGrubosc, placeholder: "Podaj grubość w mm")
                }
                
                HStack {
                    Text("Ilość")
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    TextFieldV03(value: $komponentIlosc, placeholder: "Podaj ilość w sztukach")
                }
            }

            Section(header: Text("Dekor")) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Wyszukaj Dekor", text: $searchText)

                    Picker("", selection: $komponentKolor) {
                        ForEach(filteredDekors, id: \.id) { kolor in
                            Text(kolor.name).tag(kolor.name)
                        }
                    }
                    .id(UUID())
                    .pickerStyle(MenuPickerStyle())
                }
            }

            Section(header: Text("Uwagi")) {
                TextFieldV02(value: $komponentUwagi, placeholder: "Uwagi")
            }

            Section {
                Button {
                    myAppVM.addNewKomponent(komponentMaterial: selectedMaterial, komponentDlugosc: komponentDlugosc, komponentSzerokosc: komponentSzerokosc,komponentGrubosc: komponentGrubosc, komponentIlosc: komponentIlosc, komponentJednostka: "mm", komponentKolor: komponentKolor, komponentUwagi: komponentUwagi)
                    clearFields()
                } label: {
                    Text("Dodaj nowy komponent")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .listRowBackground(Color.clear)
                
            }
        }
        .onAppear {
            komponentJednostka = selectedUnit
        }
        .onAppear {
            komponentMaterial = selectedMaterial
        }
    }

    private var filteredDekors: [Dekor] {
        if searchText.isEmpty {
            return myAppVM.allDekors
        } else {
            return myAppVM.allDekors.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    func clearFields() {
        komponentDlugosc = 0
        komponentSzerokosc = 0
        komponentGrubosc = 0
        komponentIlosc = 0
        komponentJednostka = ""
        komponentKolor = ""
        komponentUwagi = ""
        searchText = ""
    }
}

struct AddKomponentView_Previews: PreviewProvider {
    static var previews: some View {
        AddKomponentView()
    }
}
 
