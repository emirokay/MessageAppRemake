//
//  MessagesVies.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

struct MessagesView: View {
	@State var chat: Chat
	@State private var messageText = ""
	@Namespace private var bottomID // To scroll to the last message
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			VStack {
				// Messages
				ScrollViewReader { proxy in
					ScrollView {
						LazyVStack(spacing: 12) {
							ForEach(chat.messages) { message in
								ChatMessageBubble(message: message)
							}
							// Scroll Anchor
							Divider().opacity(0).id(bottomID)
						}
						.padding(.horizontal)
					}
					.onChange(of: chat.messages) {
						withAnimation {
							proxy.scrollTo(bottomID, anchor: .bottom)
						}
					}
				}
				
				// Input Bar
				inputBar
			}
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					customBackButton
				}
				ToolbarItem(placement: .navigationBarLeading) {
					chatHeader
				}
			}
			.toolbar(.hidden, for: .tabBar) // hide tabbar
		}
	}
	
	private var inputBar: some View {
		HStack(spacing: 8) {
			// Add Image Button
			Button(action: {
				// Add image func
			}) {
				Image(systemName: "photo.on.rectangle.angled")
					.font(.system(size: 24))
					.foregroundColor(.blue)
			}
			
			// Message field
			TextField("Message...", text: $messageText)
				.padding(8)
				.background(Color(.systemGray6))
				.cornerRadius(20)
				.textFieldStyle(PlainTextFieldStyle())
			
			// Send Button
			Button {} label: {
				Text("Send")
					.fontWeight(.bold)
					.foregroundColor(messageText.isEmpty ? .gray : .blue)
			}
			.disabled(messageText.isEmpty)
		}
		.padding(.horizontal)
		.padding(.vertical, 8)
		.background(Color(.systemGray5))
	}
	
	private var customBackButton: some View {
		Button {
			dismiss()
		} label: {
			Image(systemName: "chevron.left")
				.font(.system(size: 16, weight: .medium))
				.foregroundColor(.blue)
		}
	}
	
	private var chatHeader: some View {
		HStack(spacing: 8) {
			// Profile Image
			Image(systemName: "person.fill")
			
			// Chat Name -> details
			VStack(alignment: .leading) {
				Text(chat.name ?? "Unknown")
					.fontWeight(.semibold)
				Text("Tap for more info")
					.font(.footnote)
					.foregroundColor(.gray)
			}
		}
	}
	
}

// Message buble - if senderId == viewModel.currentUser.id
struct ChatMessageBubble: View {
	let message: Message
	
	var body: some View {
		HStack {
			if message.senderId == "mocUser" {
				Spacer()
				Text(message.text)
					.padding(10)
					.foregroundColor(.white)
					.background(Color.blue)
					.cornerRadius(20)
					.frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
			} else {
				Text(message.text)
					.padding(10)
					.foregroundColor(.black)
					.background(Color(.systemGray5))
					.cornerRadius(20)
					.frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
				Spacer()
			}
		}
	}
}


#Preview {
	MessagesView(chat: MockData.mocChat)
}
