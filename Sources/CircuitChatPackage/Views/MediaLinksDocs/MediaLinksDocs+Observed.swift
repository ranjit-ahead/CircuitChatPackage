//
//  MediaLinksDocs+Observed.swift
//  Chat
//
//  Created by Apple on 04/11/23.
//

import Foundation

extension MediaLinksDocs {
    class Observed: ObservableObject {
        
        var responseData: MediaLinksDocsModel?
        
        @Published var mediaData: [String: [MediaLinksDocsData]] = [:]
        @Published var linksData: [String: [MediaLinksDocsData]] = [:]
        @Published var docsData: [String: [MediaLinksDocsData]] = [:]
        
        func fetchData(_ segment: Int, lastChatData: Chat) {
            
            var url = "/message/media/\(lastChatData.id)/\(lastChatData.chatType ?? "")/media"
            if segment == 1 { //LINKS
                url = "/message/media/\(lastChatData.id)/\(lastChatData.chatType ?? "")/link"
            } else if segment == 2 { //DOCS
                url = "/message/media/\(lastChatData.id)/\(lastChatData.chatType ?? "")/doc"
            }
            
            circuitChatRequest(url, method: .get, model: MediaLinksDocsModel.self) { result in
                switch result {
                case .success(let data):
                    self.responseData = data
                    self.changeDataModel(segment)
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
        }
        
        func changeDataModel(_ segment: Int) {
            if let responseData = responseData?.data, responseData.count>0 {
                for mediaData in responseData {
                    let month = mediaData.createdAt?.getMonthAndYear ?? ""
                    if segment == 0 {
                        if self.mediaData[month] == nil {
                            self.mediaData[month] = [mediaData]
                        } else {
                            self.mediaData[month]?.append(mediaData)
                        }
                    } else if segment == 1 {
                        if self.linksData[month] == nil {
                            self.linksData[month] = [mediaData]
                        } else {
                            self.linksData[month]?.append(mediaData)
                        }
                    } else if segment == 2 {
                        if self.docsData[month] == nil {
                            self.docsData[month] = [mediaData]
                        } else {
                            self.docsData[month]?.append(mediaData)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - MediaLinksDocsModel
struct MediaLinksDocsModel: Codable {
    let data: [MediaLinksDocsData]?
    let count: Int?
}

// MARK: - MediaLinksDocsData
struct MediaLinksDocsData: Codable, Hashable {
    let id, contentType, text: String?
    let media: String?
    let messageId: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case contentType, media, messageId, text, createdAt
    }
}

