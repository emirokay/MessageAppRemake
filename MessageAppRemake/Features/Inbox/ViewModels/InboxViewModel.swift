//
//  InboxViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import Foundation
import FirebaseFirestore
import Combine

class InboxViewModel: ObservableObject {
	@Published var chats: [Chat] = [MockData.mocChat]
	
	@Published var currentUserId: String?
	
	private let chatRepository: ChatRepositoryProtocol
	private var cancellables = Set<AnyCancellable>()
	
	private let appState: AppStateProtocol
	
	init(chatRepository: ChatRepositoryProtocol = ChatRepository(),
		 userService: UserServiceProtocol = UserService.shared,
		 appState: AppStateProtocol = AppState.shared) {
		self.chatRepository = chatRepository
		self.appState = appState
		setupSubscribers(userService: userService)
		fetchChats()
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
	
	func fetchChats() {
		guard let currentUserId else { return }
		chatRepository.fetchChats(for: currentUserId)
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					self.appState.setError("Error fetching chats", error.localizedDescription)
				}
			}, receiveValue: { [weak self] chats in
				self?.chats = chats
			})
			.store(in: &cancellables)
	}
	
	func filteredChats(searchText: String) -> [Chat] {
		let normalizedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !normalizedSearchText.isEmpty else { return chats }
		return chats.filter { $0.name.localizedCaseInsensitiveContains(normalizedSearchText) }
	}
	
	func pinChat(chatId: String) async throws {
		//guard let currentUserId else { return }
		//try await chatRepository.updateChat(chatId: chatId, fields: ["isPinned": true])
	}
	
	func muteChat(chatId: String) async throws {
		//guard let currentUserId else { return }
		//try await chatRepository.updateChat(chatId: chatId, fields: ["isMuted": true])
	}
	
}


