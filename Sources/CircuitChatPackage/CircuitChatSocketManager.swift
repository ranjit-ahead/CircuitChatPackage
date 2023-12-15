//
//  CircuitChatSocketManager.swift
//  Chat
//
//  Created by Apple on 22/08/23.
//

import Foundation
import SocketIO
import SwiftUI

enum CircuitChatSocketEvents: String {
    case chat_archived
    case chat_unarchived
    case message_deleted_everyone
    case message_deleted
    case conversation_deleted
    case message_received
    case message_seen
    case message_starred
    case message_unstarred
    case new_message
    case user_status
    case user_action
    case new_message_admin
    case chat_read
    case chat_unread
    case chat_mute
    case chat_unmute
    case chat_block
    case chat_unblock
    case blocked_me
    case unblocked_me
    case chat_pin
    case chat_unpin
    case unread_count
    case message_edited
}

class CircuitChatSocketManager: ObservableObject {
    private var manager: SocketManager?
    var defaultUserSocket: SocketIOClient?
    
    @Published var isConnected = false
    @Published var newMessageArray: [UserChatData]?
    @Published var activeFriendsData: [Chat]?
    @Published var messageDeleted: [MessageID]?
    @Published var messageDeletedEveryone: [UserChatData]?
    @Published var messageRecieved: [String]?
    @Published var messageSeen: [MessageID]?
    @Published var userAction: [UserAction]?
    
    @Published var chatArchived: SocketChatResponse?
    @Published var chatUnarchived: SocketChatResponse?
    @Published var conversationDeleted: SocketChatResponse?
    @Published var chatRead: SocketChatResponse?
    @Published var chatUnread: SocketChatResponse?
    @Published var chatMute: SocketChatResponse?
    @Published var chatUnmute: SocketChatResponse?
    @Published var chatBlock: SocketChatResponse?
    @Published var chatUnblock: SocketChatResponse?
    @Published var blockedMe: SocketChatResponse?
    @Published var unblockedMe: SocketChatResponse?
    @Published var chatPin: SocketChatResponse?
    @Published var chatUnpin: SocketChatResponse?
    
    @Published var unreadCount: SocketChatResponse?
    
    @Published var messageEdited: UserChatData?
    
    func connectSocket() {
        var config = SocketIOClientConfiguration()
//        config.insert(.log(true))
//        config.insert(.compress)
        config.insert(.forceWebsockets(true))
        config.insert(.connectParams(["token": circuitChatToken]))
        manager = SocketManager(socketURL: URL(string: circuitChatDomain)!, config: config)
        
        guard let socket = manager?.defaultSocket else { return }
        
        defaultUserSocket = socket
        
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
            self.isConnected = true
        }
        
        if !self.isConnected {
            socket.connect()
        }
        
        //MARK: New Message
        socketMapping(CircuitChatSocketEvents.new_message.rawValue, model: [UserChatData].self, completion: { type in
            self.newMessageArray = type
            
            if let userChatData = type.first {
                if let id = userChatData.id {
                    socket.emit(CircuitChatSocketEvents.message_received.rawValue, id)
                }
            }
        })
        
        //MARK: Message Edited
        socketMapping(CircuitChatSocketEvents.message_edited.rawValue, model: [UserChatData].self, completion: { type in
            if let userChatData = type.first {
                self.messageEdited = userChatData
            }
        })

        //MARK: Online Members
        socketMapping(CircuitChatSocketEvents.user_status.rawValue, model: [Chat].self, completion: { type in
            self.activeFriendsData = type
        })
        
        //MARK: Message deleted for me
        socketMapping(CircuitChatSocketEvents.message_deleted.rawValue, model: [MessageID].self, completion: { type in
            self.messageDeleted = type
        })
        
        //MARK: Message deleted for everyone
        socketMapping(CircuitChatSocketEvents.message_deleted_everyone.rawValue, model: [UserChatData].self, completion: { type in
            self.messageDeletedEveryone = type
        })
        
        //MARK: Message Recieved
        socketMapping(CircuitChatSocketEvents.message_received.rawValue, model: [String].self, completion: { type in
            self.messageRecieved = type
        })
        
        //MARK: Message Seen
        socketMapping(CircuitChatSocketEvents.message_seen.rawValue, model: [MessageID].self, completion: { type in
            self.messageSeen = type
        })
        
        //MARK: User Action
        socketMapping(CircuitChatSocketEvents.user_action.rawValue, model: [UserAction].self, completion: { type in
            self.userAction = type
        })
        
        //MARK: New Message Admin
//        socketMapping(SocketEvents.user_action.rawValue, model: [UserAction].self, completion: { type in
//            self.userAction = type
//        })
        
        //MARK: Chat Archived
        socketMapping(CircuitChatSocketEvents.chat_archived.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatArchived = type.first
        })
        
        //MARK: Chat Unarchived
        socketMapping(CircuitChatSocketEvents.chat_unarchived.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatUnarchived = type.first
        })
        
        //MARK: Chat get deleted
        socketMapping(CircuitChatSocketEvents.conversation_deleted.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.conversationDeleted = type.first
        })
        
        //MARK: Chat read
        socketMapping(CircuitChatSocketEvents.chat_read.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatRead = type.first
        })
        
        //MARK: Chat Unread
        socketMapping(CircuitChatSocketEvents.chat_unread.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatUnread = type.first
        })
        
        //MARK: Chat Mute
        socketMapping(CircuitChatSocketEvents.chat_mute.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatMute = type.first
        })
        
        //MARK: Chat Unmute
        socketMapping(CircuitChatSocketEvents.chat_unmute.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatUnmute = type.first
        })
        
        //MARK: Chat Block
        socketMapping(CircuitChatSocketEvents.chat_block.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatBlock = type.first
        })
        
        //MARK: Chat UnBlock
        socketMapping(CircuitChatSocketEvents.chat_unblock.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatUnblock = type.first
        })
        
        //MARK: Blocked Me
        socketMapping(CircuitChatSocketEvents.blocked_me.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.blockedMe = type.first
        })
        
        //MARK: UnBlock Me
        socketMapping(CircuitChatSocketEvents.unblocked_me.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.unblockedMe = type.first
        })
        
        //MARK: Chat Pin
        socketMapping(CircuitChatSocketEvents.chat_pin.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatPin = type.first
        })
        
        //MARK: Chat UnPin
        socketMapping(CircuitChatSocketEvents.chat_unpin.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.chatUnpin = type.first
        })
        
        //MARK: Unread chat count
        socketMapping(CircuitChatSocketEvents.unread_count.rawValue, model: [SocketChatResponse].self, completion: { type in
            self.unreadCount = type.first
        })
        
        //MARK: Message Starred
//        socketMapping(SocketEvents.message_starred.rawValue, model: [].self, completion: { type in
//            
//        })

        //MARK: Socket Disconnect
        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected")
            self.isConnected = false
        }
    }
    
    func socketMapping<T: Codable>(_ socketName: String, model: T.Type, completion: @escaping (T) -> Void) {
        defaultUserSocket?.on(socketName) { socketResponse, ack in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: socketResponse, options: [])
                do  {
                    let message = try JSONDecoder().decode(model, from: jsonData)
                   
                    completion(message)
                } catch {
                    print(error)
                    print(error.localizedDescription)
                }
            } catch {
                print(error)
                print(error.localizedDescription)
            }
        }
    }
}
