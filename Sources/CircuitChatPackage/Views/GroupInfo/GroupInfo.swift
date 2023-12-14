//
//  GroupInfo.swift
//  Chat
//
//  Created by Apple on 30/10/23.
//

import SwiftUI

struct GroupInfo: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var observed = GroupInfoObserved()
    
    @State private var descriptionView: Bool = false
    
    @State private var muteNotifications: Bool = false
    @State private var unMuteNotifications: Bool = false
    
    @State private var clearChatDialogSheet: Bool = false
    @State private var deleteChatDialogSheet: Bool = false
    
    @State private var exitDialogSheet: Bool = false
    
    @State private var reportDialogSheet: Bool = false
    @State private var reportSheet: Bool = false
    @State private var reportAndExitSheet: Bool = false
    
    @State private var deleteGroupDialogSheet: Bool = false
    
    var userDetails: Chat
    
    var body: some View {
        NavigationStack {
            if let id = userDetails.id {
                List {
                    
                    VStack(spacing: 10) {
                        ImageDownloader(observed.data?.avatar)
                            .background {
                                NavigationLink("", destination: ShowImage(url: observed.data?.avatar))
                                                .opacity(0)
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        
                        Text(observed.data?.name ?? "")
                            .font(.semiBoldFont(22))
                            .multilineTextAlignment(.center)
                        Text("Group · \(observed.data?.countMembers ?? 0) Members")
                            .font(.regularFont(15))
                            .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                        HStack {
                            Button {
                                
                            } label: {
                                LazyVStack {
                                    Image("groupCall")
                                        .imageIconModifier(imageSize: 32, iconSize: 32, color: Color.clear)
                                    Text("Call")
                                        .font(.regularFont(15))
                                }
                            }.frame(height: 80)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .clipped()
                            
                            Spacer(minLength: 15)
                            
                            Button {
                                
                            } label: {
                                LazyVStack {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: 22, height: 22)
                                    Text("Search")
                                        .font(.regularFont(15))
                                }
                            }.frame(height: 80)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                                .clipped()
                        }
                    }
                    .padding(.horizontal, -20)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    Section {
                        Button {
                            descriptionView.toggle()
                        } label: {
                            if let metadata = observed.data?.metadata {
                                HStack(spacing: 0) {
                                    ExpandableText(.constant(metadata), lineLimit: 5, font: UIFont(name: "OpenSans-Regular", size: 15)!, color: Color(red: 0.4, green: 0.4, blue: 0.4))
                                        .font(.regularFont(15))
                                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                                    Spacer(minLength: 1)
                                    Image("rightArrow")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                }
                            } else {
                                Text("Add Group Description")
                                    .font(.regularFont(16))
                            }
                        }
                        .sheet(isPresented: $descriptionView) {
                            EditGroupDescription()
                                .presentationDetents([.height(UIScreen.screenHeight*(2/3))])
                        }
                    }
                    
                    Section {
                        NavigationLink(destination: {
                            MediaLinksDocs(userDetails: userDetails).toolbarRole(.editor)
                        }, label: {
                            LazyHStack {
                                Image("mediaLinksDocs")
                                    .imageIconModifier(imageSize: 22, iconSize: 40, color: Color.blue)
                                Text("Media, Links, and Docs")
                                    .font(.regularFont(16))
                            }
                        })
                        NavigationLink(destination: {
                            StarredMessage(chatId: userDetails.id, chatName: userDetails.name, chatType: userDetails.chatType).toolbarRole(.editor)
                        }, label: {
                            LazyHStack {
                                Image("star")
                                    .imageIconModifier(imageSize: 24, iconSize: 40, color: Color.orange)
                                Text("Starred Message")
                            }
                        })
                    }.font(.regularFont(16)).foregroundColor(Color(.label))
                    
                    Section {
//                        let mute = userDetails.mute ?? false
//                        Button {
//                            if mute {
//                                unMuteNotifications.toggle()
//                            } else {
//                                muteNotifications.toggle()
//                            }
//                        } label: {
//                            HStack {
//                                Image(mute ? "mute" : "unmute")
//                                    .imageIconModifier(imageSize: 18, iconSize: 40, imageColor: Color.white, color: mute ? .gray : .green)
//                                Text(mute ? "Muted" : "Mute")
//                                Spacer()
//                                Image("rightArrow")
//                                    .imageIconModifier(imageSize: 17, iconSize: 17, color: Color.clear)
//                            }
//                        }
//                        .confirmationDialog("", isPresented: $unMuteNotifications, titleVisibility: .hidden) {
//                            Button("Unmute") {
//                                observed.muteChatNotifications(chat: userDetails)
//                            }
//                        }
//                        .fullScreenCover(isPresented: $muteNotifications, content: {
//                            ShowCustomDialogSheet(showSheet: $muteNotifications, content: {
//                                VStack(spacing: 30) {
//                                    Text("Mute Notification")
//                                        .font(.semiBoldFont(20))
//                                        .foregroundColor(Color(.label))
//                                    Text("Select the duration for which you want to mute this chat. Once you are muted, you will still be notified if you are mentioned.")
//                                        .font(.regularFont(14))
//                                        .foregroundColor(Color(.label))
//                                        .frame(minWidth: 0, maxWidth: .infinity)
//                                        .multilineTextAlignment(.center)
//
//                                    VStack(alignment:.leading) {
//                                        Button {
//                                            muteNotifications.toggle()
//                                            observed.muteChatNotifications(chat: userDetails, time: 2)
//                                        } label: {
//                                            HStack {
//                                                Text("8 hours")
//                                                    .font(.regularFont(16))
//                                                Spacer()
//                                            }
//                                        }.contentShape(Rectangle())
//                                        HorizontalSeparatorView()
//                                        Button {
//                                            muteNotifications.toggle()
//                                            observed.muteChatNotifications(chat: userDetails, time: 3)
//                                        } label: {
//                                            HStack {
//                                                Text("1 week")
//                                                    .font(.regularFont(16))
//                                                Spacer()
//                                            }
//                                        }.contentShape(Rectangle())
//                                        HorizontalSeparatorView()
//                                        Button {
//                                            muteNotifications.toggle()
//                                            observed.muteChatNotifications(chat: userDetails, time: 1)
//                                        } label: {
//                                            HStack {
//                                                Text("Always")
//                                                    .font(.regularFont(16))
//                                                Spacer()
//                                            }
//                                        }
//                                    }
//                                }
//                                .padding()
//                            })
//                        })
                        
                        Button {
                            
                        } label: {
                            LazyHStack {
                                Image("wallpaperSound")
                                    .imageIconModifier(imageSize: 25, iconSize: 40, color: Color(.systemGray6))
                                Text("Wallpaper & Sound")
                            }
                        }
                        Button {
                            
                        } label: {
                            LazyHStack {
                                Image("themeEllipse")
                                    .imageIconModifier(imageSize: 28, iconSize: 40, color: Color(.systemGray6))
                                Text("Change Theme")
                            }
                        }
                    }.font(.regularFont(16)).foregroundColor(Color(.label))
                    
                    Section {
                        Button {
                            
                        } label: {
                            LazyHStack {
                                Image("groupSetting")
                                    .imageIconModifier(imageSize: 28, iconSize: 40, color: Color(.systemGray6))
                                Text("Group Settings")
                            }
                        }
                    }.font(.regularFont(16)).foregroundColor(Color(.label))
                    
                    Section(header: Text("\(observed.data?.countMembers ?? 0) Members")
                        .padding(.leading, -10)
                        .foregroundColor(Color(.label))
                        .font(.semiBoldFont(18))
                        .textCase(nil)) {
                            if let admin = observed.data?.adminDetail {
                                ForEach(admin, id: \.self) { adminDetails in
                                    NavigationLink(destination: UserInfo(id: adminDetails.id ?? "").toolbarRole(.editor), label: {
                                        HStack(spacing: 0) {
                                            ImageDownloader(adminDetails.avatar)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 46, height: 46)
                                                .clipShape(Circle())
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(adminDetails.name ?? "")
                                                    .font(.semiBoldFont(14))
                                                Text(adminDetails.about ?? "")
                                                    .font(.regularFont(12))
                                                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                            }.padding()
                                            Spacer()
                                            Text("Admin")
                                                .font(.regularFont(13))
                                                .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.55))
                                        }
                                    })
                                }
                            }
                            if let members = observed.data?.groupAllUserDetails {
                                ForEach(members, id: \.self) { memberDetails in
                                    NavigationLink(destination: UserInfo(id: memberDetails.id ?? "").toolbarRole(.editor), label: {
                                        HStack {
                                            ImageDownloader(memberDetails.avatar)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 54, height: 54)
                                                .clipShape(Circle())
                                            VStack {
                                                Text(memberDetails.name ?? "")
                                                    .font(.semiBoldFont(14))
                                                Text(memberDetails.about ?? "")
                                                    .font(.regularFont(12))
                                                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    
                    Section {
                        Button {
                            clearChatDialogSheet.toggle()
                        } label: {
                            Text("Clear Chat")
                        }
                        .fullScreenCover(isPresented: $clearChatDialogSheet, content: {
                            ShowCustomDialogSheet(action: { clearChatDialogSheet.toggle() }, content: {
                                VStack(spacing: 30) {
                                    Text("Clear Chat")
                                        .font(.semiBoldFont(20))
                                        .foregroundColor(Color(.label))
                                    Text("Are you sure you want to delete all messages from this chat?")
                                        .font(.regularFont(14))
                                        .foregroundColor(Color(.label))
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Button {
                                        clearChatDialogSheet.toggle()
                                        observed.deleteChat(id)
                                    } label: {
                                        Text("Yes, Delete All Messages")
                                            .font(.regularFont(16))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                            })
                        })
                        
                        //MARK: DELETE CHAT
                        Button {
                            deleteChatDialogSheet.toggle()
                        } label: {
                            Text("Delete Chat")
                        }
                        .fullScreenCover(isPresented: $deleteChatDialogSheet, content: {
                            ShowCustomDialogSheet(action: { deleteChatDialogSheet.toggle() }, content: {
                                VStack(spacing: 30) {
                                    Text("Delete Chat")
                                        .font(.semiBoldFont(20))
                                        .foregroundColor(Color(.label))
                                    Text("Are you sure you want to delete all messages and remove this chat from your chat list?")
                                        .font(.regularFont(14))
                                        .foregroundColor(Color(.label))
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Button {
                                        deleteChatDialogSheet.toggle()
                                        observed.deleteChat(id)
                                    } label: {
                                        Text("Yes, Delete All Messages")
                                            .font(.regularFont(16))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                            })
                        })
                    }.font(.regularFont(16)).foregroundColor(Color(.label))
                    
                    Section {
                        
                        //MARK: EXIT GROUP
                        Button {
                            exitDialogSheet.toggle()
                        } label: {
                            Text("Exit Group")
                        }
                        .fullScreenCover(isPresented: $exitDialogSheet, content: {
                            ShowCustomDialogSheet(action: { exitDialogSheet.toggle() }, content: {
                                VStack(spacing: 30) {
                                    Text("Exit Group")
                                        .font(.semiBoldFont(20))
                                        .foregroundColor(Color(.label))
                                    Text("Are you sure you want to exit this group? You will not be able to rejoin this group directly. To rejoin, you can contact group members or group admin.")
                                        .font(.regularFont(14))
                                        .foregroundColor(Color(.label))
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Button {
                                        exitDialogSheet.toggle()
                                        observed.exitGroup(id)
                                    } label: {
                                        Text("Yes, Exit Group")
                                            .font(.regularFont(16))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                            })
                        })
                        
                        //MARK: REPORT GROUP
                        Button {
                            reportDialogSheet.toggle()
                        } label: {
                            Text("Report Group")
                        }
                        .fullScreenCover(isPresented: $reportDialogSheet, content: {
                            ShowCustomDialogSheet(action: { reportDialogSheet.toggle() }, content: {
                                VStack(spacing: 30) {
                                    Text("Report Group")
                                        .font(.semiBoldFont(20))
                                        .foregroundColor(Color(.label))
                                    Text("Here, you can report this group. You can also choose to report and exit from this group from below.")
                                        .font(.regularFont(14))
                                        .foregroundColor(Color(.label))
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    VStack(spacing: 12) {
                                        Button {
                                            reportDialogSheet.toggle()
                                            reportAndExitSheet.toggle()
                                        } label: {
                                            HStack {
                                                Text("Report and Exit")
                                                    .font(.regularFont(16))
                                                    .foregroundColor(.red)
                                                Spacer()
                                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                            }
                                        }
                                        HorizontalSeparatorView()
                                        Button {
                                            reportDialogSheet.toggle()
                                            reportSheet.toggle()
                                        } label: {
                                            HStack {
                                                Text("Report")
                                                    .font(.regularFont(16))
                                                    .foregroundColor(.red)
                                                Spacer()
                                                Image(systemName: "exclamationmark.triangle")
                                            }
                                        }
                                    }
                                }
                                .padding()
                            })
                        })
                        .fullScreenCover(isPresented: $reportSheet, content: {
                            ShowCustomDialogSheet(action: { reportSheet.toggle() }, content: {
                                VStack(spacing: 30) {
                                    Text("Report Group")
                                        .font(.semiBoldFont(20))
                                        .foregroundColor(Color(.label))
                                    Text("Are you sure you want to report this group? No one in this group will be notified that you have reported.")
                                        .font(.regularFont(14))
                                        .foregroundColor(Color(.label))
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Button {
                                        reportSheet.toggle()
                                        observed.reportGroup(id)
                                    } label: {
                                        Text("Yes, Report Group")
                                            .font(.regularFont(16))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                            })
                        })
                        .fullScreenCover(isPresented: $reportAndExitSheet, content: {
                            ShowCustomDialogSheet(action: { reportAndExitSheet }, content: {
                                VStack(spacing: 30) {
                                    Text("Report and Exit Group")
                                        .font(.semiBoldFont(20))
                                        .foregroundColor(Color(.label))
                                    Text("Are you sure you want to report and exit this group? No one in this group will be notified that you have reported.")
                                        .font(.regularFont(14))
                                        .foregroundColor(Color(.label))
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Button {
                                        reportAndExitSheet.toggle()
                                        observed.reportGroup(id, leave: true)
                                    } label: {
                                        Text("Yes, Report and Exit Group")
                                            .font(.regularFont(16))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                            })
                        })
                        
                        //MARK: DELETE GROUP
                        Button {
                            deleteGroupDialogSheet.toggle()
                        } label: {
                            Text("Delete Group")
                        }
                        .fullScreenCover(isPresented: $deleteGroupDialogSheet, content: {
                            ShowCustomDialogSheet(action: { deleteGroupDialogSheet.toggle() }, content: {
                                VStack(spacing: 30) {
                                    Text("Delete Group")
                                        .font(.semiBoldFont(20))
                                        .foregroundColor(Color(.label))
                                    Text("Are you sure you want to delete this group? It will not be recoverable after being deleted.")
                                        .font(.regularFont(14))
                                        .foregroundColor(Color(.label))
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .multilineTextAlignment(.center)
                                    Button {
                                        deleteGroupDialogSheet.toggle()
                                        observed.deleteGroup(id)
                                    } label: {
                                        Text("Yes, Delete Group")
                                            .font(.regularFont(16))
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                            })
                        })
                        
                    }.font(.regularFont(16)).foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if let name = observed.data?.createdBy?.name {
                            Text("Group created by \(name)")
                        }
                        if let date = observed.data?.createdAt?.readableDate {
                            Text("Created \(date)")
                        }
                    }
                    .font(.regularFont(12))
                    .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.62))
                    .padding(.leading, -15)
                    //.frame(minWidth: 0, maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .environmentObject(observed)
                .fullScreenCover(isPresented: .constant(getBoolFromString(observed.toastMessage))) {
                    Toast(isShowing: $observed.toastMessage)
                }
                .environment(\.defaultMinListRowHeight, 55)
                .navigationBarTitle("Group Info")
                .navigationBarItems(trailing: Text("Edit").foregroundColor(.blue))
                .onAppear {
                    observed.fetchInfo(userDetails.id)
                }
            }
        }
    }
}

//struct GroupInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupInfo(id: "64b908b755033863b46c7299")
//    }
//}

