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

public var scoreObs = PublishSubject<[String: Any]>()

class WebSocketIO {
    
    static var manager = SocketManager(socketURL: URL(string: "http://104.196.60.173:3000")!, config: [.log(true), .compress])
    
    class func scoreWebSocket() {
        
//        let manager = SocketManager(socketURL: URL(string: "http://104.196.60.173:3000")!, config: [.log(true), .compress])
        
        let socket = manager.defaultSocket
        
        socket.connect()
        
        socket.on(clientEvent: .connect){ data, ack in
            print("Conect")
            print(data)
            print(ack)
        }
        
        socket.on("/score") { data, ack in
            guard let scoreJSON = data as? Array<[String: Any]> else { return }
            
            scoreObs.onNext(scoreJSON[0])
            
//            if let score = scoreJSON[0]["score"] as? Int {
//                print(score)
//            }
            
        }
        
//        socket.emit("algo", <#T##items: SocketData...##SocketData#>)
        
    }
}
