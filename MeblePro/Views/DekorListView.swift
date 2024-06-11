//
//  DekorListView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 01/11/2023.
//

import SwiftUI

struct DekorListView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State private var dekorName = ""
    @State private var dekorKodname = ""
    
    var body: some View {
        Form {
            Section {
                TextFieldV02 (value: $dekorName, placeholder: "Nazwa dekoru")
                TextFieldV02(value: $dekorKodname, placeholder: "Kod dekoru")
                Button {
                    myAppVM.addNewDekor(dekorName: dekorName, dekorKodname: dekorKodname)
                    dekorName = ""
                    dekorKodname = ""
                } label: {
                    Text("Dodaj nowy dekor")
                }
            } header: {
                Text("Dodaj nowy dekor")
            }
            
            Section {
                ForEach(myAppVM.allDekors, id: \.id) { dekor in
                    NavigationLink(value: dekor) {
                        HStack {
                                Image(systemName: "paintpalette")
                                    .font(Font.title2)
                                    .foregroundColor(.blue)
                               
                            VStack(alignment: .leading) {
                                 
                                Text("\(dekor.name) - \(dekor.kodname)")
                                  
                                
                            }
                            Spacer()
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                .onDelete(perform: deleteKolor(at:))
            } header: {
                Text("Lista Dekorów")
            }
            
        }
        .navigationTitle("Lista Dekorów")
    }

    func deleteKolor(at offsets: IndexSet) {
        let selectedDekor = offsets.map { index in
            self.myAppVM.allDekors[index]
        }
        if selectedDekor.count == 1 {
            myAppVM.deleteDekor(selectedDekors: selectedDekor[0])
        }
    }
}
struct DekorListView_Previews: PreviewProvider {
    static var previews: some View {
        DekorListView()
    }
}
