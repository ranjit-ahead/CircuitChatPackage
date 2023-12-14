//
//  AboutView.swift
//  Chat
//
//  Created by Apple on 07/11/23.
//

import SwiftUI

struct AboutView: View {
    
    @Binding var aboutSelected: String
    
    @Binding var aboutOptions: [AboutOptions]
    
    var body: some View {
        NavigationStack {
            
            List {
                Section(header: Text("Currently Set to").textCase(nil)) {
                    Text(aboutSelected)
                }
                Section(header: Text("Select Your About").textCase(nil)) {
                    ForEach($aboutOptions, id: \.self, editActions: .delete) { $aboutOptions in
                        Text(aboutOptions.about)
                    }
                }
            }
            
        }
        .navigationTitle("About")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
            }
        }
    }
}

//struct AboutView_Previews: PreviewProvider {
//    static var previews: some View {
//        AboutView()
//    }
//}
