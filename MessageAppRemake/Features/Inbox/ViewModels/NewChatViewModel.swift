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
	
	init(
		chatRepository: ChatRepositoryProtocol = ChatRepository.shared,
		userService: UserServiceProtocol = UserService.shared,
		chatStore: ChatStoreProtocol = ChatStore.shared,
		appState: AppStateProtocol = AppState.shared
	) {
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
		let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedText.isEmpty else { return allUsers }
		
		return allUsers.filter { $0.name.localizedCaseInsensitiveContains(trimmedText) }
	}
	
	func startChat(with users: [User], chatName: String = "", imageData: Data? = nil) {
		guard let currentUser else { return }
		
		appState.setLoading(true)
		let userIds = users.map { $0.id } + [currentUser.id]
		
		if let existingChat = self.chats.first(where: { Set($0.memberIds) == Set(userIds) }) {
			self.newChat = existingChat
			appState.setLoading(false)
		} else {
			TaskHandler.performTaskWithLoading {
				let chatId = UUID().uuidString
				let isGroup = users.count > 1
				let finalChatName = !chatName.isEmpty ? chatName : (isGroup ? "New Group Chat" : "New Chat")
				let imageUrl = try await (imageData != nil ? self.chatRepository.uploadImage(chatId: chatId, imageData: imageData!, isGroup: isGroup) : "")
				
				await self.createNewChat( userIds: userIds, chatName: finalChatName, imageUrl: imageUrl, chatId: chatId, isGroup: isGroup, currentUserId: currentUser.id)
				self.appState.setLoading(false)
			}
		}
	}
	
	private func uploadChatImage(chatId: String, imageData: Data?, isGroup: Bool) async throws -> String? {
		guard let imageData else { return nil }
		return try await chatRepository.uploadImage(chatId: chatId, imageData: imageData, isGroup: isGroup)
	}
	
	private func createNewChat(userIds: [String], chatName: String, imageUrl: String, chatId: String, isGroup: Bool, currentUserId: String) async {
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
		
		TaskHandler.performTaskWithLoading { @MainActor in
			try await self.chatRepository.createChat(chat: newChat)
			self.newChat = newChat
		}
		
	}
}
