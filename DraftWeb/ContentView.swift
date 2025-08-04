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
                // Barra de pestañas
                ToolbarItem(placement: .navigation) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(store.pages) { page in
                                HStack(spacing: 4) {
                                    Button(action: {
                                        selectedPage = page.id
                                    }) {
                                        Text(page.url.host() ?? "Nueva pestaña")
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(selectedPage == page.id ? Color.gray.opacity(0.3) : Color.clear)
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    Button(action: {
                                        store.pages.removeAll { $0.id == page.id }
                                        if selectedPage == page.id {
                                            selectedPage = store.pages.last?.id
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedPage == page.id ? Color.blue.opacity(0.2) : Color.clear)
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: 30)
                }

                // Campo para ingresar URL
               /* ToolbarItem(placement: .principal) {
                    TextField("URL", text: $currentURLString)
                        .onSubmit {
                            if let url = URL(string: currentURLString) {
                                store.submit(url)
                                selectedPage = store.pages.last?.id
                                currentURLString = ""
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 400)
                }*/

                // Botón para tomar snapshot
                
                ToolbarItem {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem {
                    Button {
                        Task {
                            image = try await proxy.takeSnapshot()
                        }
                    } label: {
                        Image(systemName: "camera")
                    }
                }
            }

        }
    }
}


#Preview {
    ContentView()
}
