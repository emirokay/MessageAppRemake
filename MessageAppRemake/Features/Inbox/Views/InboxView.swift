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
	
	@State private var showSelectedChat = false
	@State private var selectedChat: Chat?
	
	var body: some View {
		NavigationStack {
			VStack {
				chatList
					.searchable(text: $searchText)
					.listStyle(PlainListStyle())
					.navigationTitle("Chats")
					.toolbar {
						ToolbarItem(placement: .topBarTrailing) {
							newChatButton
						}
					}
					.sheet(isPresented: $showNewChatView) {
						NewChatView(selectedChat: $selectedChat, showSelectedChat: $showSelectedChat)
					}
					.onAppear {
						viewModel.fetchChats()
					}
					.navigationDestination(isPresented: $showSelectedChat, destination: {
						if let chat = selectedChat {
							MessagesView(chat: chat)
						}
					})
			}
		}
	}
	
	private var chatList: some View {
		List {
			ForEach(viewModel.filteredChats(searchText: searchText)) { chat in
				let destination = MessagesView(chat: chat)
				NavigationLink(destination: destination) {
					InboxChatRowView(viewModel: viewModel, chat: chat)
						.swipeActions {
							pinButton(for: chat)
							muteButton(for: chat)
						}
				}
			}
		}
	}
	
	private var newChatButton: some View {
		Button {
			showNewChatView.toggle()
		} label: {
			Image(systemName: "plus.circle.fill")
				.font(.title2)
				.foregroundStyle(.blue)
		}
	}
	
	private func pinButton(for chat: Chat) -> some View {
		Button {
			
		} label: {
			Label("Pin chat", systemImage: chat.isPinned ? "pin.slash.fill" : "pin.fill")
		}
		.tint(.gray)
	}
	
	private func muteButton(for chat: Chat) -> some View {
		Button {
			
		} label: {
			Label("Mute", systemImage: chat.isMuted ? "bell.fill" : "bell.slash.fill")
		}
		.tint(.orange)
	}
}

#Preview {
	InboxView(viewModel: InboxViewModel())
}
