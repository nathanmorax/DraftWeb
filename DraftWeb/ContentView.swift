//
//  ContentView.swift
//  DraftWeb
//
//  Created by Jonathan Mora on 23/07/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var store = Store()
    @State var currentURLString: String = "https://www.objc.io"
    @State var selectedPage: Page.ID?
    @State var image: NSImage?
    
    var body: some View {
        WebViewReader { proxy in
            NavigationSplitView(sidebar: {
                List(selection: $selectedPage) {
                    ForEach(store.pages) { page in
                        Text(page.url.absoluteString)
                    }
                }
            }, detail: {
                
                if let s = selectedPage, let page = store.pages.first(where: { $0.id == s }) {
                    
                    WebView(url: page.url)
                        .overlay {
                            if let i = image {
                                Image(nsImage: i)
                                    .scaleEffect(0.5)
                                    .border(Color.red)
                            }
                        }
                    
                } else {
                    ContentUnavailableView("No Page Selected", systemImage: "globe")
                }
                
            })
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    BrowserToolbarView(store: $store, selectedPage: $selectedPage)
                    
                    
                }
                
                // Botón para tomar snapshot
                
                ToolbarItem(placement: .primaryAction) {
                    
                    DraftWebTabsRightView(store: $store, selectedPage: $selectedPage) {
                        image = try await proxy.takeSnapshot()
                        return image!
                        
                    }
                }
                
            }
            
        }
    }
}


#Preview {
    ContentView()
}
