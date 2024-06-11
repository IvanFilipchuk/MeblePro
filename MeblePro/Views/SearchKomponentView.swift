//
//  SearchKomponentView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 30/10/2023.
//

import SwiftUI

struct SearchKomponentView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State private var taskText = ""
    @State private var taskDlugosc: Int = 0
    @State private var taskSzerokosc: Int = 0
    @State private var taskGrubosc: Int = 0
    @State private var taskIlosc: Int = 0
    @State private var taskJednostka = ""
    @State private var taskKolor = ""
    @State private var taskUwagi = ""
    @State private var searchDlugosc: Int = 0
    @State private var searchSzerokosc: Int = 0
    @State private var searchGrubosc: Int = 0
    @State private var searchKolor = ""
    @State private var isDlugoscAsSzerokosc = false
    @State private var searchSelectedColor = ""
    @State private var szerokoscPily = 3
    @State private var searchIlosc = 1
    @State private var selectedMaterial: String = "MDF laminowane"
    
    let allMaterials = ["MDF surowe", "MDF laminowane", "Płyty wiórowe: OBS i MFP", "Płyty paździerzowe", "Płyty melaminowe", "Sklejki", "Płyty pilśniowe", "Szkło", "Lustro"]
    var body: some View {
        Form {
            Section(header: Text("Wyszukaj komponent")) {
                Picker("Typ Materiału", selection: $selectedMaterial) {
                    ForEach(allMaterials, id: \.self) { material in
                        Text(material)
                    }
                }
                    HStack {
                        Text("Długość")
                            .frame(width: 100, alignment: .leading)
                        Divider()
                        TextField("Podaj długość w mm", value: isDlugoscAsSzerokosc ? $searchSzerokosc : $searchDlugosc, formatter: NumberFormatter())
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(180))
                            .onTapGesture {
                                let temp = searchDlugosc
                                searchDlugosc = searchSzerokosc
                                searchSzerokosc = temp
                            }
                    }
                    HStack {
                        Text("Szerokość")
                            .frame(width: 100, alignment: .leading)
                        Divider()
                        TextField("Podaj szerokość w mm", value: isDlugoscAsSzerokosc ? $searchDlugosc : $searchSzerokosc, formatter: NumberFormatter())
                    }
                    HStack {
                        Text("Grubość")
                            .frame(width: 100, alignment: .leading)
                        Divider()
                        TextField("Podaj grubość w mm", value: $searchGrubosc, formatter: NumberFormatter())
                    }
                    HStack {
                        Text("Ilość")
                            .frame(width: 100, alignment: .leading)
                        Divider()
                        TextField("Podaj ilość w sztukach", value: $searchIlosc, formatter: NumberFormatter())
                    }
                    HStack {
                        Text("Pila")
                            .frame(width: 100, alignment: .leading)
                        Divider()
                        TextField("Podaj szerokość pily w mm", value: $szerokoscPily, formatter: NumberFormatter())
                        
                        Button(action: {
                            clearFields()
                        }) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
            }
            Section{
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Wyszukaj Dekor", text: $searchKolor)
                    Picker("", selection: $searchSelectedColor) {
                        ForEach(filteredDekors, id: \.id) { kolor in
                            Text(kolor.name).tag(kolor.name)
                        }
                    }
                    .id(UUID())
                    .pickerStyle(MenuPickerStyle())
                }
            }
            Section(header: Text("Wyniki wyszukiwania")) {
                ForEach(mostEfficientComponents, id: \.id) { task in
                    NavigationLink(value: task) {
                        HStack {
                            Image(systemName: "rectangle.3.offgrid")
                                .font(Font.title2)
                                .foregroundColor(task.uwagi.isEmpty ? .blue : .red)
                            VStack(alignment: .leading) {
                                Text("\(task.dlugosc) X \(task.szerokosc) X \(task.grubosc) - \(task.ilosc) - \(task.kolor)")
                                    .foregroundColor(task.uwagi.isEmpty ? .black : .red)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("D/C: \(task.dateCreated, formatter: myAppVM.formatDate)")
                                UpdateDateView(inputDate: task.lastUpdated)
                            }
                            .font(Font.system(size: 10))
                            .foregroundColor(Color.gray)
                        }
                    }
                }
                .onDelete(perform: addToTask(at:))
            }
            
        }
    }

    private var filteredDekors: [Dekor] {
        if searchKolor.isEmpty {
            return myAppVM.allDekors
        } else {
            return myAppVM.allDekors.filter { $0.name.localizedCaseInsensitiveContains(searchKolor) }
        }
    }
    private var filteredComponents: [Komponent] {
        let matchingComponents = myAppVM.allKomponents.filter { component in
            let lengthToCheck = isDlugoscAsSzerokosc ? searchSzerokosc : searchDlugosc
            let widthToCheck = isDlugoscAsSzerokosc ? searchDlugosc : searchSzerokosc
            let adjustedSawWidth = szerokoscPily * 2

            return component.dlugosc >= lengthToCheck + adjustedSawWidth &&
                   component.szerokosc >= widthToCheck + adjustedSawWidth &&
                   component.grubosc == searchGrubosc &&
                   component.kolor == searchSelectedColor &&
                   component.text == selectedMaterial
        }
        if matchingComponents.isEmpty {
        }
        return matchingComponents
    }

    func addToTask(at offsets: IndexSet) {
        let addToTask: [Komponent] = offsets.compactMap { index in
            guard index < mostEfficientComponents.count else { return nil }
            return mostEfficientComponents[index]
        }

        addToTask.forEach { task in
            myAppVM.addKomponentToTaskList(selectedKomponent: task, searchDlugosc: searchDlugosc, searchSzerokosc: searchSzerokosc, searchGrubosc: searchGrubosc, searchKolor: searchSelectedColor, szerokoscPily: szerokoscPily)
            if searchIlosc > 0 {
                searchIlosc -= 1
            }
            if searchIlosc == 0 {
                clearFields()
            }
        }
    }
    private var mostEfficientComponents: [Komponent] {
        guard !filteredComponents.isEmpty else {
            return []
        }
        let searchedSurfaceArea = (searchDlugosc + szerokoscPily * 2) * (searchSzerokosc + szerokoscPily * 2)
        let sortedComponents = filteredComponents.sorted { component1, component2 in
            let surfaceArea1 = component1.dlugosc * component1.szerokosc
            let surfaceArea2 = component2.dlugosc * component2.szerokosc
            return surfaceArea1 <= surfaceArea2
        }
        let numberOfEfficientComponents = min(searchIlosc, sortedComponents.count)
        return Array(sortedComponents.prefix(numberOfEfficientComponents))
    }
    func clearFields() {
        searchDlugosc = 0
        searchSzerokosc = 0
        searchGrubosc = 0
        searchKolor = ""
        isDlugoscAsSzerokosc = false
        searchSelectedColor = ""
        szerokoscPily = 3
        searchIlosc = 1
    }
}

struct SearchKomponentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchKomponentView()
    }
}
