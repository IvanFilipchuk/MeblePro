//
//  TabBarView.swift
//  MeblePro
//
//  Created by Іван Філіпчук on 27/10/2023.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab = 0
    @EnvironmentObject var myAppVM: MyAppViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                AddKomponentView()
                    .navigationBarItems(
                        trailing: NavigationLink(destination: DekorListView()) {
                            Image(systemName: "paintbrush")
                                .foregroundColor(.blue)
                        }
                    )
            }
            .tabItem {
                Image(systemName: "square.and.pencil")
            }
            .tag(0)
            NavigationView{
            KomponentsListView()
                .navigationBarItems(
                    trailing: NavigationLink(destination: DeleteKomponentListView()) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.blue)
                    }
                )
            }
                .tabItem {
                    Image(systemName: "rectangle.stack")
                }
                .tag(1)
            SearchKomponentView()
                .tabItem {
                    Image(systemName: "doc.text.magnifyingglass")
                }
                .tag(2)
           TasksListView()
                .tabItem {
                    Image(systemName: "text.book.closed.fill")
                }
                .tag(3)
            UserView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                }
                .tag(4)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
