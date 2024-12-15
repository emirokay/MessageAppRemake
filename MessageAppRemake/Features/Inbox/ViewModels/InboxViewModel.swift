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
	private let userService: UserServiceProtocol
	private let chatRepository: ChatRepositoryProtocol
	private var cancellables = Set<AnyCancellable>()
	
	init(chatRepository: ChatRepositoryProtocol = ChatRepository(),
		 userService: UserServiceProtocol = UserService.shared,
		 appState: AppStateProtocol = AppState.shared) {
		self.chatRepository = chatRepository
		self.appState = appState
		self.userService = userService
		setupSubscribers(userService: userService)
	}
	
	private func setupSubscribers(userService: UserServiceProtocol) {
		userService.currentUserPublisher
			.compactMap { $0?.id }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] userId in
				self?.currentUserId = userId
				self?.fetchChats()
			}
			.store(in: &cancellables)
	}
	
	func fetchChats() {
		guard let currentUserId else { return }
		chatRepository.fetchChats(for: currentUserId)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				if case .failure(let error) = completion {
					self?.appState.setError("Error fetching chats", error.localizedDescription)
				}
			} receiveValue: { [weak self] chats in
				self?.chats = chats
				self?.fetchUsers(for: chats)
			}
			.store(in: &cancellables)
	   }
	
	private func fetchUsers(for chats: [Chat]) {
		let userIds = Set(chats.flatMap { $0.memberIds }.filter { $0 != currentUserId })

		chatRepository.fetchUsersInChats(for: Array(userIds))
			.receive(on: DispatchQueue.main)
			.sink { [weak self] completion in
				if case .failure(let error) = completion {
					self?.appState.setError("Error fetching users", error.localizedDescription)
				}
			} receiveValue: { [weak self] users in
				self?.users = users
			}
			.store(in: &cancellables)
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
		//guard let currentUserId else { return }
		//try await chatRepository.updateChat(chatId: chatId, fields: ["isPinned": true])
	}
	
	func muteChat(chatId: String) async throws {
		//guard let currentUserId else { return }
		//try await chatRepository.updateChat(chatId: chatId, fields: ["isMuted": true])
	}
	
}


