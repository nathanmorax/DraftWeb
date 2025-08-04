//
//  WebView.swift
//  DraftWeb
//
//  Created by Jonathan Mora on 04/08/25.
//
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    
    var url: URL
    
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
        
        context.environment.webViewBox?.value = nsView
        
        if nsView.url != url {
            let request = URLRequest(url: url)
            nsView.load(request)
        }
    }
}

struct WebViewReader<Content: View>: View {
    @State private var proxy: WebViewProxy = WebViewProxy()
    @ViewBuilder var content: (WebViewProxy) -> Content
    var body: some View {
        content(proxy)
            .environment(\.webViewBox, proxy.box)
    }
}


struct WebViewProxy {
    
    var box: Box<WKWebView?> = Box(nil)
    
    @MainActor
    func takeSnapshot() async throws-> NSImage {
        guard let w = box.value else { throw NoWebViewError()}
        return try await w.takeSnapshot(configuration: nil)
        
    }
    
}

extension EnvironmentValues {
    
    @Entry var webViewBox: Box<WKWebView?>?
}
