//
//  MessageModel.swift
//  Logthemis
//
//  Created by Markus Paulsen on 18.11.23.
//

import SwiftUI
import Foundation

struct MessageModel: Identifiable, Hashable {
    
    var id = UUID()
    var message: String
    var isRequest: Bool
    var isError: Bool
}
