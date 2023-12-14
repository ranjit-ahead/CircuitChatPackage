//
//  GroupPasswordAccess.swift
//  Chat
//
//  Created by Apple on 25/09/23.
//

import SwiftUI
import Combine

struct GroupPasswordAccess: View {
    var chatSelected: Chat
    var protectedGroup: ProtectedGroupView?
    
    @Binding var showingGroupPasswordAccess: Bool
    @Binding var currentChatSelected: Chat?
    @Binding var passwordText: String
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
//                ImageDownloader(protectedGroup?.icon)
//                    .frame(width: 45, height: 45)
                AsyncImage(
                    url: URL(string: protectedGroup?.icon ?? ""),
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    },
                    placeholder: {
                        // Placeholder view or ProgressView
                    }
                )
                .frame(width: 45, height: 45)
                
                Text(protectedGroup?.label ?? "Please enter password to access this group.")
                    .font(.semiBoldFont(16))
                
                HStack {
                    SecureField("", text: $passwordText)
                        .placeholder(when: passwordText.isEmpty) {
                            Text(protectedGroup?.password ?? "Password")
                            //.font(Font.custom("OpenSans-SemiBold", size: 10))
                                .foregroundColor(Color(UIColor(red: 0.71, green: 0.71, blue: 0.71, alpha: 1)))
                        }
                    Spacer()
                }
                .padding()
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)), lineWidth: 1)
                )
                
                Button {
                    fetchChatMessages(lastChatData: chatSelected, password: passwordText)
                    showingGroupPasswordAccess.toggle()
                } label: {
                    Text(protectedGroup?.submit?.label ?? "Submit")
                        .font(.regularFont(15))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 42)
                                .background(Color(.systemBlue))
                                .cornerRadius(5)
                        }
                }
            }
            .padding()
            .frame(minWidth: UIScreen.screenWidth-70, minHeight: 281)
            .fixedSize(horizontal: true, vertical: true)
            .background(RoundedRectangle(cornerRadius: 27).fill(Color(.tertiarySystemBackground).opacity(1)))
            
            .onTapGesture {
                //
            }
        }
        .onAppear {
            passwordText = ""
        }
        .onTapGesture {
            showingGroupPasswordAccess.toggle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundBlurView())
    }
    
    func fetchChatMessages(lastChatData: Chat, password: String) {
        let pageCount = 1
        let limitCount = 10
        let bodyData: [String:Any] = [
            "password" : password
        ]
        circuitChatRequest("/message/\(lastChatData.id)/\(lastChatData.chatType ?? "")?page=\(pageCount)&limit=\(limitCount)", method: .post, bodyData: bodyData, model: UserChatResponse.self) { result in
            switch result {
            case .success(_):
//                if selectedIndexes.contains(lastChatData) {
//                    selectedIndexes.remove(lastChatData)
//                } else {
//                    selectedIndexes.insert(lastChatData)
//                }
                self.currentChatSelected = lastChatData
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
}
