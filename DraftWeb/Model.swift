//
//  Page.swift
//  DraftWeb
//
//  Created by Jonathan Mora on 04/08/25.
//
import SwiftUI

struct Page: Identifiable, Hashable {
    var id = UUID()
    var url: URL
    var title: String?
}

struct NoWebViewError: Error { }
