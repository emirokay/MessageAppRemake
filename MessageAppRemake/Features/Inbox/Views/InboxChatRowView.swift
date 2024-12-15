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
							.foregroundColor(chat.isRead ? .blue : .gray)
					}
					
					Text(chat.lastMessage)
						.font(.subheadline)
						.foregroundColor(.gray)
						.lineLimit(1)
					
					Spacer()
					
					HStack(spacing: 4) {
						if chat.isPinned {
							Image(systemName: "pin.fill")
								.foregroundColor(.gray)
						}
						if chat.isMuted {
							Image(systemName: "bell.slash.fill")
								.foregroundColor(.gray)
						}
						if chat.unreadCount > 0 {
							Text("\(chat.unreadCount)")
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
