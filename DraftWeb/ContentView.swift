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
@MyGlobalActor
class Store {
    var pages: [Page] = []
    
    nonisolated init () {
        
    }
    
    func submit(_ url: URL) {
        
        pages.append(Page(url: url))
        
    }
}

@globalActor
actor MyGlobalActor {
    static let shared = MyGlobalActor()
}

struct ContentView: View {
    
    @State var store = Store()
    @State var currentURLString: String = "https://www.objc.io"
    @State var selectedPage: Page.ID?
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $selectedPage) {
                ForEach(store.pages) { page in
                    Text(page.url.absoluteString)
                }
            }
        }, detail: {
            
            if let page = selectedPage {
                Text(page.uuidString)

            } else {
                ContentUnavailableView("No Page Selected", systemImage: "globe")
            }
            
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                TextField("URL" ,text: $currentURLString)
                    .onSubmit {
                        if let url = URL(string: currentURLString) {
                            currentURLString = ""
                            Task {
                                await store.submit(url)
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
