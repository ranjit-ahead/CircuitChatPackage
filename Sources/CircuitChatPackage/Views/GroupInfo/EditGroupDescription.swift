//
//  EditGroupDescription.swift
//  Chat
//
//  Created by Apple on 03/11/23.
//

import SwiftUI

struct EditGroupDescription: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var observed: GroupInfoObserved
    
    @State private var groupDesc = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                TextField("", text: $groupDesc,  axis: .vertical)
                    .placeholder(when: groupDesc.isEmpty, alignment: .topLeading) {
                        VStack {
                            Text("Add Group Description")
                                .font(.regularFont(14))
                            Spacer()
                        }
                    }
                    .font(.regularFont(14))
                    .padding()
                    .frame(minHeight: 240) // Adjust the padding as needed
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.56, green: 0.56, blue: 0.58), lineWidth: 1)
                    )
                
                Text("This group description is visible to participants of this group and people invited to this group.")
                    .font(.regularFont(13))
                Spacer()
            }
            .onAppear {
                groupDesc = observed.data?.metadata ?? ""
            }
            .padding()
            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
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
                    Text("Group Description")
                        .font(.semiBoldFont(22))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) { // <3>
                    Button(action: {
                        observed.editGroup(observed.data?.id ?? "", groupName: observed.data?.name ?? "", metadata: groupDesc)
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.regularFont(16))
                            .foregroundColor(groupDesc != "" ? Color(red: 0.02, green: 0.49, blue: 0.99) :Color(red: 0.74, green: 0.74, blue: 0.74))
                    }
                    .disabled(groupDesc != "" ? false: true)
                }
            }
        }
    }
}

//struct EditGroupDescription_Previews: PreviewProvider {
//    static var previews: some View {
//        EditGroupDescription()
//    }
//}
