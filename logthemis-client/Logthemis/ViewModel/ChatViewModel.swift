//
//  ChatViewModel.swift
//  Logthemis
//
//  Created by Markus Paulsen on 18.11.23.
//

import Foundation
import Alamofire
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [MessageModel] = [MessageModel(message: "Hi, I am Logthemis. How can I help you?", isRequest: false, isError: false)]
    
    func addRequest(message: String, sessionID: UUID, logFile: LogFileSelection, generating: Binding<Bool>) {
        messages.append(MessageModel(message: message, isRequest: true, isError: false))
        DispatchQueue.main.async {
            generating.wrappedValue = true
        }
        AF
            .request("https://logthemis.ase.cit.tum.de/", method: .get, parameters: ["message": message, "sessionId": sessionID, "logFile": logFile.rawValue])
            .responseString { response in
                DispatchQueue.main.async {
                    generating.wrappedValue = false
                }
                switch response.result {
                case .success(let success):
                    if(response.response?.statusCode == 200) {
                        self.messages.append(MessageModel(message: "\(success)", isRequest: false, isError: false))
                    } else {
                        self.messages.append(MessageModel(message: "An error occured during your request. Please try again or contact your favorite sysadmin.", isRequest: false, isError: true))
                    }
                    
                case .failure(_):
                    self.messages.append(MessageModel(message: "An error occured conntecting to the server. Please try again or contact your favorite sysadmin.", isRequest: false, isError: true))
                }
            }
    }
    func deleteAllRequests() {
        messages.removeAll()
        messages.append(MessageModel(message: "Hi, I am Logthemis. How can I help you?", isRequest: false, isError: false))
    }
}
