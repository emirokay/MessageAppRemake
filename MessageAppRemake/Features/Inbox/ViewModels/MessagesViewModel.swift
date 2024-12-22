//
//  MessagesViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 2.12.2024.
//

import Combine
import FirebaseFirestore

class MessagesViewModel: ObservableObject {
	@Published var chat: Chat
	@Published var messages: [Message] = []
	@Published var users: [User] = []
	@Published var currentUserId: String?
	@Published var isSending: Bool = false
	
	private let chatRepository: ChatRepositoryProtocol
	private let chatStore: ChatStoreProtocol
	private var cancellables = Set<AnyCancellable>()
	private let appState: AppStateProtocol
	
	init(chat: Chat,
		 chatRepository: ChatRepositoryProtocol = ChatRepository(),
		 chatStore: ChatStoreProtocol = ChatStore.shared,
		 userService: UserServiceProtocol = UserService.shared,
		 appState: AppStateProtocol = AppState.shared) {
		self.chat = chat
		self.chatRepository = chatRepository
		self.chatStore = chatStore
		self.appState = appState
		setupSubscribers(userService: userService)
		fetchMessages()
	}
	
	private func setupSubscribers(userService: UserServiceProtocol) {
		userService.currentUserPublisher
			.compactMap { $0?.id }
			.receive(on: DispatchQueue.main)
			.sink { [weak self] userId in
				self?.currentUserId = userId
			}
			.store(in: &cancellables)
		
		chatStore.usersPublisher
			.assign(to: &$users)
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
		
		if let imageData = imageData {
			Task {
				do {
					let imageUrl = try await chatRepository.uploadImage(chatId: chat.id, imageData: imageData, isGroup: false)
					sendMessageWithUrl(messageText: messageText, imageUrl: imageUrl)
				} catch {
					self.appState.setError("Error uploading image", error.localizedDescription)
				}
			}
		} else {
			sendMessageWithUrl(messageText: messageText, imageUrl: "")
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
			seenBy: []
		) 
		
		Task {
			do {
				try await chatRepository.sendMessage(chatId: chat.id, message: newMessage)
				DispatchQueue.main.async {
					self.isSending = false
				}
			} catch {
				self.isSending = false
				self.appState.setError("Error sending message", error.localizedDescription)
			}
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
				try await chatRepository.markMessagesAsSeen(chatId: chat.id, messageIds: unseenMessageIds, userId: currentUserId)
			} catch {
				self.appState.setError("Error marking messages as seen", error.localizedDescription)
			}
		}
	}
}

