//
//  SettingsView.swift
//  Chat
//
//  Created by Apple on 21/08/23.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var observed = Observed()
    
    @State private var openEditProfile = false
    
    var body: some View {
        NavigationStack {
            
            List {
                Section(content: {
                    HStack {
                        ZStack(alignment: .bottomTrailing) {
                            ImageDownloader(observed.data?.data.avatar)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .background {
                                    NavigationLink("", destination: ShowImage(url:observed.data?.data.avatar))
                                                    .opacity(0)
                                }

                            Image(systemName: "camera")
                                .imageIconModifier(imageSize: 13, iconSize: 26, imageColor: .white, color: .blue)
                        }
                        VStack(alignment: .leading) {
                            Text(observed.data?.data.name ?? "").font(.semiBoldFont(18))
                            Text(observed.data?.data.metadata ?? "")
                                .font(.regularFont(15))
                                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                        }
                        .onTapGesture {
                            openEditProfile.toggle()
                        }
                        .sheet(isPresented: $openEditProfile, content: {
                            EditProfile(preUserName: .constant(observed.data?.data.name), preDescription: .constant(observed.data?.data.metadata), preAbout: .constant(observed.data?.data.about), selectedImageURL: URL(string: observed.data?.data.avatar ?? "")!, aboutOptions: observed.data?.data.aboutOptions)
                        })
                    }
                })
                
                Group {
                    NavigationLink(destination: {
                        StarredMessage(chatId: observed.data?.data.id, chatType: "user").toolbarRole(.editor)
                    }, label: {
                        LazyHStack {
                            Image("star", bundle: .module)
                                .imageIconModifier(imageSize: 24, iconSize: 40, imageColor: .blue, color: Color(.systemGray6))
                            Text("Starred Message")
                        }
                    })
                    NavigationLink(destination: {
                        //
                    }, label: {
                        LazyHStack {
                            Image("faceCircle", bundle: .module)
                                .imageIconModifier(imageSize: 24, iconSize: 40, imageColor: .blue, color: Color(.systemGray6))
                            Text("Account Setting")
                        }
                    })
                    NavigationLink(destination: {
                        //StarredMessage(userDetails: userDetails).toolbarRole(.editor)
                    }, label: {
                        LazyHStack {
                            Image("tickShield", bundle: .module)
                                .imageIconModifier(imageSize: 24, iconSize: 40, imageColor: .blue, color: Color(.systemGray6))
                            Text("Privacy Policy")
                        }
                    })
                    NavigationLink(destination: {
                        //StarredMessage(userDetails: userDetails).toolbarRole(.editor)
                    }, label: {
                        LazyHStack {
                            Image("notificationBell", bundle: .module)
                                .imageIconModifier(imageSize: 24, iconSize: 40, imageColor: .blue, color: Color(.systemGray6))
                            Text("Notifications")
                        }
                    })
                    NavigationLink(destination: {
                        if let options = observed.data?.data.aboutOptions {
                            AboutView(aboutSelected: .constant(observed.data?.data.about ?? ""), aboutOptions: .constant(options))
                        }
                    }, label: {
                        LazyHStack {
                            Image("iIcon", bundle: .module)
                                .imageIconModifier(imageSize: 24, iconSize: 40, imageColor: .blue, color: Color(.systemGray6))
                            Text("About")
                        }
                    })
                    NavigationLink(destination: {
                        //StarredMessage(userDetails: userDetails).toolbarRole(.editor)
                    }, label: {
                        LazyHStack {
                            Image("shareIcon", bundle: .module)
                                .imageIconModifier(imageSize: 24, iconSize: 40, imageColor: .blue, color: Color(.systemGray6))
                            Text("Share")
                        }
                    })
                    NavigationLink(destination: {
                        //StarredMessage(userDetails: userDetails).toolbarRole(.editor)
                    }, label: {
                        LazyHStack {
                            Image("userStarsIcon", bundle: .module)
                                .imageIconModifier(imageSize: 24, iconSize: 40, imageColor: .blue, color: Color(.systemGray6))
                            Text("Rate us")
                        }
                    })
                }.font(.regularFont(16)).foregroundColor(Color(.label))
            }
                
        }
        .onAppear {
            if observed.data == nil {
                observed.fetchInfo(circuitChatUID)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Your Profile")
                  .font(.semiBoldFont(20))
                  .foregroundColor(.black)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension SettingsView {
    
    class Observed: ObservableObject {
        
        @Published var data: GroupInfoModel?
        
        func fetchInfo(_ id: String) {
            circuitChatRequest("/user/profile?friend=\(id)", method: .get, model: GroupInfoModel.self) { result in
                switch result {
                case .success(let data):
                    self.data = data
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
    }
}
