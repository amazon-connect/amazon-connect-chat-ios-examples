
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
import AWSConnect
import AWSConnectParticipant

class ChatWrapper {
    
    var connectSerivceClient: AWSConnect?
    var connectChatClient: AWSConnectParticipant?
    var participantToken: String?
    var connectionToken: String?
    var contactId: String?
    var websocketUrl: String?
    var instanceId  = "INSTANCE_ID" // TODO - fill in
    var contactFlowId = "CONTACT_FLOW_ID" // TODO - fill in
    
    init() {
        let credentials = AWSStaticCredentialsProvider(
                          accessKey: "ACCESS_KEY_ID", // TODO - fill in
                          secretKey: "SECRET_ACCESS_KEY_ID") // TODO - fill in
    
        let participantService = AWSServiceConfiguration(
                                     region: .USWest2, // TODO - update to the region your instance is in
                                     credentialsProvider: credentials)!
        let connectService = AWSServiceConfiguration(
                                 region: .USWest2,
                                 credentialsProvider: credentials)!
        AWSConnect.register(with: connectService, forKey: "test")
        AWSConnectParticipant.register(with: participantService, forKey: "test")
                
        connectSerivceClient = AWSConnect.init(forKey: "test")
        connectChatClient = AWSConnectParticipant.init(forKey: "test")

    }
    
    func startChatContact(name: String) {
        let startChatContactRequest = AWSConnectStartChatContactRequest()
        startChatContactRequest?.instanceId = self.instanceId
        startChatContactRequest?.contactFlowId = self.contactFlowId
              
        let participantDetail = AWSConnectParticipantDetails()
        participantDetail?.displayName = name
        startChatContactRequest?.participantDetails = participantDetail
        startChatContactRequest?.attributes = ["customerName": name, "username": "username"]
         
        connectSerivceClient?
          .startChatContact(startChatContactRequest!)
          .continueWith(block: {
            (task) -> Any? in
              self.participantToken = task.result!.participantToken
              self.contactId = task.result!.contactId
              return nil
            }
          ).waitUntilFinished()
    }
    
    func createParticipantConnection() {
        let createParticipantConnectionRequest = AWSConnectParticipantCreateParticipantConnectionRequest()
        createParticipantConnectionRequest?.participantToken = self.participantToken
        createParticipantConnectionRequest?.types = ["WEBSOCKET", "CONNECTION_CREDENTIALS"]
        
        connectChatClient?
            .createParticipantConnection(createParticipantConnectionRequest!)
            .continueWith(block: {
              (task) -> Any? in
                self.connectionToken = task.result!.connectionCredentials!.connectionToken
                self.websocketUrl = task.result!.websocket!.url
                  return nil
              }
            ).waitUntilFinished()

    }
    
    func sendChatMessage(messageContent: String) {
        let sendMessageRequest = AWSConnectParticipantSendMessageRequest()
        sendMessageRequest?.connectionToken = self.connectionToken
        sendMessageRequest?.content = messageContent
        sendMessageRequest?.contentType = "text/plain"
              
        connectChatClient?
          .sendMessage(sendMessageRequest!)
          .continueWith(block: {
            (task) -> Any? in
               return nil
          })

    }
    
    func sendTypingEvent() {
        let sendEventRequest = AWSConnectParticipantSendEventRequest()
        sendEventRequest?.connectionToken = self.connectionToken
        sendEventRequest?.contentType = "application/vnd.amazonaws.connect.event.typing"
              
        connectChatClient?
          .sendEvent(sendEventRequest!)
          .continueWith(block: {
            (task) -> Any? in
                 return nil
          })

    }
    
    func endChat() {
        let stopChatRequest = AWSConnectStopContactRequest()
        stopChatRequest?.instanceId = self.instanceId
        stopChatRequest?.contactId = self.contactId!
              
        connectSerivceClient?
          .stopContact(stopChatRequest!)
          .continueWith(block: {
            (task) -> Any? in
                  return nil
          }).waitUntilFinished()

    }
}
