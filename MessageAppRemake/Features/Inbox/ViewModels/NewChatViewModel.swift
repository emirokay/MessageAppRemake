//
//  NewChatViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 2.12.2024.
//

import Foundation
import FirebaseFirestore
import Combine

class NewChatViewModel: ObservableObject {
	@Published var users: [User] = []
	private let chatRepository: ChatRepositoryProtocol
	private let appState: AppStateProtocol
	private var currentUserId: String?
	private var cancellables = Set<AnyCancellable>()
	@Published var newChat: Chat?
	
	init(chatRepository: ChatRepositoryProtocol = ChatRepository(),
		 userService: UserServiceProtocol = UserService.shared,
		 appState: AppStateProtocol = AppState.shared) {
		self.chatRepository = chatRepository
		self.appState = appState
		setupSubscribers(userService: userService)
		fetchUsers()
	}
	
	private func setupSubscribers(userService: UserServiceProtocol) {
		userService.currentUserPublisher
			.compactMap { $0?.id }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] userId in
				self?.currentUserId = userId
			}
			.store(in: &cancellables)
	}
	
	func fetchUsers() {
		appState.setLoading(true)
		Task {
			do {
				let allUsers = try await chatRepository.fetchUsers()
				DispatchQueue.main.async {
					self.users = allUsers.filter { $0.id != self.currentUserId }
				}
			} catch {
				self.appState.setError("Error Fetching Users", error.localizedDescription)
			}
			self.appState.setLoading(false)
		}
	}
	
	func filteredUsers(searchText: String) -> [User] {
		users.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
	}
	
	func startChat(with user: User) {
		guard let currentUserId else { return }
		
		appState.setLoading(true)
		let chatId = generateChatId(user1: currentUserId, user2: user.id)
		Task {
			do {
				if let existingChat = try await chatRepository.fetchChat(chatId: chatId) {
					DispatchQueue.main.async {
						self.newChat = existingChat
					}
				} else {
					let newChat = Chat(
						id: chatId,
						type: .individual,
						name: user.name,
						members: [currentUserId, user.id],
						lastMessage: "",
						lastMessageBy: "",
						lastMessageAt: Date(),
						isPinned: false,
						isMuted: false,
						isRead: false,
						unreadCount: 0,
						messages: []
					)
					try await chatRepository.createChat(chat: newChat)
					self.newChat = newChat
				}
			} catch {
				appState.setError("Error Starting Chat", error.localizedDescription)
			}
			appState.setLoading(false)
		}
	}
	
	private func generateChatId(user1: String, user2: String) -> String {
		return [user1, user2].sorted().joined(separator: "_")
	}
}
