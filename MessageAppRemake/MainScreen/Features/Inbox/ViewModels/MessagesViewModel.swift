//
//  MessagesViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 2.12.2024.
//

import Combine
import FirebaseFirestore

class MessagesViewModel: ObservableObject {
	@Published var chat: Chat {
		didSet {
			updateFilteredChatUsers()
		}
	}
	@Published var messages: [Message] = []
	@Published var users: [User] = []
	@Published var allUsers: [User] = []
	@Published var currentUserId: String?
	@Published var currentUser: User?
	@Published var isSending: Bool = false
	@Published var exitGroup: Bool = false
	@Published var navigateToUserProfile: User?
	@Published var isNavigating: Bool = false
	@Published var filteredChatUsers: [User] = []
	
	private let chatRepository: ChatRepositoryProtocol
	private let chatStore: ChatStoreProtocol
	private var cancellables = Set<AnyCancellable>()
	
	private var isReadyToMarkMessages: AnyPublisher<Bool, Never> {
		Publishers.CombineLatest($currentUserId, $messages)
			.map { $0 != nil && !$1.isEmpty }
			.removeDuplicates()
			.eraseToAnyPublisher()
	}
	
	init(chat: Chat,
		 chatRepository: ChatRepositoryProtocol = ChatRepository.shared,
		 chatStore: ChatStoreProtocol = ChatStore.shared,
		 userService: UserServiceProtocol = UserService.shared) {
		self.chat = chat
		self.chatRepository = chatRepository
		self.chatStore = chatStore
		setupSubscribers(userService: userService)
		fetchMessages()
		updateFilteredChatUsers()
	}
	
	private func setupSubscribers(userService: UserServiceProtocol) {
		userService.currentUserPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: &$currentUser)
		
		userService.currentUserPublisher
			.compactMap { $0?.id }
			.receive(on: DispatchQueue.main)
			.assign(to: &$currentUserId)
		
		chatStore.usersPublisher
			.assign(to: &$users)
		
		chatStore.allUsersPublisher
			.assign(to: &$allUsers)
		
		isReadyToMarkMessages
				.filter { $0 }
				.sink { [weak self] _ in
					self?.markMessagesAsSeen()
				}
				.store(in: &cancellables)
	}
	
	func updateFilteredChatUsers() {
		filteredChatUsers = users.filter { chat.memberIds.contains($0.id) }
	}
	
	func fetchAllUsers() {
		TaskHandler.performTaskWithLoading {
			self.chatStore.fetchAllUsers()
		}
	}
	
	func fetchMessages() {
		chatRepository.fetchMessages(chatId: chat.id)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				if case .failure(_) = completion {
					//self?.appState.setError("Error fetching messages", error.localizedDescription)
				}
			}, receiveValue: { [weak self] messages in
				self?.messages = messages
			})
			.store(in: &cancellables)
	}
	
	func sendMessage(messageText: String, imageData: Data?) {
		isSending = true
		TaskHandler.performTaskWithLoading {
			if let imageData = imageData {
				let imageUrl = try await self.chatRepository.uploadImage(chatId: self.chat.id, imageData: imageData, isGroup: false)
				self.createMessage(text: messageText, imageUrl: imageUrl)
			} else {
				self.createMessage(text: messageText, imageUrl: "")
			}
		}
		isSending = false
	}
	
	private func createMessage(text: String, imageUrl: String) {
		guard let currentUserId else { return }
		
		let newMessage = Message(
			id: UUID().uuidString,
			chatId: chat.id,
			senderId: currentUserId,
			text: text,
			imageUrl: imageUrl,
			sentAt: Date(),
			seenBy: [currentUserId]
		)
		
		TaskHandler.performTask {
			try await self.chatRepository.sendMessage(chatId: self.chat.id, message: newMessage)
		}
	}
	
	func saveGroupInfo(chatName: String, about: String, imageData: Data?){
		var updatedChat = self.chat
		if !chatName.isEmpty { updatedChat.name = chatName }
		if !about.isEmpty { updatedChat.bio = about }
		
		TaskHandler.performTaskWithLoading {
			if let imageData {
				let profileImageUrl = try await self.chatRepository.uploadImage(chatId: updatedChat.id, imageData: imageData, isGroup: true)
				updatedChat.imageUrl = profileImageUrl
			}
			try await self.chatRepository.uploadChatData(chat: updatedChat)
			DispatchQueue.main.async { self.chat = updatedChat }
		}
	}
	
	func addGroupMembers(users: [User]) {
		var updatedChat = self.chat
		let userIds = users.map { $0.id }
		updatedChat.memberIds.append(contentsOf: userIds)
		
		TaskHandler.performTaskWithLoading {
			try await self.chatRepository.uploadChatData(chat: updatedChat)
			DispatchQueue.main.async { self.chat = updatedChat }
		}
	}
	
	func toggleAdmin(selectedUserId: String) {
		var updatedChat = self.chat
		if updatedChat.admins.contains(selectedUserId) {
			updatedChat.admins.removeAll { $0 == selectedUserId }
		} else {
			updatedChat.admins.append(selectedUserId)
		}
		
		TaskHandler.performTask {
			try await self.chatRepository.uploadChatData(chat: updatedChat)
			DispatchQueue.main.async { self.chat = updatedChat }
		}
	}
	
	func removeFromGroup(selectedUserId: String) {
		var updatedChat = self.chat
		updatedChat.memberIds.removeAll { $0 == selectedUserId }
		
		TaskHandler.performTaskWithLoading {
			try await self.chatRepository.uploadChatData(chat: updatedChat)
			DispatchQueue.main.async { self.chat = updatedChat }
		}
	}
	
	func exitFromGroup() {
		guard let currentUserId else { return }
		var updatedChat = self.chat
		updatedChat.memberIds.removeAll { $0 == currentUserId }
		
		TaskHandler.performTaskWithLoading {
			try await self.chatRepository.uploadChatData(chat: updatedChat)
			self.chatStore.refreshChatsAndUsers()
			DispatchQueue.main.async { self.chat = updatedChat }
		}
	}
	
	func markMessagesAsSeen() {
		guard let currentUserId else { return }
		
		TaskHandler.performTask {
			let unseenMessageIds = self.messages
				.filter { !$0.seenBy.contains(currentUserId) }
				.map { $0.id }
			
			guard !unseenMessageIds.isEmpty else { return }
			
			try await self.chatRepository.markMessagesAsSeen(chat: self.chat, messageIds: unseenMessageIds, userId: currentUserId)
		}
	}
}
