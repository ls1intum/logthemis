//
//  MessageRowView.swift
//  Logthemis
//
//  Created by Markus Paulsen on 18.11.23.
//

import SwiftUI

struct MessageRowView: View {
    let message: String
    let isRequest: Bool
    var isError: Bool
    
    func getCurrentDate() -> String {
        let currentDate = Date()
        let formater : DateFormatter = DateFormatter()
        formater.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formater.string(from: currentDate)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(getCurrentDate())
                    .foregroundColor(Color.gray)
                    .font(.custom("Courier New", size: 10))
                Text(message)
                    .padding()
                    .foregroundColor(isError ? .red : (isRequest ? .green : .blue))
                    .font(.custom("Courier New", size: 15))
                    .background(
                        RoundedRectangle(cornerRadius: 8.0)
                            .stroke(isError ? .red : (isRequest ? .green : .blue), lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    .listRowSeparator(.hidden)
                    .overlay(alignment: isRequest ? .bottomTrailing : .bottomLeading) {
                        Image(systemName: "arrowtriangle.down")
                            .rotationEffect(isRequest ? .degrees(325.0) : .degrees(45.0))
                            .offset(x: isRequest ? 6.7 : -6.7, y: 6.7)
                            .foregroundColor(isError ? .red : (isRequest ? .green : .blue))
                    }
            }.frame(maxWidth: .infinity, alignment: isRequest ? .trailing : .leading).padding()
            Spacer()
            
        }
    }
}

#Preview {
    MessageRowView(message: "Test", isRequest: false, isError: true)
}
