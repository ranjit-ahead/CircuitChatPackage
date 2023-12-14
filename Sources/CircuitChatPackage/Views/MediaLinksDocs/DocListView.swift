//
//  DocListView.swift
//  Chat
//
//  Created by Apple on 04/11/23.
//

import SwiftUI

struct DocListView: View {
    @State private var fileSizeText: String? = nil
    var data: MediaLinksDocsData
    
    var body: some View {
        let fileExtension = URL(string: data.media ?? "")!.pathExtension
        HStack {
            Group {
                if fileExtension=="pdf" || fileExtension=="docx" || fileExtension=="xls" || fileExtension=="png" || fileExtension=="jpg" || fileExtension=="jpeg" {
                    Image(fileExtension=="pdf" ? "pdfFileIcon" : fileExtension=="docx" ? "docxFileIcon" : fileExtension=="xls" ? "excelFileIcon" : fileExtension=="png" ? "pngFileIcon" : fileExtension=="jpg" ? "jpgFileIcon" : "jpegFileIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "doc")
                        .resizable()
                        .foregroundColor(Color(.systemGray))
                        .padding(5)
                }
            }.frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(URL(string: data.media ?? "")!.lastPathComponent)").lineLimit(1).font(.semiBoldFont(14))
                HStack {
                    if let fileSizeText = fileSizeText {
                        Text(fileSizeText)
                            .padding(.leading, 0).padding(.trailing, 0)
                    } else {
                        Text("5 KB")
                            .padding(.leading, 0).padding(.trailing, 0)
                            .onAppear {
                                Task {
                                    getFileSizeFromURL(urlString: data.media ?? "") { fileSize in
                                        fileSizeText = fileSize?.convertBytesToGBMBKB
                                    }
                                }
                            }
                    }
                    Text("|  \(String(describing: fileExtension.uppercased()))")
                    Spacer()
                }.font(.regularFont(12)).foregroundColor(.gray)
            }
        }
    }
}
