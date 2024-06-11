//
//  DeleteKomponentListView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 01/12/2023.
//

import SwiftUI

struct DeleteKomponentListView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State private var isRestoring = false
    @State private var selectedRestoreIndexSet: IndexSet?
    @State private var isClearingTrash = false

    var body: some View {
        Form {
            Section(header: Text("Kosz")) {
                if myAppVM.allDeletedKomponents.isEmpty {
                    HStack {
                        Spacer()
                        Image(systemName: "trash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .padding(.vertical, 50)
                        Spacer()
                    }
                } else {
                    ForEach(myAppVM.allDeletedKomponents, id: \.id) { komponent in
                        NavigationLink(value: komponent) {
                            HStack {
                                Image(systemName: "xmark.bin.fill")
                                    .font(Font.title2)
                                    .foregroundColor(.red)

                                VStack(alignment: .leading) {
                                    Text("\(komponent.dlugosc) X \(komponent.szerokosc) X \(komponent.grubosc) - \(komponent.kolor) ")
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text("Data utworzenia: \(komponent.dateCreated, formatter: myAppVM.formatDate)")
                                        .font(Font.system(size: 10))
                                        .foregroundColor(Color.gray)
                                }
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                isRestoring.toggle()
                                selectedRestoreIndexSet = IndexSet([myAppVM.allDeletedKomponents.firstIndex(of: komponent)].compactMap { $0 })
                            } label: {
                                Label("Przywróć", systemImage: "arrow.uturn.left.circle")
                            }
                            .tint(.green)
                        }
                    }
                    .onDelete(perform: deleteDeletedKomponent(at:))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isClearingTrash.toggle()
                }) {
                    if myAppVM.allDeletedKomponents.isEmpty {
                        Image(systemName: "trash")
                    } else {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                }
                .actionSheet(isPresented: $isClearingTrash) {
                    ActionSheet(
                        title: Text("Wyczyść Kosz"),
                        message: Text("Czy na pewno chcesz usunąć wszystkie elementy z kosza?"),
                        buttons: [
                            .destructive(Text("Usuń wszystko"), action: {
                                clearTrash()
                            }),
                            .cancel(Text("Anuluj"))
                        ]
                    )
                }
            }
        }
        .actionSheet(isPresented: $isRestoring) {
            ActionSheet(
                title: Text("Przywróć Komponet"),
                buttons: [
                    .destructive(Text("Przywróć"), action: {
                        if let indexSet = selectedRestoreIndexSet {
                            restoreKomponent(at: indexSet)
                        }
                    }),
                    .cancel(Text("Anuluj"))
                ]
            )
        }
    }

    func deleteDeletedKomponent(at offsets: IndexSet) {
        let selectedKolor = offsets.map { index in
            self.myAppVM.allDeletedKomponents[index]
        }

        if selectedKolor.count == 1 {
            myAppVM.deleteDeletedKomponent(selectedDeletedKomponent: selectedKolor[0])
        }
    }

    func restoreKomponent(at offsets: IndexSet) {
        guard let firstIndex = offsets.first, firstIndex < myAppVM.allDeletedKomponents.count else {
            return
        }

        let selectedKomponentToRestore = myAppVM.allDeletedKomponents[firstIndex]
        myAppVM.restoreKomponentFromTrash(removedKomponent: selectedKomponentToRestore)
    }

    func clearTrash() {
        myAppVM.deleteAllDeletedKomponents()
    }
}

struct DeleteKomponentListView_Previews: PreviewProvider {
     static var previews: some View {
         DeleteKomponentListView()
     }
 }
