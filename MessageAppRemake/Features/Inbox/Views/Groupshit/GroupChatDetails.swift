//
//  GroupChatDetails.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 22.12.2024.
//

import SwiftUI

struct GroupChatDetailsView: View {
	var currentUser: User
	@ObservedObject var viewModel: MessagesViewModel

	@State private var about = ""
	@State private var chatName = ""
	
	@State private var showAboutView = false
	@State private var showAddMembers = false
	@State private var showEditView = false
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack {
					GroupHeader(chat: viewModel.chat, users:  viewModel.filteredChatUsers + [currentUser])
					
					GroupBioSection(about: viewModel.chat.bio, showAboutView: $showAboutView, isAdmin: viewModel.chat.admins.contains(where: { $0 == currentUser.id }))
					
					MembersSection(viewModel: viewModel, currentUser: currentUser, showAddMembers: $showAddMembers)
					
					ExitGroupButton(viewModel: viewModel, chat: viewModel.chat, currentUser: currentUser.id)
					
					Spacer()
				}
			}
			.navigationTitle("Group Details")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarBackButtonHidden()
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					if viewModel.chat.admins.contains(where: { $0 == currentUser.id }) {
						Button("Edit") {
							showEditView = true
						}
					}
				}
				ToolbarItem(placement: .topBarLeading) {
					Button{
						dismiss()
					} label: {
						Image(systemName: "chevron.left")
						Text("Back")
					}
				}
			}
			.onAppear { refreshData() }
			.onChange(of: viewModel.chat) { refreshData() }
			.fullScreenCover(isPresented: $showAboutView) {
				TextEditorView(about: $about, currentAbout: viewModel.chat.bio, showAboutView: $showAboutView, action: {
					viewModel.saveGroupInfo(chatName: chatName, about: about, imageData: nil)
					refreshData()
				})
			}
			.fullScreenCover(isPresented: $showAddMembers) {
				AddMembers(chat: viewModel.chat, users: viewModel.filteredChatUsers, viewModel: viewModel)
			}
			.fullScreenCover(isPresented: $showEditView) {
				EditGroup(chat: viewModel.chat, chatName: chatName, viewModel: viewModel)
			}
			.fullScreenCover(isPresented: $viewModel.isNavigating) {
				NavigationStack {
					UserDetailsView(user: viewModel.navigateToUserProfile)
						.toolbar {
							ToolbarItem(placement: .topBarLeading) {
								Button("Done") { viewModel.isNavigating = false }
									.padding()
							}
						}
				}
			}
		}
	}
	
	private func refreshData() {
		about = viewModel.chat.bio
		chatName = viewModel.chat.name
	}
}

struct ExitGroupButton: View {
	@ObservedObject var viewModel: MessagesViewModel
	var chat: Chat
	var currentUser: String
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		Button {
			viewModel.removeFromGroup(selectedUserId: currentUser)
			dismiss()
			viewModel.exitGroup = true
			
		} label: {
			Text("Exit Group")
				.frame(maxWidth: UIScreen.main.bounds.width - 60)
				.foregroundStyle(.red)
		}
		.padding(12)
		.background(Color(.systemGray6))
		.cornerRadius(10)
		.padding(.horizontal, 24)
	}
}

#Preview {
	NavigationStack {
		GroupChatDetailsView(currentUser: MockData.mocUser, viewModel: MessagesViewModel(chat: MockData.mocChat))
	}
}

