//
//  LogFileSelection.swift
//  Logthemis
//
//  Created by Markus Paulsen on 18.11.23.
//

import Foundation

enum LogFileSelection: String, CaseIterable, Identifiable {
    case log1,log2,log3
    var id: Self { self }
}
