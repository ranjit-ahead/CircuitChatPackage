//
//  UserInfo.swift
//  Chat
//
//  Created by Apple on 31/10/23.
//

import SwiftUI

struct UserInfo: View {
    
    @StateObject private var observed = Observed()
    
    var id: String
    
    var body: some View {
        List {
            
            Section {
                ImageDownloader(observed.data?.avatar)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                Text(observed.data?.name ?? "")
                    .font(.semiBoldFont(22))
                Text(observed.data?.about ?? "")
                    .font(.regularFont(15))
                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                HStack {
                    Button {
                        
                    } label: {
                        LazyVStack {
                            Image(systemName: "phone.badge.plus")
                                .resizable()
                                .frame(width: 22, height: 22)
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
                    
                } label: {
                    LazyHStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Media, Links, and Docs")
                    }
                }
                Button {
                    
                } label: {
                    LazyHStack {
                        Image(systemName: "star")
                        Text("Starred Message")
                    }
                }
            }.font(.regularFont(16)).foregroundColor(Color(.label))
            
            Section {
                Button {
                    
                } label: {
                    LazyHStack {
                        Image(systemName: "speaker.wave.2")
                        Text("Mute")
                    }
                }
                Button {
                    
                } label: {
                    LazyHStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Wallpaper & Sound")
                    }
                }
                Button {
                    
                } label: {
                    LazyHStack {
                        Image(systemName: "circle.hexagonpath")
                        Text("Change Theme")
                    }
                }
            }.font(.regularFont(16)).foregroundColor(Color(.label))
            
            Section(header: Text("\(observed.data?.commonGroupCount ?? 0) Group in Common")
                                .padding(.leading, -10)
                                .foregroundColor(Color(.label))
                                .font(.semiBoldFont(18))
                                .textCase(nil)) {
                if let members = observed.data?.groupProfiles {
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
                    
                } label: {
                    Text("Clear Chat")
                }
                Button {
                    
                } label: {
                    Text("Delete Chat")
                }
            }.font(.regularFont(16)).foregroundColor(Color(.label))
            
            Section {
                Button {
                    
                } label: {
                    Text("Block \(observed.data?.name ?? "")")
                }
                Button {
                    
                } label: {
                    Text("Report \(observed.data?.name ?? "")")
                }
            }.font(.regularFont(16)).foregroundColor(.red)
        }
        .navigationBarTitle("Contact Info")
        .navigationBarItems(trailing: Text("Edit"))
        .onAppear {
            observed.fetchInfo(id)
        }
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        UserInfo(id: "")
    }
}
