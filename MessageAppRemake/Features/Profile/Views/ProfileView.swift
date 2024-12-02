//
//  ProfileView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 27.11.2024.
//

import SwiftUI

struct ProfileView: View {
	@ObservedObject var viewModel: ProfileViewModel
	@State private var searchText = ""
	
	var body: some View {
		NavigationStack {
			List {
				// Profile Header
				VStack(alignment: .leading, spacing: 16) {
					Image(systemName: "person.circle.fill")
					//CircularProfileImageView(imageUrl: viewModel.currentUser?.profileImageURL, size: 100)

					VStack(alignment: .leading) {
						Text(viewModel.currentUser?.name ?? "Unknown User")
							.font(.title3)
							.bold()
						Text(viewModel.currentUser?.about ?? "No bio available")
							.foregroundColor(.gray)
					}
				}
				.padding(.vertical)

				// Settings Section
				Section("Settings") {
					ForEach(viewModel.settingsOptions) { option in
						NavigationLink(destination: option.destination) {
							Label(option.title, systemImage: option.iconName)
						}
					}
				}

				// Account Actions
				Section {
					Button("Log Out") {
						viewModel.signOut()
					}
					.foregroundColor(.red)

					Button("Delete Account") {
						viewModel.deleteAccount()
					}
					.foregroundColor(.red)
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationTitle("Profile")
		}
	}
}

#Preview {
	ProfileView(viewModel: ProfileViewModel())
}
