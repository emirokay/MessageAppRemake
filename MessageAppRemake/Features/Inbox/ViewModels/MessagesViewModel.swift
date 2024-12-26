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
			recalculateFilteredChatUsers()
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
	
	private let chatRepository: ChatRepositoryProtocol
	private let chatStore: ChatStoreProtocol
	private var cancellables = Set<AnyCancellable>()
	private let appState: AppStateProtocol
	
	var filteredChatUsers: [User] = []

	func recalculateFilteredChatUsers() {
		filteredChatUsers = users.filter { user in
			chat.memberIds.contains(user.id)
		}
	}
	
	private var isReadyToMarkMessages: AnyPublisher<Bool, Never> {
		Publishers.CombineLatest($currentUserId, $messages)
			.map { currentUserId, messages in
				currentUserId != nil && !messages.isEmpty
			}
			.removeDuplicates()
			.eraseToAnyPublisher()
	}
	
	init(chat: Chat,
		 chatRepository: ChatRepositoryProtocol = ChatRepository.shared,
		 chatStore: ChatStoreProtocol = ChatStore.shared,
		 userService: UserServiceProtocol = UserService.shared,
		 appState: AppStateProtocol = AppState.shared) {
		self.chat = chat
		self.chatRepository = chatRepository
		self.chatStore = chatStore
		self.appState = appState
		setupSubscribers(userService: userService)
		fetchMessages()
		recalculateFilteredChatUsers()
	}
	
	private func setupSubscribers(userService: UserServiceProtocol) {
		userService.currentUserPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: &$currentUser)
		
		userService.currentUserPublisher
			.compactMap { $0?.id }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] userId in
				self?.currentUserId = userId
			}
			.store(in: &cancellables)
		
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
	
	func fetchAllUsers() {
		chatStore.fetchAllUsers()
	}
	
	func fetchMessages() {
		chatRepository.fetchMessages(chatId: chat.id)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					self.appState.setError("Error fetching messages", error.localizedDescription)
				}
			}, receiveValue: { [weak self] messages in
				self?.messages = messages
			})
			.store(in: &cancellables)
	}
	
	func sendMessage(messageText: String, imageData: Data?) {
		isSending = true
		
		performTaskWithLoading{
			if let imageData = imageData {
				let imageUrl = try await self.chatRepository.uploadImage(chatId: self.chat.id, imageData: imageData, isGroup: false)
				self.sendMessageWithUrl(messageText: messageText, imageUrl: imageUrl)
			} else {
				self.sendMessageWithUrl(messageText: messageText, imageUrl: "")
			}
		}
	}
	
	private func sendMessageWithUrl(messageText: String, imageUrl: String) {
		guard let currentUserId else { return }
		
		let newMessage = Message(
			id: UUID().uuidString,
			chatId: chat.id,
			senderId: currentUserId,
			text: messageText,
			imageUrl: imageUrl,
			sentAt: Date(),
			seenBy: [currentUserId]
		)
		
		performTaskWithLoading {
			try await self.chatRepository.sendMessage(chatId: self.chat.id, message: newMessage)
		}
		
		self.isSending = false
	}
	
	func saveGroupInfo(chat: Chat, chatName: String, about: String, imageData: Data?){
		var chat = chat
		if !chatName.isEmpty {
			chat.name = chatName
		}
		if !about.isEmpty {
			chat.bio = about
		}
		performTaskWithLoading {
			if let imageData {
				let profileImageUrl = try await self.chatRepository.uploadImage(chatId: chat.id, imageData: imageData, isGroup: true)
				chat.imageUrl = profileImageUrl
			}
			try await self.chatRepository.uploadChatData(chat: chat)
			DispatchQueue.main.async {
				self.chat = chat
			}
		}
	}
	
	func addGroupMembers(chat: Chat, users: [User]) {
		var chat = chat
		
		let userIds = users.map { $0.id }
		chat.memberIds.append(contentsOf: userIds)
		
		performTaskWithLoading {
			try await self.chatRepository.uploadChatData(chat: chat)
			DispatchQueue.main.async {
				self.chat = chat
			}
		}
	}
	
	func handleAdmin(chat: Chat, selectedUserId: String) {
		guard let currentUserId = currentUserId else { return }
		var chat = chat
		
		if chat.admins.contains(selectedUserId) {
			chat.admins.removeAll(where: { $0 == selectedUserId })
		} else {
			chat.admins.append(selectedUserId)
		}
		
		performTaskWithLoading {
			try await self.chatRepository.uploadChatData(chat: chat)
			DispatchQueue.main.async {
				self.chat = chat
			}
		}
	}
	
	func removeFromGroup(chat: Chat, selectedUserId: String) {
		guard let currentUserId = currentUserId else { return }
		var chat = chat
		chat.memberIds.removeAll(where: { $0 == selectedUserId })
		
		performTaskWithLoading {
			try await self.chatRepository.uploadChatData(chat: chat)
			DispatchQueue.main.async {
				self.chat = chat
			}
		}
	}
	
	private func performTaskWithLoading(_ task: @escaping () async throws -> Void) {
		appState.setLoading(true)
		Task {
			do {
				try await task()
			} catch {
				appState.setError("Operation Failed", error.localizedDescription)
			}
			appState.setLoading(false)
		}
	}
	
	func markMessagesAsSeen() {
		guard let currentUserId else { return }

		Task {
			let unseenMessageIds = messages
				.filter { !$0.seenBy.contains(currentUserId) }
				.map { $0.id }
						
			guard !unseenMessageIds.isEmpty else { return }
			
			do {
				try await chatRepository.markMessagesAsSeen(chat: chat, messageIds: unseenMessageIds, userId: currentUserId)
			} catch {
				self.appState.setError("Error marking messages as seen", error.localizedDescription)
			}
		}
	}
	
}
