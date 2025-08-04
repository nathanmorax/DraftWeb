//
//  DraftWebTabsView.swift
//  DraftWeb
//
//  Created by Jonathan Mora on 04/08/25.
//

import SwiftUI

struct BrowserToolbarView: View {
    @Binding var store: Store
    @Binding var selectedPage: Page.ID?
    @State private var addressBarText: String = ""
    
    // URL actual de la pestaña seleccionada
    private var currentPageURL: String {
        guard let selectedPage = selectedPage,
              let page = store.pages.first(where: { $0.id == selectedPage }) else {
            return ""
        }
        return page.url.absoluteString
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Barra de direcciones en el centro
            TextField("Enter URL or search", text: $addressBarText)
                .onSubmit {
                    navigateToURL()
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 300, maxWidth: 500)
                .onChange(of: selectedPage) { _, _ in
                    // Actualizar el texto cuando cambia la pestaña seleccionada
                    addressBarText = currentPageURL
                }
                .onAppear {
                    // Inicializar con la URL actual
                    addressBarText = currentPageURL
                }
            

        }
        .padding(.horizontal, 8)
        .frame(height: 40)
    }
    
    private func navigateToURL() {
        var urlString = addressBarText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Agregar https:// si no tiene protocolo
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            // Si no contiene punto, buscar en Google
            if !urlString.contains(".") && !urlString.isEmpty {
                urlString = "https://www.google.com/search?q=" + urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            } else {
                urlString = "https://" + urlString
            }
        }
        
        guard let url = URL(string: urlString) else { return }
        
        if let selectedPageID = selectedPage {
            // Navegar en la pestaña actual (actualizar URL existente)
            if let index = store.pages.firstIndex(where: { $0.id == selectedPageID }) {
                store.pages[index] = Page(url: url)
                store.pages[index].id = selectedPageID // Mantener el mismo ID
            }
        } else {
            // Crear nueva pestaña
            store.submit(url)
            selectedPage = store.pages.last?.id
        }
        
        addressBarText = url.absoluteString
    }
    
    private func createNewTab() {
        let defaultURL = URL(string: "https://www.google.com")!
        store.submit(defaultURL)
        selectedPage = store.pages.last?.id
        addressBarText = defaultURL.absoluteString
    }
}

#Preview {
    @State var store = Store()
    @State var selectedPage: Page.ID? = nil
    
    return BrowserToolbarView(
        store: $store,
        selectedPage: $selectedPage
    )
    .padding()
}


struct DraftWebTabsRightView: View {
    @Binding var store: Store
    @Binding var selectedPage: Page.ID?
    @State private var addressBarText: String = ""

    var onScreenshot: (() async throws -> NSImage)?
    
    var body: some View {
        
        HStack {
            
            Button {
                createNewTab()
            } label: {
                Image(systemName: "plus")
            }
            
            Button {
                Task {
                    if let onScreenshot = onScreenshot {
                        try await onScreenshot()
                    }
                }
                
            } label: {
                Image(systemName: "camera")
                
            }
        }
    }
    
    private func createNewTab() {
        let defaultURL = URL(string: "https://www.objc.io")!
        store.submit(defaultURL)
        selectedPage = store.pages.last?.id
        addressBarText = defaultURL.absoluteString
    }
}
