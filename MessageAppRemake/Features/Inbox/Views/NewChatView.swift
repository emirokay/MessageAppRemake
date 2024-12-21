import SwiftUI


import SwiftUI

struct NewChatView: View {
	@State var searchText = ""
	@StateObject var viewModel = NewChatViewModel()
	@Environment(\.dismiss) var dismiss
	@Binding var selectedChat: Chat?
	@Binding var showSelectedChat: Bool
	
	var body: some View {
		NavigationStack {
			VStack {
				List {
					Section {
						ZStack(alignment: .leading) {
							NavigationLink(destination: NewGroupChatView(viewModel: viewModel)) {
								EmptyView()
							}
							.opacity(0.0)
							Label("New Group", systemImage: "person.2")
						}
					}
					
					// User List
					Section("Friends") {
						ForEach(viewModel.filteredUsers(searchText: searchText)) { user in
							UserRow(user: user) {
								viewModel.startChat(with: [user])
							}.foregroundStyle(.primary)
						}
					}
				}
			}
			.searchable(text: $searchText)
			.navigationTitle("New Chat")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						dismiss()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.foregroundStyle(.gray)
					}
				}
			}
			.onChange(of: viewModel.newChat) {
				dismiss()
				self.selectedChat = viewModel.newChat
				self.showSelectedChat = true
			}
			.onAppear {
				viewModel.fetchUsers()
			}
		}
	}
}

struct UserRow: View {
	let user: User
	let onTap: () -> Void
	
	var body: some View {
		Button(action: onTap) {
			HStack {
				CircularProfileImage(url: user.profileImageURL, wSize: 40, hSize: 40)
				Text(user.name)
					.fontWeight(.medium)
			}
		}
	}
}

#Preview {
	@Previewable @State var bool = false
	Button("Toggle") {
		bool.toggle()
	}
	.onAppear() {
		bool.toggle()
	}
	.sheet(isPresented: $bool, content: {
		NewChatView(selectedChat: .constant(MockData.mocChat), showSelectedChat: .constant(false))
	})
}
