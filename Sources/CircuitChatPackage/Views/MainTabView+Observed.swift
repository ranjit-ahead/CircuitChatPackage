//
//  MainTabView+Observed.swift
//  Chat
//
//  Created by Apple on 13/09/23.
//

import Foundation

//extension MainTabView {
    class MainTabViewObserved: ObservableObject {
        @Published var apiResponse: MainTabViewData?
        
        var socketIO: CircuitChatSocketManager?
//        var menus: FetchMenus?
        
        func fetchApiData() {
            
            circuitChatRequest("/user/login-uid", method: .post, model: MainTabViewData.self) { result in
                switch result {
                case .success(let data):
                    circuitChatToken = data.token
                    self.apiResponse = data
                    self.socketIO?.connectSocket()
//                    self.menus?.fetchAPI()
                case .failure(let error):
                    print("Error fetching chat messages: \(error.localizedDescription)")
                }
            }
            
            //            let urlString = "/user/login-uid"
            //            let json = "{\"\(uIDKeyName)\":\"\(uID)\"}"
            //
            //            let url = URL(string: urlString)!
            //            let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
            //
            //            var request = URLRequest(url: url)
            //            request.httpMethod = HTTPMethod.post.rawValue
            //            request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            //            request.httpBody = jsonData
            //            request.headers = [
            //                clientIDKeyName: clientID,
            //                clientSecretKeyName: clientSecret
            //            ]
            
            //            AF.request(request).response { response in
            //                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
            //                    print("Data: \(utf8Text)")
            //                }
            //            }
            
        }
        
    }
//}

class FetchMenus: ObservableObject {
    
    var menus: Menus?
    
    func fetchAPI() {
//        sendRequest("/user/menu", method: .get, model: Menus.self) { result in
//            switch result {
//            case .success(let data):
//                self.menus = data
//            case .failure(let error):
//                print("Error fetching chat messages: \(error.localizedDescription)")
//            }
//        }
    }
}
