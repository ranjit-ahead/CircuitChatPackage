//
//  ChatList.swift
//  Chat
//
//  Created by Apple on 29/09/23.
//

import SwiftUI

//struct ChatList: View {
//    
//    var apiRequest: ApiRequest
//    
//    @Environment(\.editMode) private var editMode
//    
//    @EnvironmentObject var observed: ChatListViewObserved
//    @EnvironmentObject var menus: FetchMenus
//    
//    @State private var showingGroupPasswordAccess = false
//    @State private var chatSelected: LastChatData?
//    @State private var passwordSuccess = false
//    @State private var passwordText = ""
//    
//    @State private var selectedIndexes: Set<LastChatData> = []
//    
//    @State private var showMoreOptions = false
//    
//    @State private var mode: EditMode = .inactive //< -- Here
//    
//    private func toggleSelection(for index: LastChatData) {
//        if selectedIndexes.contains(index) {
//            selectedIndexes.remove(index)
//        } else {
//            selectedIndexes.insert(index)
//        }
//    }
//    
//    @State private var showEditingOptions = false
//    
//    @State private var showProfilePage = false
//    
//    //MARK: Main Body
//    var body: some View {
//        NavigationStack {
//            if let data = observed.apiResponse?.menu.chats {
//                List {
//                    Section(header:
//                                VStack {
//                        if observed.archived {
//                            HStack {
//                                Spacer()
//                                Text((mode == .inactive) ? (observed.apiResponse?.menu.editDescription ?? "") : (observed.apiResponse?.menu.doneDescription ?? ""))
//                                    .font(.regularFont(14))
//                                    .multilineTextAlignment(.center)
//                                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
//                                Spacer()
//                            }.textCase(nil)
//                        } else {
//                            VStack {
//                                if let activeUserResponse = observed.activeUserResponse {
//                                    ScrollView(.horizontal, showsIndicators: false) {
//                                        HStack {
//                                            ForEach(activeUserResponse.data, id: \.id) { item in
//                                                OnlineMembers(userImage: item.avatar ?? nil, userName: item.name, isVerified: item.verified ?? false)
//                                                    .padding(.horizontal, 6)
//                                            }
//                                        }
//                                    }
//                                    .textCase(nil) //Handle Auto Capitalize
//                                    .frame(height: activeUserResponse.data.count>0 ? 100 : 0)
//                                }
//                            }.padding(.horizontal, -13)
//                        }
//                    }
//                    ) {
//                        if !observed.archived {
//                            if let archived = observed.apiResponse?.menu.archived {
//                                NavigationLink(destination: ArchivedView(apiRequest: apiRequest).toolbar(.hidden, for: .tabBar), label: {
//                                    HStack {
//                                        ImageDownloader(archived.icon, renderMode: .template)
//                                            .frame(width: 28, height: 28)
//                                        Text(archived.label ?? "")
//                                            .font(.semiBoldFont(17))
//                                        Spacer()
//                                    }
//                                })
//                            }
//                        }
//                        ForEach(data, id: \.id) { item in
//                            ChatItem(item: item, editMode: $mode)
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    if mode == .active {
//                                        if let index = data.firstIndex(of: item) {
//                                            observed.apiResponse?.menu.chats[index].isSelected = !(item.isSelected ?? false)
//                                            showEditingOptions.toggle()
//                                        }
//                                    } else {
//                                        chatSelected = item
//                                        DispatchQueue.main.async {
//                                            if !(item.chat.protected ?? false) || passwordSuccess {
//                                                toggleSelection(for: item)
//                                            } else {
//                                                showingGroupPasswordAccess.toggle()
//                                            }
//                                        }
//                                    }
//                                }
//                                .navigationDestination(isPresented: $showProfilePage, destination: {
//                                    if let chatSelected = chatSelected {
//                                        if chatSelected.chat.chatType=="user"  {
//                                            UserInfo(id: chatSelected.id).toolbarRole(.editor)
//                                        } else {
//                                            GroupInfo(userDetails: chatSelected).toolbarRole(.editor)
//                                        }
//                                    }
//                                })
//                                .navigationDestination(isPresented: Binding<Bool>( get: { selectedIndexes.contains(item) },
//                                                                                   set: { newValue in
//                                    if newValue {
//                                        selectedIndexes.insert(item)
//                                    } else {
//                                        selectedIndexes.remove(item)
//                                    }
//                                    if let index = data.firstIndex(of: item) {
//                                        observed.apiResponse?.menu.chats[index].unread = 0
//                                    }
//                                })) {
//                                    UserChatDetail(userDetails: item, password: passwordText)
//                                        .toolbar(.hidden, for: .tabBar)
//                                        .toolbarRole(.editor)
//                                }
//                                .onAppear {
//                                    passwordSuccess = false
//                                    Task {
//                                        if observed.hasReachedEnd(of: item, array: data) {
//                                            observed.fetchApiData(apiRequest: apiRequest)
//                                        }
//                                    }
//                                }
//                                .swipeActions {
//                                    if let swipeOptions = observed.apiResponse?.menu.swipeOptions {
//                                        ForEach(swipeOptions.reversed()) { swipeOption in
//                                            swipeOptionView(swipeOption, item: item)
//                                        }
//                                    }
//                                }
//                        }
//                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                    }
//                    .listSectionSeparator(.hidden)
//                    .listRowBackground(Color.clear)
//                }
//                .refreshable {
//                    observed.apiResponse = nil
//                    observed.pageCount = 1
//                    observed.fetchApiData(apiRequest: apiRequest)
//                }
//                .toolbar {
//                    EditButton()
//                        .font(.semiBoldFont(13))
//                        .background(Color(.systemGray6))
//                        .cornerRadius(30)
//                        .onTapGesture {
//                            showEditingOptions.toggle()
//                        }
//                }
//                .environment(\.editMode, $mode)
//                .scrollContentBackground(.hidden)
//                .listStyle(.grouped)
//                .onAppear {
//                    observed.fetchOnlineMembers()
//                }
//                .fullScreenCover(isPresented: $showMoreOptions, content: {
//                    chatCustomDialog
//                })
//                .toolbar(mode == .active ? .hidden : .visible, for: .tabBar)
//            }
//            if showingGroupPasswordAccess {
//                VStack {}
//                    .fullScreenCover(isPresented: $showingGroupPasswordAccess, content: {
//                        GroupPasswordAccess(chatSelected: chatSelected!, itemObserved: observed, showingGroupPasswordAccess: $showingGroupPasswordAccess, passwordIsCorrect: $passwordSuccess, passwordText: $passwordText)
//                    })
//                    .onAppear {
//                        UIView.setAnimationsEnabled(false)
//                    }
//            }
//            if mode == .active {
//                HStack {
//                    
//                    if let footer = observed.apiResponse?.menu.footer {
//                        ForEach(footer) { footer in
//                            footerView(footer)
//                        }
//                    }
//                }
//                .padding()
//                .background(.ultraThinMaterial)
//                .overlay(Rectangle().frame(width: nil, height: 0.2).foregroundColor(Color.gray), alignment: .top)
//                //.shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -5)
//                .onAppear {
//                    UIView.setAnimationsEnabled(false)
//                }
//            }
//        }.navigationBarTitle(observed.apiResponse?.menu.navigationTitle ?? "")
//    }
//    
//    @ViewBuilder
//    func footerView(_ footer: FetchResponse) -> some View {
//        if let data = observed.apiResponse?.menu.chats {
//            let indexArray = data.filter{ $0.isSelected ?? false }.map{ observed.apiResponse?.menu.chats.firstIndex(of: $0) ?? 0 }
//            
//            if footer.id=="archive" || footer.id=="unarchive" { //ARCHIVE BUTTON
//                Button {
//                    let chatIDs = data.filter{ $0.isSelected ?? false }.map{ $0.id }
//                    observed.archiveChat(chatIds: chatIDs)
//                    
//                    mode.toggle()
//                    for index in indexArray {
//                        observed.apiResponse?.menu.chats[index].isSelected = false
//                    }
//                } label: {
//                    Text(footer.label ?? "")
//                }.disabled(indexArray.count > 0 ? false : true)
//                
//                Spacer()
//            } else if footer.id=="read" { //READ ALL BUTTON
//                Button {
//                    
//                } label: {
//                    Text(indexArray.count>0 ? (footer.label ?? "") : (footer.labelSelected ?? ""))
//                }
//                Spacer()
//            } else if footer.id=="delete" { //DELETE BUTTON
//                Button {
//                    let chatIDs = data.filter{ $0.isSelected ?? false }.map{ data in
//                        return ChatIDAndType(id: data.id, chatType: (data.chat.chatType ?? "user"))
//                    }
//                    observed.deleteConversation(chatIds: chatIDs)
//                    
//                    mode.toggle()
//                    for index in indexArray {
//                        observed.apiResponse?.menu.chats[index].isSelected = false
//                    }
//                } label: {
//                    Text(footer.label ?? "")
//                }.disabled(indexArray.count > 0 ? false : true)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    func swipeOptionView(_ swipeOption: FetchResponse, item: LastChatData) -> some View {
//        if swipeOption.id=="archive" {
//            Button {
//                observed.archiveChat(chatIds: [item.id])
//            } label: {
//                //observed.archived ? "Unarchive" : "Archive"
//                Label(swipeOption.label ?? "", systemImage: "archivebox.fill")
//                    .font(.regularFont(12))
//                //                                            Label(title: {
//                //                                                Text(archive.label ?? "")
//                //                                            }, icon: {
//                //                                                if let image = archive.icon {
//                //                                                    ImageFetch(image)
//                //                                                }
//                //                                                }
//                //                                            }).font(.regularFont(12))
//            }
//            .tint(Color.purple)
//        } else if swipeOption.id=="pin" {
//            if !observed.archived {
//                Button {
//                    observed.pinChat(chat: item)
//                } label: {
//                    Label((item.pin ?? false) ? (swipeOption.labelSelected ?? "") : (swipeOption.label ?? ""), systemImage: (item.pin ?? false) ? "pin.slash" : "pin")
//                        .font(.regularFont(12))
//                }
//                .tint(Color.blue)
//            }
//        } else if swipeOption.id=="more" {
//            Button {
//                chatSelected = item
//                showMoreOptions.toggle()
//                
//            } label: {
//                Label(swipeOption.label ?? "", systemImage: "ellipsis.message.fill")
//                    .font(.regularFont(12))
//            }
//            .tint(Color(uiColor: .systemGray3))
//        }
//    }
//    
//    var chatCustomDialog: some View {
//        CustomDialog(isPresented: $showMoreOptions, bodyContent: {
//            VStack {
//                if let moreMenus = observed.moreMenus?.menu {
//                    ForEach(moreMenus) { moreMenu in
//                        if moreMenu.id=="profile" {
//                            Button {
//                                showMoreOptions.toggle()
//                                showProfilePage.toggle()
//                            } label: {
//                                HStack {
//                                    ImageDownloader(moreMenu.icon, renderMode: .template)
//                                        .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
//                                    Text(moreMenu.label ?? "")
//                                    Spacer()
//                                }.foregroundColor(Color(.label))
//                            }
//                        } else if moreMenu.id=="read" {
//                            Button {
//                                showMoreOptions.toggle()
//                            } label: {
//                                HStack {
//                                    ImageDownloader(moreMenu.icon, renderMode: .template)
//                                        .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
//                                    Text(moreMenu.label ?? "")
//                                    Spacer()
//                                }.foregroundColor(Color(.label))
//                            }
//                        } else if moreMenu.id=="mute" {
//                            Button {
//                                if let chatSelected = chatSelected {
//                                    observed.muteChatNotifications(chat: chatSelected)
//                                }
//                                showMoreOptions.toggle()
//                            } label: {
//                                HStack {
//                                    ImageDownloader(moreMenu.icon, renderMode: .template)
//                                        .viewIconModifier(imageSize: 18, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
//                                    Text(moreMenu.label ?? "")
//                                    Spacer()
//                                }.foregroundColor(Color(.label))
//                            }
//                        } else if moreMenu.id=="report" {
//                            Button {
//                                showMoreOptions.toggle()
//                            } label: {
//                                HStack {
//                                    ImageDownloader(moreMenu.icon, renderMode: .template)
//                                        .viewIconModifier(imageSize: 22, iconSize: 32, imageColor: Color(.label), iconColor: Color(.systemGray5))
//                                    Text(moreMenu.label ?? "")
//                                    Spacer()
//                                }.foregroundColor(Color(.label))
//                            }
//                        } else if moreMenu.id=="delete" {
//                            Button {
//                                showMoreOptions.toggle()
//                            } label: {
//                                HStack {
//                                    ImageDownloader(moreMenu.icon)
//                                        .frame(width: 32, height: 32)
//                                    Text(moreMenu.label ?? "")
//                                        .foregroundColor(.red)
//                                    Spacer()
//                                }.foregroundColor(Color(.label))
//                            }
//                        } else if moreMenu.id=="block" {
//                            Button {
//                                showMoreOptions.toggle()
//                            } label: {
//                                HStack {
//                                    ImageDownloader(moreMenu.icon)
//                                        .frame(width: 32, height: 32)
//                                    Text(moreMenu.label ?? "")
//                                        .foregroundColor(.red)
//                                    Spacer()
//                                }.foregroundColor(Color(.label))
//                            }
//                        }
//                        if let index = moreMenus.firstIndex(of: moreMenu) {
//                            if index != moreMenus.count-1 && index != moreMenus.count-2 {
//                                Divider()
//                            }
//                        }
//                    }
//                }
//            }
//            .accentColor(.black)
//            .padding()
//        }, cancelContent: {
//            VStack {
//                let moreMenus = observed.moreMenus?.menu
//                if let moreMenu = moreMenus?.filter({ $0.id=="cancel" }) {
//                    if let cancelMenu = moreMenu.first {
//                        Button {
//                            showMoreOptions.toggle()
//                        } label: {
//                            HStack {
//                                Spacer()
//                                Text(cancelMenu.label ?? "")
//                                    .font(.semiBoldFont(16))
//                                Spacer()
//                            }
//                            .foregroundColor(Color(.label))
//                            .accentColor(.black)
//                            .padding()
//                            .background(Color(.tertiarySystemBackground))
//                            .frame(height: 53)
//                        }.background(Color(.tertiarySystemBackground)).cornerRadius(10)
//                    }
//                }
//            }
//        })
//        .background(BackgroundBlurView())
//        .background { Color.black.opacity(0.25).edgesIgnoringSafeArea(.all) }
//        .onAppear {
//            if let chatSelected = chatSelected {
//                observed.fetchChatMenus(chat: chatSelected, apiRequest: apiRequest)
//            }
//            //UIView.setAnimationsEnabled(false)
//        }
//        .onDisappear {
//            observed.moreMenus = nil
//        }
//    }
//    
//}

//struct ChatList_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatList()
//    }
//}
