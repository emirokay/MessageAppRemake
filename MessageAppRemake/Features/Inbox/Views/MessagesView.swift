//
//  MessagesVies.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

struct MessagesView: View {
	@Namespace private var bottomID
	@Environment(\.dismiss) private var dismiss
	@StateObject var viewModel: MessagesViewModel
	
	init(chat: Chat) {
		_viewModel = StateObject(wrappedValue: MessagesViewModel(chat: chat))
	}
	
	var body: some View {
		NavigationStack {
			VStack {
				ScrollViewReader { proxy in
					ScrollView {
						LazyVStack {
							ForEach(viewModel.messages) { message in
								ChatMessageBubble(message: message, currentUserId: viewModel.currentUserId ?? "")
									.id(message.id)
							}
						}
					}
					.onChange(of: viewModel.messages) {
						withAnimation {
							proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
						}
					}
				}
				inputBar
			}
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					ChatHeader(chat: viewModel.chat, viewModel: viewModel) {
						dismiss()
					}
				}
			}
			.toolbar(.hidden, for: .tabBar)
		}
	}
	
	private var inputBar: some View {
		HStack(spacing: 8) {
			Button(action: {
				// Add image functionality
			}) {
				Image(systemName: "photo.on.rectangle.angled")
					.font(.system(size: 24))
					.foregroundColor(.blue)
			}
			.accessibilityLabel("Add Image")
			
			TextField("Message...", text: $viewModel.messageText)
				.padding(8)
				.background(Color(.systemGray6))
				.cornerRadius(20)
				.accessibilityLabel("Message Text Field")
			
			Button {
				viewModel.sendMessage()
			} label: {
				Text("Send")
					.fontWeight(.bold)
					.foregroundColor(viewModel.messageText.isEmpty ? .gray : .blue)
			}
			.disabled(viewModel.messageText.isEmpty || viewModel.isSending)
			.accessibilityLabel("Send Message")
		}
		.padding()
		.background(Color(.systemGray5))
	}
}

struct ChatHeader: View {
	let chat: Chat
	let viewModel: MessagesViewModel
	let onBack: () -> Void
	
	var body: some View {
		HStack(spacing: 8) {
			Button(action: onBack) {
				Image(systemName: "chevron.left")
					.font(.system(size: 16, weight: .medium))
					.foregroundColor(.blue)
			}
			CircularProfileImage(url: chat.displayImageURL(for: viewModel.currentUserId ?? "", users: viewModel.users), size: 38)
			VStack(alignment: .leading) {
				Text(chat.chatName(for: viewModel.currentUserId ?? "", users: viewModel.users))
					.fontWeight(.semibold)
				Text("Tap for more info")
					.font(.footnote)
					.foregroundColor(.gray)
			}
		}
		.padding(.vertical, 10)
	}
}

struct ChatMessageBubble: View {
	let message: Message
	let currentUserId: String
	
	var body: some View {
		HStack {
			if message.senderId == currentUserId {
				Spacer()
				VStack(alignment: .trailing, spacing: 4) {
					Text(message.text)
						.padding(10)
						.foregroundColor(.white)
						.background(Color.blue)
						.clipShape(ChatBuble(isFromCurrentUser: true))
					Text(message.sentAt.formatted(date: .omitted, time: .shortened))
						.font(.caption2)
						.foregroundColor(.gray)
				}
				.frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
			} else {
				VStack(alignment: .leading, spacing: 4) {
					Text(message.text)
						.padding(10)
						.foregroundColor(.black)
						.background(Color(.systemGray5))
						.clipShape(ChatBuble(isFromCurrentUser: false))
					Text(message.sentAt.formatted(date: .omitted, time: .shortened))
						.font(.caption2)
						.foregroundColor(.gray)
				}
				.frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
				Spacer()
			}
		}
		.padding(.horizontal, 8)
	}
}

struct ChatBuble: Shape {
	let isFromCurrentUser: Bool
	
	func path(in rect: CGRect) -> Path {
		let bubbleCornerRadius: CGFloat = min(rect.height / 2, 16)
		let path = UIBezierPath(roundedRect: rect,
								byRoundingCorners: [
									.topLeft,
									.topRight,
									isFromCurrentUser ? .bottomLeft : .bottomRight
								],
								cornerRadii: CGSize(width: bubbleCornerRadius, height: bubbleCornerRadius))
		return Path(path.cgPath)
	}
}

#Preview {
	MessagesView(chat: MockData.mocChat)
}
