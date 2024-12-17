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
	
	@Published var messageText: String = ""
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
	
	func sendMessage() {
		guard !messageText.isEmpty, let currentUserId else { return }
		
		isSending = true
		let newMessage = Message(
			id: UUID().uuidString,
			chatId: chat.id,
			senderId: currentUserId,
			text: messageText,
			sentAt: Date()
		)
		
		Task {
			do {
				try await chatRepository.sendMessage(chatId: chat.id, message: newMessage)
				DispatchQueue.main.async {
					self.isSending = false
					self.messageText = ""
				}
			} catch {
				self.isSending = false
				self.appState.setError("Error sending messages", error.localizedDescription)
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

