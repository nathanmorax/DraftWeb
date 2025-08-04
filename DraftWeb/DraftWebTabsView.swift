//
//  DraftWebTabsView.swift
//  DraftWeb
//
//  Created by Jonathan Mora on 04/08/25.
//

import SwiftUI

struct DraftWebTabsView: View {
    @Binding var store: Store
    @Binding var selectedPage: Page.ID?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.pages) { page in
                    DraftWebTabView(
                        page: page,
                        isSelected: selectedPage == page.id,
                        onSelect: {
                            selectedPage = page.id
                        },
                        onClose: {
                            store.pages.removeAll { $0.id == page.id }
                            if selectedPage == page.id {
                                selectedPage = store.pages.last?.id
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 30)
    }
}

struct DraftWebTabView: View {
    let page: Page
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Button {
                onSelect()
            } label: {
                HStack(spacing: 6) {
                    
                    Text(page.url.absoluteString)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: 120) // Limita el ancho máximo
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? Color.gray.opacity(0.3) : Color.clear)
                .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        )
    }
}

#Preview {
    @State var store = Store()
    @State var selectedPage: Page.ID? = nil
    
    return DraftWebTabsView(store: $store, selectedPage: $selectedPage)
        .padding()
}
