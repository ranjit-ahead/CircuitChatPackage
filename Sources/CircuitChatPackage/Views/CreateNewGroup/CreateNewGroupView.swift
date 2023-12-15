//
//  CreateNewGroupView.swift
//  Chat
//
//  Created by Apple on 19/09/23.
//

import SwiftUI

struct CreateNewGroupView: View {
    
    var apiResponse: NewChatResponse?
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var newChatNavigation: NewChatNavigation
    
    @StateObject private var observed = Observed()
    
    @State private var selectedImageURL: URL?
    @State private var groupName = ""
    @State private var groupDesc = ""
    @State private var groupPassword = ""
    
    @State private var creatingGroup = false
    
    @Binding var selections: [Chat]
    
    @State private var showImageUploadingOptions = false
    @State private var isCameraPresented = false
    @State private var isGalleryPresented = false
    
    @State private var showPrivacyOptions = false
    @State private var privacySelection: FetchResponse?
    
    var totalMembers: Int?
    
    let borderColor = Color(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
    
    let placeholderFont = Font.custom("OpenSans-Regular", size: 14)
    let placeholderColor = Color(UIColor(red: 0.54, green: 0.54, blue: 0.54, alpha: 1))
    
    var body: some View {
        
        NavigationView {
            VStack(spacing: 20) {
                
                HStack {
                    Button {
                        showImageUploadingOptions.toggle()
                    } label: {
                        if let selectedImage = selectedImageURL {
                            ImageDownloader(selectedImage.absoluteString)
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                        } else {
                            ImageDownloader(apiResponse?.menu.createNewGroup?.avatarIcon)
                                .viewIconModifier(imageSize: 28, iconSize: 56, iconColor: Color(.systemGray5))
                        }
                    }
                    .frame(width: 70, height: 70)
                    
                    .confirmationDialog("", isPresented: $showImageUploadingOptions, titleVisibility: .hidden) {
                        let array = apiResponse?.menu.createNewGroup?.avatarOptions?.filter({ $0.id != "reset" && $0.id != "cancel" }).map({ $0.label ?? "" }) ?? ["Camera", "Gallery"]
                        let photoSelectedArray = apiResponse?.menu.createNewGroup?.avatarOptions?.filter({ $0.id != "cancel" }).map({ $0.label ?? "" }) ?? ["Camera", "Gallery", "Reset Picture"]
                        ForEach(selectedImageURL==nil ? array : photoSelectedArray, id: \.self) { uploadOption in
                            Button(uploadOption) {
                                if uploadOption == "Camera" {
                                    isCameraPresented = true
                                } else if uploadOption == "Gallery" {
                                    isGalleryPresented = true
                                } else {
                                    selectedImageURL = nil
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $isCameraPresented) {
//                        CameraPicker(selectedImage: $selectedImage, isPresented: $isCameraPresented)
                    }
                    .sheet(isPresented: $isGalleryPresented, content: {
                        ImagePicker(selectedImageURL: $selectedImageURL, isImagePickerPresented: $isGalleryPresented)
                    })
                    
                    HStack {
                        TextField("", text: $groupName)
                            .placeholder(when: groupName.isEmpty) {
                                Text(apiResponse?.menu.createNewGroup?.nameInput?.placeholder ?? "Group Name")
                                    .font(placeholderFont)
                                    .foregroundColor(placeholderColor)
                            }
                        Spacer()
                    }
                    .padding()
                    .frame(height: 42) // Adjust the padding as needed
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(borderColor, lineWidth: 1)
                    )
                }
                
                TextField("", text: $groupDesc,  axis: .vertical)
                    .placeholder(when: groupDesc.isEmpty, alignment: .topLeading) {
                        VStack {
                            Text(apiResponse?.menu.createNewGroup?.groupDescription?.placeholder ?? "Group Description")
                                .font(placeholderFont)
                                .foregroundColor(placeholderColor)

                            Spacer()
                        }
                    }
                .font(placeholderFont)
                .padding()
                .frame(height: 120) // Adjust the padding as needed
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(borderColor, lineWidth: 1)
                )
                
                Button {
                    showPrivacyOptions = true
                } label: {
                    VStack{
                        HStack {
                            Text(apiResponse?.menu.createNewGroup?.selectType?.label ?? "Group Privacy")
                                .font(placeholderFont)
                                .foregroundColor(placeholderColor)
                            Spacer()
                            Text(privacySelection?.label ?? apiResponse?.menu.createNewGroup?.selectType?.select ?? "")
                                .font(placeholderFont)
                                .foregroundColor(placeholderColor)
                            Image("rightArrow", bundle: .module)
                                .resizable()
                                .foregroundColor(placeholderColor)
                                .frame(width: 20, height: 20)
                        }
                        .padding()
                        .frame(height: 42)
                        .background{
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(borderColor, lineWidth: 1)
                        }
                    }
                }
                .confirmationDialog("", isPresented: $showPrivacyOptions, titleVisibility: .hidden) {
//                    ForEach(GroupPrivacy.allCases, id: \.self) { privacy in
//                        Button(privacy.rawValue) {
//                            privacySelection = privacy.rawValue
//                        }
//                    }
                    if let options = apiResponse?.menu.createNewGroup?.selectType?.options {
                        ForEach(options) { option in
                            Button(option.label ?? "") {
                                privacySelection = option
                            }
                        }
                    }
                }
                
                if privacySelection?.value == 2 {
                    HStack {
                        SecureField("", text: $groupPassword)
                            .placeholder(when: groupPassword.isEmpty) {
                                Text(apiResponse?.menu.createNewGroup?.passwordInput?.label ?? "Group Password")
                                    .font(placeholderFont)
                                    .foregroundColor(placeholderColor)
                            }
                        Spacer()
                    }
                    .padding()
                    .frame(height: 42) // Adjust the padding as needed
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(borderColor, lineWidth: 1)
                    )
                }
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(Color(.systemGray5))
                    
                    HStack {
                        Text("\(apiResponse?.menu.createNewGroup?.selectedCount?.label ?? "Members :") \(selections.count) \(apiResponse?.menu.createNewGroup?.selectedCount?.label2 ?? "of 1000")")
                            .font(placeholderFont.weight(.semibold))
                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 30)
                .padding(.leading, -18)
                .padding(.trailing, -18)
                
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(selections) { item in
                                SelectedMembersCollectionList(item: item, selections: $selections)
                            }
                        }
                    }
                }
                
                Spacer()
                
            }
            .padding(.leading, 18)
            .padding(.trailing, 18)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image("leftArrow", bundle: .module)
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(apiResponse?.menu.createNewGroup?.navigationTitle ?? "Create New Group")
                    .font(.semiBoldFont(22))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) { // <3>
                Button(action: {
                    creatingGroup = true
                    observed.createGroup(imageURL: selectedImageURL, name: groupName, groupPrivacy: privacySelection?.value, password: groupPassword=="" ? nil : groupPassword, users: selections, completion: {
                        creatingGroup = false
                        newChatNavigation.showSheet.toggle()
                    })
                }) {
                    if creatingGroup {
                        ProgressView()
                    } else {
                        Text(apiResponse?.menu.createNewGroup?.create?.label ?? "Create")
                            .font(.regularFont(16))
                            .foregroundColor(selections.count>0 ? Color(red: 0.02, green: 0.49, blue: 0.99) :Color(red: 0.74, green: 0.74, blue: 0.74))
                    }
                }
                .disabled(selections.count>0 ? false: true)
            }
        }
    }
}

//struct CreateNewGroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateNewGroupView()
//    }
//}
