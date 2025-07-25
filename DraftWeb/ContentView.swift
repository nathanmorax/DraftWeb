//
//  ContentView.swift
//  DraftWeb
//
//  Created by Jonathan Mora on 23/07/25.
//

import SwiftUI
import Observation
import WebKit

struct Page: Identifiable, Hashable {
    var id = UUID()
    var url: URL
}
@Observable
class Store {
    var pages: [Page] = [
        .init(url: .init(string: "https://www.objc.io")!),
        .init(url: .init(string: "https://www.apple.com")!)
        
    ]
    
    func submit(_ url: URL) {
        
        pages.append(Page(url: url))
        
    }
}

class Box<A> {
    var value: A
    
    init(_ value: A) {
        self.value = value
    }
}

struct NoWebViewError: Error { }

struct WebViewProxy {
    
    var box: Box<WKWebView?> = Box(nil)
    
    func takeSnapshot() async throws-> NSImage {
        guard let w = box.value else { throw NoWebViewError()}
        return try! await w.takeSnapshot(configuration: nil)
    }
}

extension EnvironmentValues {
    
    @Entry var webViewBox: Box<WKWebView?>?
}

struct WebViewReader<Content: View>: View {
    @State private var proxy: WebViewProxy = WebViewProxy()
    @ViewBuilder var content: (WebViewProxy) -> Content
    var body: some View {
        content(proxy)
            .environment(\.webViewBox, proxy.box)
    }
}

struct WebView: NSViewRepresentable {
    
    var url: URL
    var snapShot: (_ takeSnapshot: @escaping () async -> NSImage) -> ()
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
    }
    
    func makeCoordinator() -> Coordinator {
        .init()
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let result = WKWebView()
        result.navigationDelegate = context.coordinator
        return result
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        assert(Thread.isMainThread)
        
        context.environment.webViewBox?.value = nsView
        
        snapShot({
            assert(Thread.isMainThread)
            return try! await nsView.takeSnapshot(configuration: nil)
        })
        
        if nsView.url != url {
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }
}

// TODO: - Check in Pattern Proxy( remove)
extension NSImage: @unchecked Sendable { }

struct ContentView: View {
    
    @State var store = Store()
    @State var currentURLString: String = "https://www.objc.io"
    @State var selectedPage: Page.ID?
    @State var image: NSImage?
    @State var takeSnapshot: (() async -> NSImage)?
    
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $selectedPage) {
                ForEach(store.pages) { page in
                    Text(page.url.absoluteString)
                }
            }
        }, detail: {
            
            if let s = selectedPage, let page = store.pages.first(where: { $0.id == s }) {
                
                WebViewReader { proxy in
                    WebView(url: page.url, snapShot: { takeSnapshot in
                        self.takeSnapshot = takeSnapshot
                    })
                    .toolbar {
                        Button("Snapdshot Alt") {
                            Task {
                                image = try await proxy.takeSnapshot()
                            }
                        }
                    }
                }
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
            ToolbarItem(placement: .principal) {
                TextField("URL" ,text: $currentURLString)
                    .onSubmit {
                        if let url = URL(string: currentURLString) {
                            currentURLString = ""
                            store.submit(url)
                        }
                    }
            }
            
            ToolbarItem {
                Button("Take a Snapshot") {
                    Task {
                        image = await takeSnapshot?()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
