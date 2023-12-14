//
//  MediaLinksDocs.swift
//  Chat
//
//  Created by Apple on 04/11/23.
//

import SwiftUI

struct MediaLinksDocs: View {
    
    var userDetails: Chat?
    
    @State private var selectedSegment = 0
    
    @StateObject private var observed = Observed()
    
    var body: some View {
        NavigationStack {
            // Display lists based on the selected segment
            if selectedSegment == 0 {
                mediaList
            } else if selectedSegment == 1 {
                linksList
            } else if selectedSegment == 2 {
                docsList
            }
        }
        .onAppear {
            if let userDetails = userDetails {
                observed.fetchData(0, lastChatData: userDetails)
                observed.fetchData(1, lastChatData: userDetails)
                observed.fetchData(2, lastChatData: userDetails)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) { // <3>
                Picker("Select a segment", selection: $selectedSegment) {
                    Text("Media").tag(0)
                    Text("Links").tag(1)
                    Text("Docs").tag(2)
                }
                .tint(.blue)
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 250)
            }
            ToolbarItem(placement: .navigationBarTrailing) { // <3>
                Button(action: {
                    
                }) {
                    Text("Select")
                        .font(.regularFont(16))
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    var mediaList: some View {
        Group {
            if let observedData = observed.mediaData, observedData.count>0 {
                ScrollView {
                    ForEach(Array(observedData), id: \.key) { str, data in
                        Section(header: HStack { Text(str).font(.regularFont(14)).foregroundColor(.gray)
                            Spacer() }.textCase(nil)) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
                                    ForEach(data, id: \.self) { data in
                                        NavigationLink(destination: ShowImage(url: data.media).toolbar(.hidden, for: .tabBar), label: {
                                            ImageDownloader(data.media)
                                                .scaledToFill()
                                                .frame(height: 110)
                                                .cornerRadius(5)
                                        })
                                    }
                                }
                            }
                    }
                }
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "photo").resizable().frame(maxWidth: 40, maxHeight: 40).foregroundColor(.gray)
                    Text("No Media").font(.semiBoldFont(18))
                    Text("Tap + to share media with \(userDetails?.name ?? "")").font(.regularFont(16))
                    Spacer()
                }
            }
        }
        .padding()
    }

    var linksList: some View {
        Group {
            if let observedData = observed.linksData, observedData.count>0 {
                List {
                    ForEach(Array(observedData), id: \.key) { str, data in
                        Section(header: HStack { Text(str).font(.regularFont(14)).foregroundColor(.gray)
                                                Spacer() }.textCase(nil)) {
                            ForEach(data, id: \.self) { data in
                                if let media = data.media {
                                    Link(media, destination: URL(string: media)!)
                                }
                            }
                        }
                    }
                }.listStyle(.grouped).scrollContentBackground(.hidden).background(Color(.systemBackground))
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "link").resizable().frame(maxWidth: 40, maxHeight: 40).foregroundColor(.gray)
                    Text("No Links").font(.semiBoldFont(18))
                    Text("Links you send and receive with \(userDetails?.name ?? "") will appear here.").font(.regularFont(16))
                    Spacer()
                }
            }
        }
    }

    var docsList: some View {
        Group {
            if let observedData = observed.docsData, observedData.count>0 {
                List {
                    ForEach(Array(observedData), id: \.key) { str, data in
                        Section(header: HStack { Text(str).font(.regularFont(14)).foregroundColor(.gray)
                                                Spacer() }.textCase(nil)) {
                            ForEach(data, id: \.self) { data in
                                if let media = data.media {
                                    let mediaUrl = URL(string: media)!
                                    NavigationLink(destination: WebView(url: mediaUrl).navigationTitle(mediaUrl.lastPathComponent).toolbar(.hidden, for: .tabBar), label: {
                                        DocListView(data: data)
                                    })
                                }
                            }
                        }
                    }
                }.listStyle(.grouped).scrollContentBackground(.hidden).background(Color(.systemBackground))
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "doc.fill").resizable().frame(maxWidth: 40, maxHeight: 40).foregroundColor(.gray)
                    Text("No Documents").font(.semiBoldFont(18))
                    Text("Tap + to share documents with \(userDetails?.name ?? "")").font(.regularFont(16))
                    Spacer()
                }
            }
        }
    }
}

struct MediaLinksDocs_Previews: PreviewProvider {
    static var previews: some View {
        MediaLinksDocs()
    }
}
