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
	var allUsersPublisher: Published<[User]>.Publisher { get }

	func setCurrentUserId(_ userId: String)
	func refreshChatsAndUsers()
	func fetchAllUsers()
}

final class ChatStore: ObservableObject, ChatStoreProtocol {
	static let shared = ChatStore()
	
	private init(appState: AppStateProtocol = AppState.shared) {
		self.appState = appState
	}

	private let chatRepository: ChatRepositoryProtocol = ChatRepository()
	private let appState: AppStateProtocol
	private var cancellables = Set<AnyCancellable>()
	private var currentUserId: String?

	@Published private(set) var chats: [Chat] = []
	@Published private(set) var users: [User] = []
	@Published private(set) var allUsers: [User] = []
	
	var chatsPublisher: Published<[Chat]>.Publisher { $chats }
	var usersPublisher: Published<[User]>.Publisher { $users }
	var allUsersPublisher: Published<[User]>.Publisher { $allUsers }
	
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
				self?.chats = chats.sorted(by: { $0.lastMessageAt > $1.lastMessageAt })
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
	
	func fetchAllUsers() {
		guard let userId = currentUserId else { return }
		
		appState.setLoading(true)
		Task {
			do {
				let allUsers = try await chatRepository.fetchAllUsers()
				self.allUsers = allUsers.filter { $0.id != userId }
			} catch {
				self.appState.setError("Error Fetching Users", error.localizedDescription)
			}
			self.appState.setLoading(false)
		}
	}
	
}

