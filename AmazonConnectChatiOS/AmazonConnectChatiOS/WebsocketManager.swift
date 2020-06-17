
/**********************************************************************************************************************
 *  Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved                                            *
 *                                                                                                                    *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated      *
 *  documentation files (the "Software"), to deal in the Software without restriction, including without limitation   *
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and  *
 *  to permit persons to whom the Software is furnished to do so.                                                     *
 *                                                                                                                    *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO  *
 *  THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    *
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF         *
 *  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS *
 *  IN THE SOFTWARE.                                                                                                  *
 **********************************************************************************************************************/

import Foundation
import Starscream

class WebsocketManager : WebSocketDelegate {
    private let socket: WebSocket
    private let messageCallback: (Message)-> Void
    
    init(wsUrl: String, onRecievedMessage: @escaping (Message)-> Void) {
        self.messageCallback = onRecievedMessage
        self.socket = WebSocket(request: URLRequest(url: URL(string:wsUrl)!))
        self.socket.disableSSLCertValidation = true
        print("connecting to websocket")
        socket.delegate = self
        socket.connect()
        print("done")
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
        socket.write(string: "{\"topic\": \"aws/subscribe\", \"content\": {\"topics\": [\"aws/chat\"]}})")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let json = try? JSONSerialization.jsonObject(with: Data(text.utf8), options: []) as? [String: Any] {
            let content = json["content"]
            print (content)

            if let stringContent = content as? String,
                let innerJson = try? JSONSerialization.jsonObject(with: Data(stringContent.utf8), options: []) as? [String: Any] {
                let type = innerJson["Type"] as! String
                if type == "MESSAGE" {
                    let participantRole = innerJson["ParticipantRole"] as! String
                    let message = Message(
                      participant: participantRole,
                      text: innerJson["Content"] as! String)
                    messageCallback(message)
                } else if innerJson["ContentType"] as! String == "application/vnd.amazonaws.connect.event.chat.ended" {
                    let message = Message(
                      participant: "System Message",
                      text: "The chat has ended.")
                    messageCallback(message)
                }
            }
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("got some data: \(data.count)")
    }
}
