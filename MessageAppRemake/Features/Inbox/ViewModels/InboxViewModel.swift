//
//  InboxViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import Foundation
import FirebaseFirestore
import Combine

class InboxViewModel: ObservableObject {
	@Published var chats: [Chat] = []
	@Published var users: [User] = []
	@Published var currentUserId: String?
	
	private let chatStore: ChatStoreProtocol
	private let chatRepository: ChatRepositoryProtocol
	private var cancellables = Set<AnyCancellable>()
	
	init(userService: UserServiceProtocol = UserService.shared,
		chatStore: ChatStoreProtocol = ChatStore.shared,
		chatRepository: ChatRepositoryProtocol = ChatRepository.shared) {
		self.chatStore = chatStore
		self.chatRepository = chatRepository
		setupSubscribers(userService: userService)
	}
	
	private func setupSubscribers(userService: UserServiceProtocol) {
		userService.currentUserPublisher
			.compactMap { $0?.id }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] userId in
				self?.currentUserId = userId
				self?.chatStore.setCurrentUserId(userId)
			}
			.store(in: &cancellables)
		
		chatStore.chatsPublisher
			.assign(to: &$chats)
		
		chatStore.usersPublisher
			.assign(to: &$users)
	}
	
	func filteredChats(searchText: String) -> [Chat] {
		let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !searchText.isEmpty else { return chats }
		
		return chats.filter { chat in
			let chatName = chat.chatName(for: currentUserId ?? "", users: users)
			return chatName.localizedCaseInsensitiveContains(searchText)
		}
	}
	
	func togglePin(chat: Chat) {
		updateChat(chat: chat) { chat, currentUserId in
			if chat.isPinned.contains(currentUserId) {
				chat.isPinned.removeAll { $0 == currentUserId }
			} else {
				chat.isPinned.append(currentUserId)
			}
		}
	}

	func toggleMute(chat: Chat) {
		updateChat(chat: chat) { chat, currentUserId in
			if chat.isMuted.contains(currentUserId) {
				chat.isMuted.removeAll { $0 == currentUserId }
			} else {
				chat.isMuted.append(currentUserId)
			}
		}
	}

	private func updateChat(chat: Chat, updateAction: (inout Chat, String) -> Void) {
		guard let currentUserId else { return }
		var mutableChat = chat
		updateAction(&mutableChat, currentUserId)
		
		Task {
			try await chatRepository.uploadChatData(chat: mutableChat)
		}
	}

}
