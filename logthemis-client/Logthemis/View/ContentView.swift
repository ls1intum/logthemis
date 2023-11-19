//
//  ContentView.swift
//  Logthemis
//
//  Created by Markus Paulsen on 17.11.23.
//

import SwiftUI
import Combine
import ActivityIndicatorView


struct ContentView: View {
    @ObservedObject var chat = ChatViewModel();
    @State private var newString = "";
    @State private var sessionID = UUID();
    @State private var logFileSelectionIndex: Int = 0;
    @State var generating = false;
    
    
    func getLogFileSelection(_ from: Int) -> LogFileSelection {
        let selections: [String] = LogFileSelection.allCases.map { $0.rawValue}
        return LogFileSelection(rawValue: selections[from]) ?? LogFileSelection.log1
    }
    
    // Taken from https://udaypatial.medium.com/scroll-to-bottom-of-a-list-of-items-swiftui-21ade9f2d46b
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView {
                    ScrollViewReader { scrollViewReader in
                        LazyVStack(alignment: .leading) {
                            ForEach(chat.messages, id: \.self) { message in
                                MessageRowView(message: message.message, isRequest: message.isRequest, isError: message.isError)
                                    .frame(maxWidth: .infinity)
                                    .id(message)
                            }
                        }
                        .onReceive(Just(chat.messages)) { _ in
                            withAnimation {
                                proxy.scrollTo(chat.messages.last, anchor: .bottom)
                            }
                        }
                    }
                    
                }
                if(generating) {
                    VStack {
                        Text("Stephan is typing")
                            .foregroundColor(Color.gray)
                            .font(.custom("Courier New", size: 10 * CGFloat(Constants.scaling)))
                        ActivityIndicatorView(isVisible: $generating, type:
                                .scalingDots(count: 3, inset: 2)).foregroundColor(.cyan)
                            .frame(width: 50.0, height: 50.0)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider().foregroundColor(.green).background(.green)
                VStack {
                    SegmentedPicker(items: LogFileSelection.allCases.map { $0.rawValue }, selection: self.$logFileSelectionIndex)
                    HStack {
                        Button(action: {
                            sessionID = UUID();
                            chat.deleteAllRequests()
                            newString = ""
                        }) {
                            Image(systemName: "trash")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.all, 5)
                        TextField("Send a message", text: $newString, onCommit: {
                            chat.addRequest(message: newString, sessionID: sessionID, logFile: getLogFileSelection(self.logFileSelectionIndex), generating: $generating)
                            newString = ""
                            
                        })
                        .padding(.all, 10)
                        .frame(minHeight: 25 * CGFloat(Constants.scaling))
                        .textFieldStyle(.plain)
                        .font(.custom("Courier New", size: 15 * CGFloat(Constants.scaling)))
                        .foregroundColor(.green)
                        .background(Color.clear)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.green, lineWidth: 1 * CGFloat( Constants.scaling))
                        )
                        //.padding(.all, 5)
                        Button(action: {
                            chat.addRequest(message: newString, sessionID: sessionID, logFile: getLogFileSelection(self.logFileSelectionIndex), generating: $generating)
                            newString = ""
                        }) {
                            Image(systemName: "paperplane")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.all, 5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    //.background(Color.black)
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    withAnimation {
                        proxy.scrollTo(chat.messages.last, anchor: .bottom)
                    }
                }//.background(Color.black)
            }
        }
    }
}

#Preview {
    ContentView()
}
