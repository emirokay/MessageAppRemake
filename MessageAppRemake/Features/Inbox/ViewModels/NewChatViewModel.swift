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
	
	init(chatRepository: ChatRepositoryProtocol = ChatRepository.shared,
		 userService: UserServiceProtocol = UserService.shared,
		 chatStore: ChatStoreProtocol = ChatStore.shared,
		 appState: AppStateProtocol = AppState.shared) {
		self.chatRepository = chatRepository
		self.chatStore = chatStore
		self.appState = appState
		setupSubscribers(userService: userService)
		chatStore.fetchAllUsers()
	}
	
	private func setupSubscribers(userService: UserServiceProtocol) {
		userService.currentUserPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: &$currentUser)
		
		chatStore.chatsPublisher
			.assign(to: &$chats)
		
		chatStore.allUsersPublisher
			.assign(to: &$allUsers)
		
	}
	
	func filteredUsers(searchText: String) -> [User] {
		return allUsers.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
	}
	
	func startChat(with users: [User], chatName: String = "", imageData: Data? = nil) {
		guard let currentUser else { return }
		
		appState.setLoading(true)
		let userIds = users.map { $0.id } + [currentUser.id]
		let chatId = generateChatId(users: userIds)
		
		if let existingChat = self.chats.first(where: { $0.id == chatId }) {
			Task {
				await MainActor.run {
					self.newChat = existingChat
				}
				appState.setLoading(false)
			}
		} else {
			Task {
				let isGroup = users.count > 1
				let finalChatName = !chatName.isEmpty ? chatName : (isGroup ? "New Group Chat" : "New Chat")
				let imageUrl = try? await (imageData != nil ? chatRepository.uploadImage(chatId: chatId, imageData: imageData!, isGroup: isGroup) : "")
				
				handleNewChat(userIds: userIds, chatName: finalChatName, imageUrl: imageUrl ?? "", chatId: chatId, isGroup: isGroup, currentUserId: currentUser.id)
				appState.setLoading(false)
			}
		}
	}
	
	private func handleNewChat(userIds: [String], chatName: String, imageUrl: String, chatId: String, isGroup: Bool, currentUserId: String) {
		Task {
			do {
				let initialUnreadCount = Dictionary(uniqueKeysWithValues: userIds.map { ($0, 0) })
				
				let newChat = Chat(
					id: chatId,
					type: isGroup ? .group : .individual,
					name: chatName,
					imageUrl: imageUrl,
					memberIds: userIds,
					lastMessage: "",
					lastMessageBy: "",
					lastMessageId: "",
					lastMessageAt: Date(),
					createdBy: currentUserId,
					createdAt: Date(),
					bio: "",
					admins: [currentUserId],
					isPinned: [],
					isMuted: [],
					isRead: [],
					unreadCount: initialUnreadCount,
					messages: []
				)
				
				try await chatRepository.createChat(chat: newChat)
				await MainActor.run {
					self.newChat = newChat
				}
			} catch {
				print(error)
				print(error.localizedDescription)
				appState.setError("Error Creating Chat", error.localizedDescription)
			}
		}
	}
	
	private func generateChatId(users: [String]) -> String {
		let hash = users.sorted().joined(separator: "_").hashValue
		return "chat_\(hash)"
	}
}
