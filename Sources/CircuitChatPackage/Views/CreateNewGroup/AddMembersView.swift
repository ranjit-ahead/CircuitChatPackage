//
//  AddMembersView.swift
//  Chat
//
//  Created by Apple on 18/09/23.
//

import SwiftUI

struct AddMembersView: View {
    
    var apiRequest: ApiRequest
    
    @Binding var forwardMode: EditMode
    var forwardMessages: [String] = []
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var observed = Observed()
    
    @State private var searchText = ""
    @State private var memberSelected = false
    
    @State private var selections: [Chat] = []
    @State private var isDetailViewActive = false
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollViewProxy in
                //                HStack {
                List {
                    
                    if selections.count > 0 {
                        Section() {
                            VStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(selections) { item in
                                            SelectedMembersCollectionList(item: item, selections: $selections)
                                            //                                                .onTapGesture(perform: {
                                            //                                                    self.selections.removeAll(where: { $0 == item })
                                            //                                                })
                                        }
                                    }
                                }
                            }.padding(.horizontal, -13)
                        }
                    }
                    
                    //MARK: Frequently Contacted
                    if let array = observed.frequentlyContactedArray, array.count>0 {
                        Section(header: Text(observed.apiResponse?.menu.frequentlyContacted?.id ?? "").textCase(nil)) {
                            ForEach(array) { item in
                                AddMembersViewRow(item: item, isSelected: self.selections.contains(item)) {
                                    if self.selections.contains(item) {
                                        self.selections.removeAll(where: { $0 == item })
                                    } else {
                                        self.selections.append(item)
                                    }
                                }
                            }
                        }
                    }
                    
                    if let array = observed.chatArray, array.count>0 {
                        ForEach(array) { array in
                            Section(header: Text(array.id)) {
                                ForEach(array.results) { item in
                                    AddMembersViewRow(item: item, isSelected: self.selections.contains(item)) {
                                        if self.selections.contains(item) {
                                            self.selections.removeAll(where: { $0 == item })
                                        } else {
                                            self.selections.append(item)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                //                    .listStyle(.grouped)
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
                .searchable(text: $searchText)
                //                    VStack {
                //                        if let array = chatMapping {
                //                            ForEach(array) { section in
                //                                Button(section.id) {
                //                                    scrollViewProxy.scrollTo(section.id, anchor: .top)
                //                                }
                //                            }
                //                        }
                //                    }
                //                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        ImageDownloader(observed.apiResponse?.menu.addMember?.closeIcon ?? observed.apiResponse?.menu.closeIcon, image: "leftArrow")
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(uiColor: UIColor(red: 0.64, green: 0.64, blue: 0.64, alpha: 1)))
                    }
                }
                ToolbarItem(placement: .principal) { // <3>
                    Text(observed.apiResponse?.menu.addMember?.navigationTitle ?? observed.apiResponse?.menu.navigationTitle ?? "")
                        .font(.semiBoldFont(15))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) { // <3>
                    Button(action: {
                        // Activate the navigation link
                        if selections.count>0 {
                            if let done = observed.apiResponse?.menu.done {
                                let users = selections.map({ $0.id })
                                observed.sendMessage(apiRequest: ApiRequest(apiURL: done.apiURL, method: done.apiMethod), messages: forwardMessages, users: users)
                                forwardMode = .inactive
                                dismiss()
                            } else {
                                isDetailViewActive = true
                            }
                        }
                    }) {
                        Text(observed.apiResponse?.menu.addMember?.next ?? observed.apiResponse?.menu.done?.label ?? "")
                            .font(.regularFont(16))
                            .foregroundColor(selections.count>0 ? Color(red: 0.02, green: 0.49, blue: 0.99) :Color(red: 0.74, green: 0.74, blue: 0.74))
                    }
                    .disabled(selections.count>0 ? false : true)
                }
            }
        }
        
        // Use NavigationLink to navigate to the new view
        .background(
            NavigationLink(destination: CreateNewGroupView(apiResponse: observed.apiResponse, selections: $selections, totalMembers: observed.chatArray?.count), isActive: $isDetailViewActive) {
                EmptyView()
            }.opacity(0) // This keeps the link hidden
        )
        .onAppear {
            observed.fetchApiData(apiRequest: apiRequest)
        }
    }
}

//struct AddMembersView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddMembersView()
//    }
//}
