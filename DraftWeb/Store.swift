//
//  Page.swift
//  DraftWeb
//
//  Created by Jonathan Mora on 04/08/25.
//
import SwiftUI

@Observable
class Store {
    var pages: [Page] = [
        .init(url: .init(string: "https://www.objc.io")!),
        .init(url: .init(string: "https://www.apple.com")!)
        
    ]
    
    func submit(_ url: URL) {
        pages.append(Page(url: url))
    }
    
    func remove(_ id: Page.ID) {
        pages.removeAll() { $0.id == id }
    }
}
