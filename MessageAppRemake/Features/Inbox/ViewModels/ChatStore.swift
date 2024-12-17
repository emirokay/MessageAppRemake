//
//  ChatStore.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 17.12.2024.
//

import Combine
import FirebaseFirestore

protocol ChatStoreProtocol {
	var chatsPublisher: Published<[Chat]>.Publisher { get }
	var usersPublisher: Published<[User]>.Publisher { get }
	
	func setCurrentUserId(_ userId: String)
	func refreshChatsAndUsers()
}

final class ChatStore: ObservableObject, ChatStoreProtocol {
	static let shared = ChatStore()
	private init() {}

	private let chatRepository: ChatRepositoryProtocol = ChatRepository()
	private var cancellables = Set<AnyCancellable>()
	private var currentUserId: String?

	@Published private(set) var chats: [Chat] = []
	@Published private(set) var users: [User] = []

	var chatsPublisher: Published<[Chat]>.Publisher { $chats }
	var usersPublisher: Published<[User]>.Publisher { $users }

	func setCurrentUserId(_ userId: String) {
		guard currentUserId != userId else { return }
		currentUserId = userId
		refreshChatsAndUsers()
	}

	func refreshChatsAndUsers() {
		guard let userId = currentUserId else { return }

		chatRepository.fetchChats(for: userId)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] chats in
				self?.chats = chats
				self?.fetchUsers(for: chats)
			}
			.store(in: &cancellables)
	}

	private func fetchUsers(for chats: [Chat]) {
		guard let userId = currentUserId else { return }
		let userIds = Set(chats.flatMap { $0.memberIds }.filter { $0 != userId })

		chatRepository.fetchUsersInChats(for: Array(userIds))
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in }) { [weak self] users in
				self?.users = users
			}
			.store(in: &cancellables)
	}
}

