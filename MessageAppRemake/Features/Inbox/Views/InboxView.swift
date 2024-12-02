//
//  InboxView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 26.11.2024.
//

import SwiftUI

struct InboxView: View {
	@ObservedObject var viewModel: InboxViewModel
	@State private var searchText = ""
	@State private var showNewChatView = false
	
	var body: some View {
		
		NavigationStack {
			List {
				// Search Bar
				SearchBarView(searchText: $searchText)
				
				// Filtered Chats
				ForEach(viewModel.filteredChats(searchText: searchText)) { chat in
					// Navigate to selected chat
					NavigationLink(destination: MessagesView(chat: chat)) {
						// Chat row view
						InboxChatRowView(chat: chat)
					}
				}
			}
			.listStyle(PlainListStyle())
			.navigationTitle("Chats")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						showNewChatView.toggle()
					} label: {
						Image(systemName: "plus.circle.fill")
							.font(.title2)
							.foregroundStyle(.blue)
					}
				}
			}
			.sheet(isPresented: $showNewChatView) {
				// Start new chat view
				NewChatView()
			}
		}
	}
}

#Preview {
	InboxView(viewModel: InboxViewModel())
}
