//
//  ContactListView.swift
//  Chat
//
//  Created by Apple on 20/10/23.
//

import SwiftUI
import Contacts

struct ContactListView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var contacts: [CNContact] = []
    @State private var sortedContacts: [String:[CNContact]] = [:]
    @State private var isFetching = false
    
    @State private var selectedContacts:[CNContact] = []
    
    @State private var navigateContactListNumbersView = false
    
    var userChat: Chat?

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedContacts.sorted(by: { $0.key < $1.key }), id: \.key) { section, contactArray in
                    Section(header: Text(section)) {
                        ForEach(contactArray, id: \.identifier) { contact in
                            HStack {
                                if let imageData = contact.imageData {
                                    if let image = UIImage(data: imageData) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 46, height: 46)
                                            .aspectRatio(contentMode: .fill)
                                    }
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.gray)
                                        .font(.regularFont(46))
                                }
                                VStack(alignment: .leading) {
                                    Text("\(contact.givenName) \(contact.familyName)").font(.regularFont(14))
                                    
                                    ForEach(contact.phoneNumbers, id: \.self) { phoneNumber in
                                        if let phoneNo = (phoneNumber.value).value(forKey: "digits") as? String {
                                            Text("\(phoneNo)").lineLimit(1).font(.regularFont(12))
                                        }
                                    }
                                }
                                Spacer()
                                if selectedContacts.contains(contact) {
                                    Image("selectedTickIcon", bundle: .module)
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .background(content: {
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .background(Color(red: 0.02, green: 0.49, blue: 0.99))
                                                .cornerRadius(17)
                                                .padding(EdgeInsets(top: -5, leading: -5, bottom: -5, trailing: -5))
                                        })
                                        .padding(.trailing, 20)
                                } else {
                                    Circle()
                                        .strokeBorder(Color(UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)), lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                        .padding()
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedContacts.contains(contact) {
                                    if let index = selectedContacts.firstIndex(of: contact) {
                                        selectedContacts.remove(at: index)
                                    }
                                } else {
                                    selectedContacts.append(contact)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Share Contacts")
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedContacts.count>0 {
                            navigateContactListNumbersView.toggle()
                        }
                    }) {
                        Text("Next")
                            .font(.regularFont(16))
                            .foregroundColor(selectedContacts.count>0 ? .blue : Color(uiColor: UIColor(red: 0.74, green: 0.74, blue: 0.74, alpha: 1)))
                            .disabled(selectedContacts.count>0 ? false: true)
                    }
                }
            }
            .onAppear {
                DispatchQueue.global(qos: .userInitiated).async {
                    fetchContacts()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            // Use NavigationLink to navigate to the new view
            .background(
                NavigationLink("", destination: ContactListNumbersView(selectedContacts: selectedContacts, userChat: userChat), isActive: $navigateContactListNumbersView)
                    .opacity(0) // This keeps the link hidden
            )
        }
    }

    func fetchContacts() {
        
        if self.contacts.count>0 {
            return
        }
        
        isFetching = true

        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if granted {
                
                let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor])
                fetchRequest.sortOrder = CNContactSortOrder.userDefault

                do {
                    try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                        self.contacts.append(contact)
                    })
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                for contact in contacts {
                    if let prefix = contact.givenName.first {//get contact name and first character)
                        let contactPrefix = "\(prefix)"
                        if sortedContacts[contactPrefix] == nil {
                            self.sortedContacts[contactPrefix] = [contact]
                        } else {
                            self.sortedContacts[contactPrefix]?.append(contact)
                        }
                    }
                }
            } else {
                print("Access to contacts denied.")
            }

            isFetching = false
        }
    }
}

struct ContactListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView()
    }
}
