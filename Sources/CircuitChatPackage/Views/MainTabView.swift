//
//  MainTabView.swift
//  Chat
//
//  Created by Apple on 19/08/23.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var socketIO: CircuitChatSocketManager

    
    @State private var selection = 0
    
    @State private var chatTabCount: Int?
    
    var body: some View {
        TabView(selection: $selection) {
            if observed.apiResponse == nil {
                ProgressView()
            } else {
                if let tabBar = observed.apiResponse?.menu.tabBar {
                    ForEach(tabBar) { data in
                        tabViewForData(data)
                    }
                }
            }
        }
        .onAppear {
            
            // correct the transparency bug for Tab bars
            //            let tabBarAppearance = UITabBarAppearance()
            ////            tabBarAppearance.configureWithOpaqueBackground()
            //            tabBarAppearance.backgroundColor = .white.withAlphaComponent(0.5)
            //            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            //            // correct the transparency bug for Navigation bars
            //            let navigationBarAppearance = UINavigationBarAppearance()
            //            navigationBarAppearance.configureWithOpaqueBackground()
            //            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            
        }
        
        //UnreadChat count
        .onChange(of: socketIO.unreadCount, perform: { chatResponse in
            if let count = chatResponse?.unread_count {
                chatTabCount = count
            }
        })
    }
    
    @ViewBuilder
    func tabViewForData(_ data: FetchResponse) -> some View {
        if data.id == "stories" {
            StoriesView()
                .tabItem {
                    VStack {
                        Image("stories").renderingMode(.template)
                        Text(data.label ?? "")
                    }
                }
                .tag(1)
        } else if data.id == "call" {
            CallsView()
                .tabItem {
                    VStack {
                        Image("call").renderingMode(.template)
                        Text(data.label ?? "")
                    }
                }
                .tag(2)
        } else if data.id == "chat" {
            ChatView(apiRequest: ApiRequest(apiURL: data.apiURL, method: data.apiMethod))
            .tabItem {
                VStack {
                    Image(selection == 0 ? "chatfill" : "chat").renderingMode(.template)
                    Text(data.label ?? "")
                }
            }
            .tag(0)
            .badge(chatTabCount ?? data.count ?? 0)
        } else if data.id == "setting" {
            SettingsView()
                .tabItem {
                    VStack {
                        Image("setting").renderingMode(.template)
                        Text(data.label ?? "")
                    }
                }
                .tag(3)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

final class NewChatNavigation: ObservableObject {
    @Published var showSheet = false
}

//____________________________________________________________________________________________________________________________


