//
//  MapView.swift
//  Chat
//
//  Created by Apple on 18/10/23.
//

import Foundation
import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var lastKnownLocation: CLLocation?
    
    var mapView: MapView?

    func startUpdating() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        lastKnownLocation = locations.last
        if mapView?.latitude == "" || mapView?.latitude == nil {
            mapView?.latitude = "\(lastKnownLocation!.coordinate.latitude)"
            mapView?.longitude = "\(lastKnownLocation!.coordinate.longitude)"
            mapView?.fetchLocation()
        }
        mapView?.latitude = "\(lastKnownLocation!.coordinate.latitude)"
        mapView?.longitude = "\(lastKnownLocation!.coordinate.longitude)"
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}

struct Venue: Codable, Hashable {
    let image, title, desc, lat, lng: String
    // Add other properties you need
}

struct MapView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var locationProvider = LocationManager()
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @State private var searchText = ""
    
    @State private var venues: [Venue] = []
    
    var latitude: String?
    var longitude: String?
    
    var userChat: Chat?
    
    func fetchLocation() {
        let lat = "\(locationProvider.lastKnownLocation!.coordinate.latitude)"
        let lng = "\(locationProvider.lastKnownLocation!.coordinate.longitude)"
        circuitChatRequest("https://maps.googleapis.com/maps/api/place/search/json?&location=\(lat),\(lng)&radius=5000&sensor=false&key=AIzaSyBqpvO9b57QaoWD_OsDlmu-2ILU8KjCBlA&keyword=\(searchText)", method: .get, model: NearByLocationResponse.self, completion: { result in
            switch result {
            case .success(let data):
                venues.removeAll()
                for result in data.results {
                    venues.append(Venue(image: result?.icon ?? "", title: result?.name ?? "", desc: result?.vicinity ?? "", lat: "\(result?.geometry.location.lat ?? 0)", lng: "\(result?.geometry.location.lng ?? 0)"))
                }
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        })
    }
    
    func sendMessage(locationType: String, lat: String, lng: String, duration: Int = 0, text: String = "") {

        var bodyData: [String:Any] = [
            "to" : userChat?.id ?? "",
            "receiverType" : userChat?.chatType ?? "",
            "type" : "location",
            "location[locationType]" : locationType,
            "location[latitude]" : lat,
            "location[longitude]" : lng
        ]
        
        if duration>0{
            bodyData["location[duration]"] = duration
        }
        
        if text != "" {
            bodyData["text"] = text
        }
        
        circuitChatRequest("/message", method: .post, bodyData: bodyData, dataType: "form-data", model: UserChatData.self) { result in
            switch result {
            case .success(let data):
                print("success")
            case .failure(let error):
                print("Error fetching chat messages: \(error.localizedDescription)")
            }
        }
    }
    
    var duration = ["15 Minutes", "1 Hour", "8 Hours"]
    @State private var selectedDuration = "15 Minutes"
    
    @State private var showTimerList = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: .constant(.follow))
                //                .overlay(content: {
                //                    AsyncImage(
                //                        url: URL(string: userChat?.avatar ?? "https://picsum.photos/200"),
                //                        content: { image in
                //                            image
                //                                .resizable()
                //                                .frame(maxWidth: 60, maxHeight: 60)
                //                                .aspectRatio(contentMode: .fill)
                //                                .clipShape(Circle())
                //                        },
                //                        placeholder: {
                //                            //ProgressView()
                //                        }
                //                    ).background(
                //                        RoundedRectangle(cornerRadius: 30)
                //                            .stroke(.white, lineWidth: 3)
                //                    ).offset(x: 0, y: -35)
                //                })
                    .padding(.horizontal, 0)
                
                if showTimerList {
                    
                    VStack {
                        Picker("", selection: $selectedDuration) {
                            ForEach(duration, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(.inline).scaledToFit()
                        HStack {
                            TextField("", text: $searchText,  axis: .vertical)
                                .placeholder(when: searchText.isEmpty) {
                                    Text("Add a caption").foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.58))
                                }
                                .padding()
                                .frame(height: 44)
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                            
                            Button{
                                
                                let lat = "\(locationProvider.lastKnownLocation!.coordinate.latitude)"
                                let lng = "\(locationProvider.lastKnownLocation!.coordinate.longitude)"
                                let durationTime = selectedDuration=="15 Minutes" ? 15 : selectedDuration=="1 Hour" ? 60 : 240
                                
                                sendMessage(locationType: "live_location", lat: lat, lng: lng, duration: durationTime, text: searchText)
                                dismiss()
                            } label: {
                                Image("sendIcon")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 44, height: 44)
                                    .clipped()
                            }
                        }
                        HStack(spacing: 0) {
                            Spacer()
                            Image("rightArrow")
                                .resizable()
                                .frame(width: 17, height: 17)
                            Text(userChat?.name ?? "")
                                .font(.regularFont(15))
                              
                        }.foregroundColor(Color(red: 0.59, green: 0.59, blue: 0.59))
                    }.padding(10).background(Color(.secondarySystemBackground))
                    
                } else {
                    List {
                        LazyHStack {
                            Image("liveLocation")
                                .resizable()
                                .frame(width: 26, height: 26)
                                .aspectRatio(contentMode: .fit)
                            Text("Share Live Location")
                                .font(.semiBoldFont(16))
                                .multilineTextAlignment(.center)
                        }.foregroundColor(.blue)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showTimerList.toggle()
                            }
                        
                        Section(header: Text("Nearby Places").textCase(nil)) {
                            
                            LazyHStack {
                                Image("currentLocation")
                                    .resizable()
                                    .frame(width: 42, height: 42)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.blue)
                                Text("Send your Current Location")
                                    .font(.semiBoldFont(15))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                let lat = "\(locationProvider.lastKnownLocation!.coordinate.latitude)"
                                let lng = "\(locationProvider.lastKnownLocation!.coordinate.longitude)"
                                sendMessage(locationType: "location", lat: lat, lng: lng)
                                dismiss()
                            }
                            
                            ForEach(venues, id: \.self) { venue in
                                HStack {
                                    ImageDownloader(venue.image)
                                        .padding(10)
                                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                                        .frame(width: 42, height: 42)
                                        .clipShape(Circle())
                                    LazyVStack(alignment: .leading) {
                                        Text(venue.title)
                                            .font(.semiBoldFont(13))
                                        Text(venue.desc)
                                            .font(.semiBoldFont(13))
                                            .foregroundColor(Color(red: 0.44, green: 0.44, blue: 0.44))
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    sendMessage(locationType: "location", lat: venue.lat, lng: venue.lng, text: venue.title)
                                    dismiss()
                                }
                            }
                        }
                    }
                    .onAppear {
                        locationProvider.mapView = self
                        locationProvider.startUpdating()
                    }
                    .listStyle(.grouped)
                    .searchable(text: $searchText)
                    .onSubmit(of: .search) {
                        fetchLocation()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(showTimerList ? "Share Live Location" : "Send Location")
                }
                if !showTimerList {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            fetchLocation()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
            }
        }
        
    }
}
