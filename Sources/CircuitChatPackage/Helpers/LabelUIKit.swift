//
//  LabelUIKit.swift
//  Chat
//
//  Created by Apple on 22/08/23.
//

import UIKit
import SwiftUI

struct LabelView: View {
    var text: NSAttributedString
    var color: Color?
    var font: Font?
    var alignment: NSTextAlignment?

    @State private var height: CGFloat = .zero

    var body: some View {
        InternalLabelView(text: text, color: color, font: font, alignment: alignment, dynamicHeight: $height)
            .frame(minHeight: height)
    }

    struct InternalLabelView: UIViewRepresentable {
        var text: NSAttributedString
        var color: Color?
        var font: Font?
        var alignment: NSTextAlignment?
        
        @Binding var dynamicHeight: CGFloat

        func makeUIView(context: Context) -> UILabel {
            let label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            return label
        }

        func updateUIView(_ uiView: UILabel, context: Context) {
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = alignment ?? NSTextAlignment.left
            
            let mutableAttributedString = NSMutableAttributedString.init(attributedString: text)
            mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(color ?? .black), range: NSRange(location: 0, length: text.length))
            mutableAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.preferredFont(from: font ?? Font.headline), range: NSRange(location: 0, length: text.length))
            mutableAttributedString.addAttributes([.paragraphStyle: paragraph], range: NSRange(location: 0, length: text.length))
            uiView.attributedText = mutableAttributedString

            DispatchQueue.main.async {
                dynamicHeight = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            }
        }
    }
}
