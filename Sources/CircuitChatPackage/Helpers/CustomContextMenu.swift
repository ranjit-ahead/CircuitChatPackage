//
//  CustomContextMenu.swift
//  Chat
//
//  Created by Apple on 27/09/23.
//

import SwiftUI

//Custom View Builder
struct CustomContextMenu<Content: View, Preview: View>: View {
    
    var content: Content
    var preview: Preview
    
    //List of Actions..
    var menu: UIMenu
    var onEnd: ()->()
    
    init(@ViewBuilder content: @escaping()->Content, @ViewBuilder preview: @escaping()->Preview, actions: @escaping()-> UIMenu, onEnd: @escaping ()->()) {
        self.content = content()
        self.preview = preview()
        self.menu = actions()
        self.onEnd = onEnd
    }
    
    var body: some View {
        content
            .hidden()
            .overlay {
                ContextMenuHelper(content: content, preview: preview, actions: menu, onEnd: onEnd)
            }
    }
}

struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable {
    var content: Content
    var preview: Preview
    var menu: UIMenu
    var onEnd: ()->()
    init(content: Content, preview: Preview, actions: UIMenu, onEnd: @escaping ()->()) {
        self.content = content
        self.preview = preview
        self.menu = actions
        self.onEnd = onEnd
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        //setting our content view  as Main Interaction view...
        let hostView = UIHostingController(rootView: content)
        
        //setting constraints
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints..
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor)
        ]
        
        view.addSubview(hostView.view)
        view.addConstraints(constraints)
        
        //setting interaction
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        //
    }
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: ContextMenuHelper
        init(parent: ContextMenuHelper) {
            self.parent = parent
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil) {
                
                let previewController = UIHostingController(rootView: self.parent.preview)
                previewController.view.backgroundColor = .clear
                return previewController
                
            } actionProvider: { items in
                //
                return self.parent.menu
            }
        }
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            animator.addCompletion {
                print("Ended")
                //self.parent.onEnd
            }
        }
    }
}
