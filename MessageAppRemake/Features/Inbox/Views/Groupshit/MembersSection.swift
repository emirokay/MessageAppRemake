//
//  MembersSection.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 23.12.2024.
//

import SwiftUI

struct MembersSection: View {
	@ObservedObject var viewModel: MessagesViewModel
	let currentUser: User
	@Binding var showAddMembers: Bool
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Members")
				.font(.footnote)
				.foregroundColor(Color(.systemGray))
				.frame(maxWidth: UIScreen.main.bounds.width - 60, alignment: .leading)
			
			
			if viewModel.chat.admins.contains(where: { $0 == currentUser.id }) {
				AddMembersButton()
					.onTapGesture {
						showAddMembers = true
					}
				Divider()
			}
			
			MemberRow(user: currentUser, isAdmin: viewModel.chat.admins.contains(where: { $0 == currentUser.id }), isCurrentUserAdmin: viewModel.chat.admins.contains(where: { $0 == currentUser.id }), isCurrentUser: true, viewModel: viewModel)
			
			ForEach(viewModel.filteredChatUsers) { user in
				Divider()
				MemberRow(user: user, isAdmin: viewModel.chat.admins.contains(where: { $0 == user.id }), isCurrentUserAdmin: viewModel.chat.admins.contains(where: { $0 == currentUser.id }), viewModel: viewModel)
			}
			
		}
		.padding(12)
		.background(Color(.systemGray6))
		.cornerRadius(10)
		.padding(.horizontal, 24)
	}
	
	struct AddMembersButton: View {
		var body: some View {
			HStack {
				Image(systemName: "plus.circle.fill")
					.resizable()
					.frame(width: 40, height: 40)
					.foregroundStyle(.blue)
				
				Text("Add Members")
					.font(.callout)
					.fontWeight(.semibold)
				
				Spacer()
				Image(systemName: "chevron.right")
					.foregroundStyle(.gray)
			}
			.padding(4)
			.contentShape(Rectangle())
		}
	}
	
}

struct MemberRow: View {
	let user: User
	let isAdmin: Bool
	let isCurrentUserAdmin: Bool
	var isCurrentUser: Bool = false
	@State var showDetails: Bool = false
	@ObservedObject var viewModel: MessagesViewModel
	
	var body: some View {
		HStack {
			CircularProfileImage(url: user.profileImageURL, wSize: 40, hSize: 40)
			
			VStack(alignment: .leading) {
				HStack{
					Text(user.name)
						.font(.callout)
						.fontWeight(.semibold)
					if isCurrentUser {
						Text("(You)")
							.font(.subheadline)
							.foregroundColor(.gray)
					}
				}
				Text(user.email)
					.font(.footnote)
					.foregroundColor(.gray)
			}
			
			Spacer()
			if isAdmin {
				Text("(Admin)")
					.font(.subheadline)
					.foregroundColor(.gray)
			}
			Image(systemName: "chevron.right")
				.foregroundStyle(.gray)
		}
		.onTapGesture {
			showDetails = true
		}
		.padding(4)
		.contentShape(Rectangle())
		.sheet(isPresented: $showDetails) {
			MemberRowDetails(user: user, isAdmin: isAdmin, isCurrentUserAdmin: isCurrentUserAdmin, isCurrentUser: isCurrentUser, viewModel: viewModel)
				.presentationDetents(isCurrentUser ? [.fraction(0.2)] : isCurrentUserAdmin ? [.fraction(0.4)] : [.fraction(0.2)])
				.presentationDragIndicator(.hidden)
		}
	}
}

struct MemberRowDetails: View {
	let user: User
	let isAdmin: Bool
	let isCurrentUserAdmin: Bool
	let isCurrentUser: Bool
	@ObservedObject var viewModel: MessagesViewModel
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 16) {
				HStack {
					CircularProfileImage(url: user.profileImageURL, wSize: 40, hSize: 40)
					
					Text(user.name)
						.font(.headline)
						.fontWeight(.semibold)
					
					Spacer()
					
					Button {
						dismiss()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.font(.title2)
							.foregroundColor(.gray)
					}
				}
				.padding(.horizontal)

				ActionButton(title: "Info", foregroundColor: .blue) {
					viewModel.navigateToUserProfile = user
					dismiss()
					viewModel.isNavigating = true
				}
				
				if !isCurrentUser {
					if isCurrentUserAdmin {
						ActionButton(title: isAdmin ? "Dismiss Admin" : "Make Admin", foregroundColor: isAdmin ? .red : .blue) {
							viewModel.handleAdmin(chat: viewModel.chat, selectedUserId: user.id)
							dismiss()
						}
					}
					
					if isCurrentUserAdmin {
						ActionButton(title: "Remove from group", foregroundColor: .red) {
							viewModel.removeFromGroup(chat: viewModel.chat, selectedUserId: user.id)
							dismiss()
						}
					}
				}
				
				Spacer()
			}
			.padding(.top)
			.background(Color(.secondarySystemBackground))
			.ignoresSafeArea(edges: .bottom)
		}
	}
	
	struct ActionButton: View {
		let title: String
		let foregroundColor: Color
		let action: () -> Void
		
		init(title: String, foregroundColor: Color = .primary, action: @escaping () -> Void) {
			self.title = title
			self.foregroundColor = foregroundColor
			self.action = action
		}
		
		var body: some View {
			Button(action: action) {
				HStack {
					Text(title)
					Spacer()
				}
				.font(.body)
				.foregroundColor(foregroundColor)
				.padding(12)
				.frame(maxWidth: .infinity)
			}
			.background(Color.white)
			.cornerRadius(10)
			.padding(.horizontal)
		}
	}
}

//DIFFERENT VIEW
struct AddMembers: View {
	let chat: Chat
	let users: [User]
	@State var searchText = ""
	@ObservedObject var viewModel: MessagesViewModel
	@State var preSelectedUsers: [User] = [User]()
	@Environment(\.dismiss) var dismiss
	
	var filteredUsers: [User] {
		viewModel.allUsers.filter { user in
			!users.contains(where: { $0.id == user.id })
		}
	}
	
	var body: some View {
		NavigationStack {
			VStack {
				List {
					Section("Friends") {
						ForEach(filteredUsers) { user in
							HStack {
								UserRow(user: user) {
									if preSelectedUsers.contains(where: { $0.id == user.id }) {
										preSelectedUsers.removeAll(where: { $0.id == user.id })
									} else {
										preSelectedUsers.append(user)
									}
								}.foregroundStyle(.primary)
								Spacer()
								Image(systemName: preSelectedUsers.contains(where: { $0.id == user.id }) ? "checkmark.circle.fill" : "circle")
									.foregroundColor(preSelectedUsers.contains(where: { $0.id == user.id }) ? .blue : .gray)
							}
						}
					}
				}
			}
			.searchable(text: $searchText)
			.navigationTitle("Add Members")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel") {
						dismiss()
					}.foregroundStyle(.red)
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					Button("Add") {
						viewModel.addGroupMembers(chat: chat, users: preSelectedUsers)
						dismiss()
					}
				}
				
			}
		}
		.onAppear {
			viewModel.fetchAllUsers()
		}
	}
}
