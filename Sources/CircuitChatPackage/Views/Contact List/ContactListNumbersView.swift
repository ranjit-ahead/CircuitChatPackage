//
//  ContactListNumbersView.swift
//  Chat
//
//  Created by Apple on 23/10/23.
//

import SwiftUI
import Contacts

struct ContactListNumbersView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var closeView: NewChatNavigation
    
    var selectedContacts: [CNContact]
    @State private var selectedContactNumbersArray: [selectedContactNumbers] = []
    
    var userChat: Chat?
    
    struct selectedContactNumbers: Hashable {
        
        static func == (lhs: selectedContactNumbers, rhs: selectedContactNumbers) -> Bool {
            return lhs.name == rhs.name && lhs.numbers == rhs.numbers
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        var name: String
        var imageData: Data?
        var numbers: [selectedNumbers]
    }
    
    struct selectedNumbers: Hashable {
        
        static func == (lhs: selectedNumbers, rhs: selectedNumbers) -> Bool {
            return lhs.number == rhs.number && lhs.selected == rhs.selected
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(number)
            hasher.combine(selected)
        }
        
        var label: String?
        var number: String
        var selected: Bool
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(selectedContactNumbersArray, id: \.self) { selectedContactNumbers in
                    Section(header: HStack{
                        if let imageData = selectedContactNumbers.imageData {
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
                        Text("\(selectedContactNumbers.name)").foregroundColor(Color(.label)).font(.semiBoldFont(14)).textCase(nil)
                        
                    }.padding(.leading, -20)) {
                        ForEach(selectedContactNumbers.numbers, id: \.self) { phoneNumber in
                            HStack(spacing: 5) {
                                if phoneNumber.selected == true {
                                    Image("selectedTickIcon", bundle: .module)
                                        .resizable()
                                        .padding(5)
                                        .frame(width: 24, height: 24)
                                        .background(content: {
                                            Rectangle()
                                                .foregroundColor(Color(red: 0.02, green: 0.49, blue: 0.99))
                                                .cornerRadius(17)
                                        })
                                        .padding(.trailing, 20)
                                } else {
                                    Circle()
                                        .strokeBorder(Color(UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1)), lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                        .padding(.trailing, 20)
                                }
                                VStack(alignment: .leading) {
                                    Text((phoneNumber.label ?? "").capitalized).lineLimit(1).font(.regularFont(13)).foregroundColor(.blue)
                                    Text(phoneNumber.number).lineLimit(1).font(.regularFont(12))
                                }
                                Spacer()
                            }
                            .frame(height: 60)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let index = selectedContactNumbersArray.firstIndex(of: selectedContactNumbers) {
                                    if let phoneNumberIndex = selectedContactNumbers.numbers.firstIndex(of: phoneNumber) {
                                        self.selectedContactNumbersArray[index].numbers[phoneNumberIndex].selected = !(selectedContactNumbersArray[index].numbers[phoneNumberIndex].selected)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                for contact in selectedContacts {
                    var selNum: [selectedNumbers] = []
                    for number in contact.phoneNumbers {
                        if let phoneNo = (number.value).value(forKey: "digits") as? String {
                            let label = CNLabeledValue<NSString>.localizedString(forLabel: number.label ?? "" )
                            selNum.append(selectedNumbers(label: label, number: phoneNo, selected: true))
                        }
                    }
                    selectedContactNumbersArray.append(selectedContactNumbers(name: "\(contact.givenName) \(contact.familyName)", imageData: contact.imageData, numbers: selNum))
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
                            sendMessage()
                            closeView.showSheet.toggle()
                        }
                    }) {
                        Text("Send")
                            .font(.regularFont(16))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    func sendMessage() {
        
        var bodyData: [String:Any] = [
            "to" : userChat?.id ?? "",
            "receiverType" : userChat?.chatType ?? "",
            "type" : "contact"
        ]
        
        for index in 0..<selectedContactNumbersArray.count {
            let contact = selectedContactNumbersArray[index]
            bodyData["contact[\(index)][name]"] = contact.name
            var index2 = 0
            for phoneNumber in contact.numbers {
                if contact.numbers[index2].selected {
                    bodyData["contact[\(index)][numbers][\(index2)][number]"] = phoneNumber.number
                    index2 += 1
                }
            }
        }
        
        circuitChatRequest("/message", method: .post, bodyData: bodyData, dataType: "form-data", model: UserChatData.self) { result in
            switch result {
            case .success(let data):
                print("success")
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
    
}

//struct ContactListNumbersView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactListNumbersView()
//    }
//}
