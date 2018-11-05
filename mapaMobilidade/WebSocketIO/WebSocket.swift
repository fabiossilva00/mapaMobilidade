//
//  WebSocket.swift
//  mapaMobilidade
//
//  Created by fabio.sousa on 05/11/2018.
//  Copyright © 2018 Fabio Sousa. All rights reserved.
//

import Foundation
import SocketIO
import RxCocoa
import RxSwift

class WebSocketa {
    
    class func scoreWebSocket() {
        
        let manager = SocketManager(socketURL: URL(string: "http://104.196.60.173:3000")!)
        let socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect){ data, ack in
            print("Conect")
            print(data)
            print(ack)
        }
        
        socket.on("score") { data, ack in
            print(data)
            print(ack)
        }
        
        socket.connect()
    }
}
