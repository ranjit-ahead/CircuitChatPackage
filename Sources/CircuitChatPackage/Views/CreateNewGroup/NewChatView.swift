//
//  NewChatView.swift
//  Chat
//
//  Created by Apple on 18/09/23.
//

import SwiftUI

struct NewChatView: View {
    
    var apiRequest: ApiRequest
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var newChatNavigation: NewChatNavigation
    
    @Binding var currentChatSelected: Chat?
    
    @StateObject private var observed = Observed()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            if let menu = observed.apiResponse?.menu {
                VStack {
                    ScrollViewReader { scrollViewProxy in
//                        HStack {
                            List {
                                //MARK: Create a Group
                                Section {
                                    HStack {
                                        ImageDownloader(observed.apiResponse?.menu.createGroup?.icon)
                                            .viewIconModifier(imageSize: 24, iconSize: 46, iconColor: Color(UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)))
                                        Text(observed.apiResponse?.menu.createGroup?.label ?? "")
                                            .font(.semiBoldFont(15))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.2)
                                        NavigationLink(destination: AddMembersView(apiRequest: ApiRequest(apiURL: observed.apiResponse?.menu.createGroup?.apiURL, method: observed.apiResponse?.menu.createGroup?.apiMethod), forwardMode: .constant(.inactive))) {
                                            EmptyView()
                                        }.opacity(0)
                                        Button(action: {
                                            
                                        }){
                                            Image(systemName: "chevron.right")
                                                .frame(width: 10, height: 10)
                                                .foregroundColor(Color(UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1)))
                                        }
                                    }
                                }
                                
                                //MARK: Frequently Contacted
                                if let array = observed.frequentlyContactedArray, array.count>0 {
                                    Section(header: Text(menu.frequentlyContacted?.id ?? "").textCase(nil)) {
                                        ForEach(array) { item in
                                            viewForChatArray(item)
                                        }
                                    }
                                }
                                
                                //MARK: Chats
                                if let array = observed.chatArray, array.count>0 {
                                    ForEach(array) { array in
                                        Section(header: Text(array.id)) {
                                            ForEach(array.results) { item in
                                                viewForChatArray(item)
                                            }
                                        }
                                    }
                                }
                            }
//                            .listStyle(.grouped)
                            .searchable(text: $searchText, prompt: menu.search?.label ?? "")
                            .overlay(alignment: .trailing) {
                                VStack {
                                    if let array = observed.chatArray {
                                        ForEach(array) { section in
                                            Button(section.id) {
                                                scrollViewProxy.scrollTo(section.id, anchor: .top)
                                            }
                                        }
                                    }
                                }
                            }
//                            VStack {
//                                if let array = observed.chatArray {
//                                    ForEach(array) { section in
//                                        Button(section.id) {
//                                            scrollViewProxy.scrollTo(section.id, anchor: .top)
//                                        }
//                                    }
//                                }
//                            }
//                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            //                            Image(systemName: "plus")
                            //                                .resizable()
                            //                                .frame(width: 20, height: 20)
                            //                                .rotationEffect(.degrees(45))
                            //                                .foregroundColor(Color(uiColor: UIColor(red: 0.64, green: 0.64, blue: 0.64, alpha: 1)))
                            ImageDownloader(menu.closeIcon)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(uiColor: UIColor(red: 0.64, green: 0.64, blue: 0.64, alpha: 1)))
                        }
                    }
                    ToolbarItem(placement: .principal) { // <3>
                        Text(menu.navigationTitle ?? "")
                            .font(.semiBoldFont(22))
                    }
                }
            }
        }
        .onAppear {
            observed.fetchApiData(apiRequest: apiRequest)
        }
    }
    
    @ViewBuilder
    func viewForChatArray(_ item: Chat) -> some View {
        HStack {
            
            //Image
            ZStack(alignment: .bottomTrailing) {
                
                ImageDownloader(item.avatar)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 46, height: 46)
                    .clipShape(Circle())
                
                if item.active ?? false {
                    Circle()
                        .strokeBorder(Color(UIColor.systemBackground), lineWidth: 1.5)
                        .background(Circle().fill(.green))
                        .frame(width: 13, height: 13)
                }
            }
            
            //Text
            VStack(alignment: .leading) {
                ChatName(name: item.name, font: .semiBoldFont(15), verified: item.verified, iconSize: 19)
                    .padding(.top, 8.5)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            newChatNavigation.showSheet.toggle()
            currentChatSelected = item
        })
    }
}

//struct NewChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewChatView(apiRequest: )
//    }
//}
