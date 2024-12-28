//
//  InboxChatRowView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

struct InboxChatRowView: View {
	@ObservedObject var viewModel: InboxViewModel
	var chat: Chat
	
	private var allOthersRead: Bool {
	   guard let currentUserId = viewModel.currentUserId else { return false }
	   return chat.memberIds
		   .filter { $0 != currentUserId }
		   .allSatisfy { chat.isRead.contains($0) }
   }
	
	private var unreadCountForCurrentUser: Int {
		guard let currentUserId = viewModel.currentUserId else { return 0 }
		return chat.unreadCount[currentUserId] ?? 0
	}
	
	var body: some View {
		HStack {
			// Profile Image
			CircularProfileImage(url: chat.displayImageURL(for: viewModel.currentUserId ?? "", users: viewModel.users))
			
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					
					Text(chat.chatName(for: viewModel.currentUserId ?? "", users: viewModel.users))
						.font(.headline)
						.lineLimit(1)
					
					Spacer()
					Text(chat.lastMessageAt.formatted(.dateTime.hour().minute()))
						.font(.subheadline)
						.foregroundColor(.gray)
				}
				
				HStack {
					if chat.lastMessageBy == viewModel.currentUserId {
						Image(systemName: "checkmark")
							.resizable()
							.frame(width: 12, height: 12)
							.overlay {
								Image(systemName: "checkmark")
									.resizable()
									.frame(width: 12, height: 12)
									.offset(x: 4, y: 0)
									.mask(
										Rectangle()
											.frame(width: 10, height: 16)
											.offset(x: 6, y: 0)
									)
							}
							.foregroundColor(allOthersRead ? .blue : .gray)
					}
					Text(chat.lastMessage)
						.font(.subheadline)
						.foregroundColor(.gray)
						.lineLimit(1)
					
					Spacer()
					
					HStack(spacing: 4) {
						if chat.isPinned.contains(viewModel.currentUserId ?? "") {
							Image(systemName: "pin.fill")
								.foregroundColor(.gray)
						}
						if chat.isMuted.contains(viewModel.currentUserId ?? "") {
							Image(systemName: "bell.slash.fill")
								.foregroundColor(.gray)
						}
						if unreadCountForCurrentUser > 0 {
							Text("\(unreadCountForCurrentUser)")
								.font(.caption)
								.fontWeight(.bold)
								.foregroundColor(.white)
								.padding(6)
								.background(Circle().fill(Color.green))
						}
					}
				}
			}
		}
		.padding(.vertical, 8)
	}
}
