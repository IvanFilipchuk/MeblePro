//
//  TaskView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 01/12/2023.
//


import SwiftUI

struct TaskView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @Environment(\.dismiss) var dismiss
    @State var taskText = ""
    @State var taskDlugosc: Int = 0
    @State var taskSzerokosc: Int = 0
    @State var taskGrubosc: Int = 0
    @State var taskIlosc: Int = 0
    @State var taskJednostka = ""
    @State var taskKolor = ""
    @State var taskUwagi = ""
    @State var searchDlugosc: Int = 0
    @State var searchSzerokosc: Int = 0
    @State var searchGrubosc: Int = 0
    @State var szerokoscPily: Int = 0
    @State var searchKolor = ""
    @State private var isTaskCompleted: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var searchElement: SearchKomponent?

    var body: some View {
        List {
            Section{
                HStack {
                    Text("Materiał")
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    Text("\(taskText)")
                }
                HStack {
                    Text("Jednostka wymiarowa")
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    Text("\(taskJednostka)")
                }
                HStack {
                    Text("Pila")
                        .frame(width: 100, alignment: .leading)
                    Divider()
                    Text("\(szerokoscPily)")
                }
                
            }
            Section {
                HStack {
                    Text("Długość")
                        .frame(width: 100, alignment: .leading)
                        .foregroundColor(.blue)
                    Divider()
                    Text("\(taskDlugosc)")
                        .foregroundColor(.blue)
                }
                HStack {
                    Text("Szerokość")
                        .frame(width: 100, alignment: .leading)
                        .foregroundColor(.blue)
                    Divider()
                    Text("\(taskSzerokosc)")
                        .foregroundColor(.blue)
                }
                HStack {
                    Text("Grubość")
                        .frame(width: 100, alignment: .leading)
                        .foregroundColor(.blue)
                    Divider()
                    Text("\(taskGrubosc)")
                        .foregroundColor(.blue)
                }
                HStack {
                    Text("Dekor")
                        .frame(width: 100, alignment: .leading)
                        .foregroundColor(.blue)
                    Divider()
                    Text("\(taskKolor)")
                    .foregroundColor(.blue)
                }
                if !taskUwagi.isEmpty {
                    HStack {
                        Text("Uwagi")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.blue)
                        Divider()
                        Text("\(taskUwagi)")
                            .foregroundColor(.blue)
                    }
                }
            } header: {
                Text("Dane istniejącego komponentu")
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.blue)
            }
            
            Section {
                Section {
                    HStack {
                        Text("Długość")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.red)
                        Divider()
                        Text("\(searchDlugosc)")
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Szerokość")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.red)
                        Divider()
                        Text("\(searchSzerokosc)")
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Grubość")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.red)
                        Divider()
                        Text("\(searchGrubosc)")
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Dekor")
                            .frame(width: 100, alignment: .leading)
                            .foregroundColor(.red)
                        Divider()
                        Text("\(taskKolor)")
                            .foregroundColor(.red)
                    }
                }
            } header: {
                Text("Dane wyszukiwanego komponentu")
                    .multilineTextAlignment(.leading)
             
                    .foregroundColor(.red)
            }

            let baseWidth: CGFloat = 300
            let baseHeight: CGFloat = 300

            let widthRatio = CGFloat(searchDlugosc) / CGFloat(taskDlugosc)
            let heightRatio = CGFloat(searchSzerokosc) / CGFloat(taskSzerokosc)

            let scaleFactor = min(baseWidth / CGFloat(taskDlugosc), baseHeight / CGFloat(taskSzerokosc), 1.0)

            let scaledTaskWidth = max(min(baseWidth, CGFloat(taskDlugosc) * scaleFactor), baseWidth / 3)
            let scaledTaskHeight = max(min(baseHeight, CGFloat(taskSzerokosc) * scaleFactor), baseHeight / 3)

            let scaledSearchWidth = max(min(baseWidth, CGFloat(searchDlugosc) * scaleFactor), baseWidth / 3)
            let scaledSearchHeight = max(min(baseHeight, CGFloat(searchSzerokosc) * scaleFactor), baseHeight / 3)

            ZStack {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: scaledTaskWidth, height: scaledTaskHeight)
                    .border(Color .black)
                
                Rectangle()
                    .fill(Color.red)
                    .border(Color .black)
                    .frame(width: scaledSearchWidth, height: scaledSearchHeight)
                    .offset(
                        x: (scaledSearchWidth - scaledTaskWidth) / 2,
                        y: (scaledSearchHeight - scaledTaskHeight) / 2
                    )
            }
            Section {
                if !(searchElement?.isCompleted ?? false) {
                    Button(action: {
                        if let searchElement = searchElement {
                            myAppVM.updateTasksStatus(selectedTask: searchElement)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Zrealizowane")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            
        }
        .navigationTitle("Zadanie")
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        TaskView()
    }
}
