//
//  InboxViewModel.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import Foundation

class InboxViewModel: ObservableObject {
	@Published var chats: [Chat] = [MockData.mocChat, MockData.mocChat, MockData.mocChat]

	// Filter chats with search bar 
	func filteredChats(searchText: String) -> [Chat] {
		if searchText.isEmpty { return chats }
		return chats.filter { $0.name?.localizedCaseInsensitiveContains(searchText) == true }
	}
}
