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
	
	@Published var currentUserId: String? //CHECK THIS MAYBE UNNECESSATY
	
	private let appState: AppStateProtocol
	private let chatStore: ChatStoreProtocol
	private var cancellables = Set<AnyCancellable>()
	
	init(userService: UserServiceProtocol = UserService.shared,
		 appState: AppStateProtocol = AppState.shared,
		 chatStore: ChatStoreProtocol = ChatStore.shared) {
		self.appState = appState
		self.chatStore = chatStore
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
		let normalizedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !normalizedSearchText.isEmpty else { return chats }
		
		return chats.filter { chat in
			let chatName = chat.chatName(for: currentUserId ?? "", users: users)
			return chatName.localizedCaseInsensitiveContains(normalizedSearchText)
		}
	}
	
	func pinChat(chatId: String) async throws {
		
	}
	
	func muteChat(chatId: String) async throws {
		
	}
	
}


