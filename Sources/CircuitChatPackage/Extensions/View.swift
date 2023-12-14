//
//  View.swift
//  Chat
//
//  Created by Apple on 23/08/23.
//
import UIKit
import SwiftUI
import Kingfisher

//func ImageFetch(_ url: String?, renderMode: Image.TemplateRenderingMode = .original) -> Image {
//    do {
//        let data = try Data(contentsOf: URL(string: url!)!)
//        return Image(uiImage: UIImage(data: data)!)
//    } catch {
//        return Image(systemName: "exclamationmark.triangle")
//    }
//}

func ImageFetch(_ url: String?, renderMode: Image.TemplateRenderingMode = .original, completion: @escaping (Image) -> Void) {
    guard let urlString = url, let url = URL(string: urlString) else {
        completion(Image(systemName: "exclamationmark.triangle"))
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(Image(systemName: "exclamationmark.triangle"))
            return
        }

        if let data = data, let uiImage = UIImage(data: data) {
            let image = Image(uiImage: uiImage)
            DispatchQueue.main.async {
                completion(image)
            }
        } else {
            completion(Image(systemName: "exclamationmark.triangle"))
        }
    }

    task.resume()
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    func ImageDownloader(_ url: String?, renderMode: Image.TemplateRenderingMode = .original, image: String = "", systemImage: String = "") -> some View {
        guard let url = url else {
            return AnyView(placeholderView(image, systemImage: systemImage))
        }
        
        return AnyView(
            KFImage(URL(string: url))
                .resizable()
                .renderingMode(renderMode)
                .placeholder {
                    AnyView(placeholderView(image))
                }
                .loadDiskFileSynchronously()
                .cacheMemoryOnly()
                .fade(duration: 0.25)
        )
    }

    private func placeholderView(_ image: String, systemImage: String = "") -> some View {
        if !image.isEmpty {
            return AnyView(Image(image).resizable().aspectRatio(contentMode: .fit).clipped())
        } else if !systemImage.isEmpty {
            return AnyView(Image(systemName: systemImage).resizable().aspectRatio(contentMode: .fit).clipped().foregroundColor(Color.gray))
        } else {
            return AnyView(
                Rectangle()
                    .foregroundColor(.clear)
                    .background(Color.gray)
            )
        }
    }
    
    func viewIconModifierSize(imageWidth: CGFloat, imageHeight: CGFloat,iconSize: CGFloat, imageColor: Color? = nil, iconColor: Color) -> some View {
        self
            .frame(width: imageWidth, height: imageHeight)
            .padding()
            .foregroundColor(imageColor)
            .background(iconColor)
            .frame(width: iconSize, height: iconSize)
            .clipShape(Circle())
    }
    
    func viewIconModifier(imageSize: CGFloat, iconSize: CGFloat, imageColor: Color? = nil, iconColor: Color) -> some View {
        self
            .frame(width: imageSize, height: imageSize)
            .padding()
            .foregroundColor(imageColor)
            .background(iconColor)
            .frame(width: iconSize, height: iconSize)
            .clipShape(Circle())
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
            clipShape( RoundedCorner(radius: radius, corners: corners) )
        }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension EditMode {
    var title: String {
        self == .active ? "Done" : "Edit"
    }
    
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
