//
//  ShowImage.swift
//  Chat
//
//  Created by Apple on 20/10/23.
//

import SwiftUI
import Kingfisher

struct ShowImage: View {
    
    var url: String?
    
    var body: some View {
        VStack {
            
            Spacer()
            
            ImageDownloader(url)
                .toolbar(.hidden, for: .tabBar)
                .scaledToFit()

            Spacer()
            
            HStack {
                
                Menu {
                    Button {
                        copyTextToClipboard(url)
                    } label: {
                        Label("Copy", systemImage: "square.on.square")
                    }
                    
                    Button {
                        if let url = url {
                            saveImageToPhotos(urlString: url)
                        }
                    } label: {
                        Label("Save Image", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                        .padding(5)
                }
                
                Spacer()
                
            }
            .padding(.horizontal)
            .background(.ultraThinMaterial)
            .overlay(Rectangle().frame(height: 0.2).foregroundColor(Color.gray), alignment: .top)
//            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -5)
            .onAppear {
                UIView.setAnimationsEnabled(false)
            }
        }
    }
}

struct ShowImage_Previews: PreviewProvider {
    static var previews: some View {
        ShowImage(url: "https://picsum.photos/200")
    }
}
