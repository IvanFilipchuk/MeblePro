//
//  TasksListView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 01/12/2023.
//

import SwiftUI

struct TasksListView: View {
    @EnvironmentObject var myAppVM: MyAppViewModel
    @State private var selectedStatus = TaskStatus.all

    var filteredTasks: [SearchKomponent] {
        switch selectedStatus {
        case .all:
            return myAppVM.allSearchKomponents
        case .inProgress:
            return myAppVM.allSearchKomponents.filter { !$0.isCompleted }
        case .completed:
            return myAppVM.allSearchKomponents.filter { $0.isCompleted }
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Lista zadań")) {
                Picker("Status", selection: $selectedStatus) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Text(status.rawValue.capitalized).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                ForEach(filteredTasks, id: \.id) { task in
                    NavigationLink(value: task) {
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(Font.title2)
                                .foregroundColor(task.isCompleted ? .green : .blue)
                            VStack(alignment: .leading) {
                                Text("\(task.searchDlugosc) X \(task.searchSzerokosc) X \(task.searchGrubosc) - \(task.searchKolor) ")
                            }
                            Spacer()
                                .foregroundColor(Color.gray)
                        }

                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("D/C: \(task.dateCreated, formatter: myAppVM.formatDate)")
                        }
                        .font(Font.system(size: 10))
                        .foregroundColor(Color.gray)
                    }
                }
            }
        }
    }
}

struct TasksListView_Previews: PreviewProvider {
    static var previews: some View {
        TasksListView()
    }
}

enum TaskStatus: String, CaseIterable {
    case all = "Wszystkie"
    case inProgress = "W trakcie"
    case completed = "Zrealizowane"
}
