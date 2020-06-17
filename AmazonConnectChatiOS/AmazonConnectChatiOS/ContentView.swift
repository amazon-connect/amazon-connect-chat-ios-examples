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

import SwiftUI

struct ContentView: View {
    @State private var message: String = ""
    @State var websocketManager: WebsocketManager!
    @State var messages: [Message] = []
    
    var chatWrapper = ChatWrapper()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    print("start chat button clicked")
                    self.chatWrapper.startChatContact(name: "Customer")
                    self.chatWrapper.createParticipantConnection()
                    print("connected to participant")
                    self.websocketManager = WebsocketManager(
                        wsUrl: self.chatWrapper.websocketUrl!,
                        onRecievedMessage: {
                            [self] message in
                            print("Received message: \(message)")
                            self.messages.append(message)
                    })
                }) {
                    Text("Start Chat")
                        .fontWeight(.bold)
                        .font(.body)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .padding(10)
                }
                Button(action: {
                    print("end chat button clicked")
                    self.chatWrapper.endChat()
                }) {
                    Text("End Chat")
                        .fontWeight(.bold)
                        .font(.body)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .padding(10)
                }
            }
            
            Button(action: {
                print("send chat button clicked with \(self.message)")
                self.chatWrapper.sendChatMessage(messageContent: self.message)
            }) {
                Text("Send Chat")
                    .fontWeight(.bold)
                    .font(.body)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .padding(10)
            }
            
            TextField("Enter your chat message here", text: $message)
                .padding(10)
            Text("Messages received in the chat will show up here:")
                .padding(10)
            List (messages) { message in
                Text("\(message.participant): \(message.text)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
