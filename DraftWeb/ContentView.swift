//
//  ContentView.swift
//  DraftWeb
//
//  Created by Jonathan Mora on 23/07/25.
//

import SwiftUI
import Observation

struct Page: Identifiable, Hashable {
    var id = UUID()
    var url: URL
}
@Observable
class Store {
    var pages: [Page] = []
    
    func submit(_ url: URL) {
        
        pages.append(Page(url: url))
        
    }
    
}
struct ContentView: View {
    
    @State var store = Store()
    @State var currentURLString: String = "https://www.objc.io"
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List {
                ForEach(store.pages) { page in
                    Text(page.url.absoluteString)
                }
            }
        }, detail: {
            Text("Detail View")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                TextField("URL" ,text: $currentURLString)
                    .onSubmit {
                        if let url = URL(string: currentURLString) {
                            store.submit(url)
                            currentURLString = ""
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
