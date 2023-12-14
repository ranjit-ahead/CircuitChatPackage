//
//  SearchBarView.swift
//  Chat
//
//  Created by Apple on 21/08/23.
//

import SwiftUI

//struct SearchBarView: View {
//    
//    @EnvironmentObject var observed: ChatListViewObserved
//    
//    @Binding var searchText: String
//    
//    var body: some View {
//        HStack {
//            if let search = observed.apiResponse?.menu.search {
//                HStack {
//                    ImageDownloader(search.icon, renderMode: .template)
//                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
//                        .frame(width: 18.4618, height: 18.7)
//                    
//                    TextField("", text: $searchText)
//                        .textFieldStyle(PlainTextFieldStyle())
//                        .font(.regularFont(17))
//                        .placeholder(when: searchText.isEmpty) {
//                            Text(search.label ?? "").foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
//                        }
//                    
//                    if !searchText.isEmpty {
//                        Button(action: {
//                            searchText = ""
//                        }) {
//                            Image(systemName: "xmark.circle.fill")
//                                .foregroundColor(.gray)
//                        }
//                        .transition(.move(edge: .trailing))
//                        //.animation(.default)
//                    }
//                }
//                .frame(height: 42)
//                .padding(.horizontal, 16)
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                .padding(.horizontal)
//                .padding(.trailing, -8)
//            }
//            
//            if let filter = observed.apiResponse?.menu.filter {
//                ImageDownloader(filter.icon, renderMode: .template)
//                    .viewIconModifierSize(imageWidth: 24, imageHeight: 16, iconSize: 42, imageColor: Color(uiColor: .systemGray), iconColor: Color(.systemGray6))
//                    .padding(.trailing, 15)
//            }
//        }
//        .padding(.top, 10)
//    }
//}

//struct SearchBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBarView(searchText: .constant(""))
//    }
//}
