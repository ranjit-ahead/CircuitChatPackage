//
//  APIRequest.swift
//  Chat
//
//  Created by Apple on 25/08/23.
//

import Foundation
import Alamofire
import UIKit

func circuitChatRequest<T: Codable>(_ url: String, method: HTTPMethod, bodyData: Any? = nil, fileData: [String: Data]? = nil, dataType: String? = nil, dataExtension: String = "", model: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
    
    var parameters: [String: Any] = [:]
    if let bodyData = bodyData as? [String: Any] {
        parameters = bodyData
    }
    
    var headers: HTTPHeaders = [
        circuitChatClientIDKey: circuitChatClientID,
        circuitChatClientSecretKey: circuitChatClientSecret
    ]
    if circuitChatToken != "" {
        var bearerToken: HTTPHeader {
            return .authorization(bearerToken: circuitChatToken)
        }
        headers.add(bearerToken)
    } else {
        parameters.updateValue(circuitChatUID, forKey: circuitChatUIDKey)
    }
    
    let url = URL(string: "\(circuitChatDomain)/api"+url)!
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.headers = headers
    
    if method.rawValue == "POST" {
        if let fileData = fileData {
            let boundary = UUID().uuidString
            var body = Data()
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n")
                body.append("\r\n")
                body.append("\(value)")
                body.append("\r\n")
            }
            if let dataType = dataType {
                for (key, data) in fileData {
                    body.append("--\(boundary)\r\n")
                    body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).\(dataExtension)\"\r\n")
                    body.append("Content-Type: \(dataType)/\(dataExtension)\r\n")
                    body.append("\r\n")
                    body.append(data)
                    body.append("\r\n")
                }
            }
            body.append("--\(boundary)--")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            
        } else if dataType=="form-data" {
            let boundary = UUID().uuidString
            var body = Data()
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n")
                body.append("\r\n")
                body.append("\(value)")
                body.append("\r\n")
            }
            body.append("--\(boundary)--")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        } else {
            let jsonData = try! JSONSerialization.data(withJSONObject: bodyData ?? parameters)
            request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
        }
    } else if method.rawValue == "DELETE" {
        let jsonData = try! JSONSerialization.data(withJSONObject: bodyData ?? parameters)
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
    }
    
//    AF.request(request).responseDecodable(of: model) { response in
//        switch response.result {
//        case .success(let data):
//            print("Raw JSON Response: \(data)")
//            completion(.success(data))
//        case .failure(let error):
//            print("Error: \(error)")
//            completion(.failure(error))
//        }
//    }
    
    AF.request(request).response { response in
        do {
            let decoder = JSONDecoder()
            //decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print(utf8Text)
            }
            if let responseData = response.data {
                let root = try decoder.decode(model, from: responseData)
                completion(.success(root))
            }
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    .downloadProgress { progress in
        print(progress.fractionCompleted)
    }
    
//    AF.request(request).response { response in
//        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//            print("Data: \(utf8Text)")
//        }
//    }
    
//    AF.request(url, method: method.AFHTTPMethod, parameters: parameters, headers: headers).responseDecodable(of: model) { response in
//        switch response.result {
//        case .success(let data):
//            print("Raw JSON Response: \(data)")
//            completion(.success(data))
//        case .failure(let error):
//            print("Error: \(error)")
//            completion(.failure(error))
//        }
//    }
}

enum HTTPMethod: String {
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case query = "QUERY"
    case trace = "TRACE"
}

//extension HTTPMethod {
//    var AFHTTPMethod: Alamofire.HTTPMethod {
//        switch self {
//        case .connect: return .connect
//        case .delete: return .delete
//        case .get: return .get
//        case .head: return .head
//        case .options: return .options
//        case .patch: return .patch
//        case .post: return .post
//        case .put: return .put
//        case .query: return .query
//        case .trace: return .trace
//        }
//    }
//}
