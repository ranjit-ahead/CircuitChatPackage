//
//  TextEditorView.swift
//  Chat
//
//  Created by Apple on 13/12/23.
//

import SwiftUI

struct TextEditorView: View {
    
    @Binding var string: String
    @State var textEditorHeight : CGFloat = 20
    
    var placeholder = ""
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            Text(string)
                .font(.system(.body))
                .foregroundColor(.clear)
                .padding(.horizontal, 14)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            
            TextEditor(text: $string)
                .font(.system(.body))
                .frame(height: max(40, textEditorHeight))
//                .cornerRadius(10.0)
//                .shadow(radius: 1.0)
            
            if string.isEmpty {
                Text(placeholder)
                    .padding(.horizontal, 3)
                    .font(.system(.body))
                    .foregroundColor(Color(.lightGray))
            }
            
        }.onPreferenceChange(ViewHeightKey.self) { textEditorHeight = $0 }
        
    }
    
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
