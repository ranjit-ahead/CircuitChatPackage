//
//  ExpandableText.swift
//  Chat
//
//  Created by Apple on 03/11/23.
//

import SwiftUI

struct ExpandableText: View {
    
    @State private var expanded: Bool = false
    @State private var truncated: Bool = false
    @State private var shrinkText: String
    
    @Binding var text: String
    let lineLimit: Int
    let font: UIFont
    let color: Color
    
    init(_ text: Binding<String>, lineLimit: Int, font: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular), color: Color = Color(.black)) {
        _text = text
        _shrinkText =  State(wrappedValue: text.wrappedValue)
        self.lineLimit = lineLimit
        self.font = font
        self.color = color
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                Text(self.expanded ? text : shrinkText) + Text(moreLessText)
                    .font(Font(font))
                    .foregroundColor(.blue)
            }
            .animation(.easeInOut(duration: 1.0), value: false)
            .lineLimit(expanded ? nil : lineLimit)
            .background(
                // Render the limited text and measure its size
                Text(text)
                    .lineLimit(lineLimit)
                    .background(GeometryReader { visibleTextGeometry in
                        Color.clear.onAppear {
                            setShrinkText(visibleTextGeometry)
                        }.onChange(of: text) { _ in
                            setShrinkText(visibleTextGeometry)
                        }
                    })
                    .hidden() // Hide the background
            )
            .font(Font(font)) ///set default font
            .foregroundColor(color)
            
            if truncated {
                Button(action: {
                    expanded.toggle()
                }, label: {
                    HStack { //taking tap on only last line, As it is not possible to get 'see more' location
                        Spacer()
                        Text("")
                    }.opacity(0)
                })
            }
        }
    }
    
    private var moreLessText: String {
        if !truncated {
            return ""
        } else {
            return self.expanded ? " See Less" : " See More"
        }
    }
    
    func setShrinkText(_ visibleTextGeometry: GeometryProxy) {
        let size = CGSize(width: visibleTextGeometry.size.width, height: .greatestFiniteMagnitude)
        let attributes:[NSAttributedString.Key:Any] = [NSAttributedString.Key.font: font]
        
        ///Binary search until mid == low && mid == high
        var low  = 0
        var heigh = shrinkText.count
        var mid = heigh ///start from top so that if text contain we does not need to loop
        ///
        while ((heigh - low) > 1) {
            let attributedText = NSAttributedString(string: shrinkText + moreLessText, attributes: attributes)
            let boundingRect = attributedText.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            if boundingRect.size.height > visibleTextGeometry.size.height {
                truncated = true
                heigh = mid
                mid = (heigh + low)/2
                
            } else {
                if mid == text.count {
                    break
                } else {
                    low = mid
                    mid = (low + heigh)/2
                }
            }
            shrinkText = String(text.prefix(mid))
        }
        
        if truncated {
            shrinkText = String(shrinkText.prefix(shrinkText.count - 2))  //-2 extra as highlighted text is bold
        }
    }
    
}
