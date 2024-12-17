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
	@Published var allUsers: [User] = []
	@Published var chats: [Chat] = []
	@Published private var currentUser: User?
	@Published var newChat: Chat?
	
	private let chatRepository: ChatRepositoryProtocol
	private let chatStore: ChatStoreProtocol
	private let appState: AppStateProtocol
	private var cancellables = Set<AnyCancellable>()
	
	init(chatRepository: ChatRepositoryProtocol = ChatRepository(),
		 userService: UserServiceProtocol = UserService.shared,
		 chatStore: ChatStoreProtocol = ChatStore.shared,
		 appState: AppStateProtocol = AppState.shared) {
		self.chatRepository = chatRepository
		self.chatStore = chatStore
		self.appState = appState
		setupSubscribers(userService: userService)
		fetchUsers()
	}
	
	private func setupSubscribers(userService: UserServiceProtocol) {
		userService.currentUserPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: &$currentUser)
		
		chatStore.chatsPublisher
			.assign(to: &$chats)
		
	}
	
	func fetchUsers() {
		appState.setLoading(true)
		Task {
			do {
				let allUsers = try await chatRepository.fetchAllUsers()
				DispatchQueue.main.async {
					self.allUsers = allUsers.filter { $0.id != self.currentUser?.id }
				}
			} catch {
				self.appState.setError("Error Fetching Users", error.localizedDescription)
			}
			self.appState.setLoading(false)
		}
	}
	
	func filteredUsers(searchText: String) -> [User] {
		return allUsers.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
	}
	
	func startChat(with user: User) {
		guard let currentUser else { return }
		
		appState.setLoading(true)
		let chatId = generateChatId(user1: currentUser.id, user2: user.id)
		Task {
			do {
				if let existingChat = self.chats.first(where: { $0.id == chatId }) {
					await MainActor.run {
						self.newChat = existingChat
					}
				} else {
					let newChat = Chat(
						id: chatId,
						type: .individual,
						name: user.name,
						imageUrl: "",
						memberIds: [currentUser.id, user.id],
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
					await MainActor.run {
						self.newChat = newChat
					}
				}
			} catch {
				print(error)
				print(error.localizedDescription)
				appState.setError("Error Starting Chat", error.localizedDescription)
			}
			appState.setLoading(false)
		}
	}
	
	private func generateChatId(user1: String, user2: String) -> String {
		return [user1, user2].sorted().joined(separator: "_")
	}
}
