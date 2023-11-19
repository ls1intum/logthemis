//
//  MessageRowView.swift
//  Logthemis
//
//  Created by Markus Paulsen on 18.11.23.
//

import SwiftUI
import MarkdownUI

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
                    .font(.custom("Courier New", size: 10 * CGFloat(Constants.scaling)))
                Markdown(message)
                    .markdownTextStyle() {
                        FontFamily(.custom("Courier New"))
                        FontFamilyVariant(.monospaced)
                        FontSize(15 * CGFloat(Constants.scaling))
                        ForegroundColor(isError ? .red : (isRequest ? Constants.homeColor : Constants.awayColor))
                    }
                    .padding()
                    .foregroundColor(isError ? .red : (isRequest ? Constants.homeColor : Constants.awayColor))
                    .font(.custom("Courier New", size: 15 * CGFloat(Constants.scaling)))
                    .background(
                        RoundedRectangle(cornerRadius: 8.0)
                            .stroke(isError ? .red : (isRequest ? Constants.homeColor : Constants.awayColor), lineWidth: 2 * CGFloat(Constants.scaling))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    .listRowSeparator(.hidden)
                    .overlay(alignment: isRequest ? .bottomTrailing : .bottomLeading) {
                        Image(systemName: "arrowtriangle.down")
                            .rotationEffect(isRequest ? .degrees(325.0) : .degrees(45.0))
                            .offset(x: isRequest ? 6.7 : -6.7, y: 6.7)
                            .foregroundColor(isError ? .red : (isRequest ? Constants.homeColor : Constants.awayColor))
                    }
            }.frame(maxWidth: .infinity, alignment: isRequest ? .trailing : .leading).padding()
            Spacer()
            
        }
    }
}

#Preview {
    MessageRowView(message: "Hello", isRequest: false, isError: true)
}
