//
//  EditProfile.swift
//  Chat
//
//  Created by Apple on 09/11/23.
//

import SwiftUI

struct EditProfile: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var observed = Observed()
    
    @Binding var preUserName: String?
    @Binding var preDescription: String?
    @Binding var preAbout: String?
    @State var selectedImageURL: URL?
    
    @State private var username = ""
    @State private var description = ""
    @State private var about = ""
    
    var aboutOptions: [AboutOptions]?
    
    @State private var showImageUploadingOptions = false
    @State private var isCameraPresented = false
    @State private var isGalleryPresented = false
    
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
                                    .scaledToFill()
                            } else {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.clear)
                                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                    Circle()
                                        .foregroundColor(.clear)
                                        .background(Color(UIColor.systemBlue))
                                        .frame(width: 28, height: 28)
                                        .cornerRadius(14)
                                    Image("cameraIconFilled")
                                        .renderingMode(.template)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width:14, height: 13)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(width: 70, height: 70)
                        .cornerRadius(35)
                        .confirmationDialog("", isPresented: $showImageUploadingOptions, titleVisibility: .hidden) {
                            ForEach(selectedImageURL==nil ? ["Camera", "Gallery"] : ["Camera", "Gallery", "Reset Picture"], id: \.self) { uploadOption in
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
//                            CameraPicker(selectedImageURL: $selectedImageURL, isPresented: $isCameraPresented)
                        }
                        .sheet(isPresented: $isGalleryPresented, content: {
                            ImagePicker(selectedImageURL: $selectedImageURL, isImagePickerPresented: $isGalleryPresented, allowEditing: true)
                        })
                    
                    HStack {
                        TextField("", text: $username)
                            .placeholder(when: username.isEmpty) {
                                Text("Enter User Name")
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
                
                HStack {
                    TextField("", text: $description)
                        .placeholder(when: description.isEmpty) {
                            Text("Enter Description")
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
                
                VStack(alignment: .leading) {
                    
                    Text("About")
                        .font(.regularFont(14))
                      .foregroundColor(placeholderColor)

                    NavigationLink(destination: {
                        if let options = aboutOptions {
                            AboutView(aboutSelected: .constant(preAbout ?? ""), aboutOptions: .constant(options))
                        }
                    }, label: {
                        VStack{
                            HStack {
                                Text("Available")
                                    .font(placeholderFont)
                                    .foregroundColor(placeholderColor)
                                Spacer()
                                //                    Text(privacySelection)
                                //                        .font(placeholderFont)
                                //                        .foregroundColor(placeholderColor)
                                Image("rightArrow")
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
                    })
                }
                
                Spacer()
            }
            .padding(.leading, 18)
            .padding(.trailing, 18)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .rotationEffect(.degrees(45))
                            .foregroundColor(Color(uiColor: UIColor(red: 0.64, green: 0.64, blue: 0.64, alpha: 1)))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Your Profile")
                        .font(.semiBoldFont(22))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) { // <3>
                    Button(action: {
                        observed.editUserProfile(name: username, metadata: description, about: about, avatar: selectedImageURL)
                    }) {
    //                    if creatingGroup {
    //                        ProgressView()
    //                    } else {
    //                        Text("Done")
    //                            .font(.regularFont(16))
    ////                            .foregroundColor(selections.count>0 ? Color(red: 0.02, green: 0.49, blue: 0.99) :Color(red: 0.74, green: 0.74, blue: 0.74))
    //                    }
                        Text("Done")
                            .font(.regularFont(16))
                    }
    //                .disabled(selections.count>0 ? false: true)
                }
            }
        }
        .onAppear {
            if let preUserName = preUserName {
                username = preUserName
            }
            if let preDescription = preDescription {
                description = preDescription
            }
            if let preAbout = preAbout {
                about = preAbout
            }
        }
    }
}

extension EditProfile {
    class Observed: ObservableObject {
        
        @Published var data: GroupInfoModel?
        
        func editUserProfile(name: String, metadata: String, about: String, avatar: URL?) {
            
            let bodyData: [String:Any] = [
                "name" : name,
                "metadata": metadata,
                "about": about
            ]
            
            var dataType = ""
            var dataExtension = ""
            var fileData: [String: Data] = [:]
            if let imageURL = avatar {
                URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    if let error = error {
                        print("Error downloading image data: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data received when downloading image.")
                        return
                    }
                    
                    do {
                        dataType = "image"
                        dataExtension = imageURL.pathExtension
                        fileData.updateValue(data, forKey: "avatar")
                        // Now "data" contains the image file data
                    }
                }.resume()
            }
            
            circuitChatRequest("/user/edit", method: .post, bodyData: bodyData, fileData: fileData, dataType: dataType, dataExtension: dataExtension, model: GroupInfoModel.self) { result in
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
