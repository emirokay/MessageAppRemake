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
				NavigationLink {
					ProfileEditView(viewModel: viewModel)
				} label: {
					VStack(alignment: .leading) {
						Image(systemName: "person.circle.fill")
						
						Text(viewModel.getCurrentUser().name)
							.font(.title3)
							.bold()
						Text(viewModel.getCurrentUser().about)
							.foregroundColor(.gray)
						
					}
					.padding(.vertical)
				}
				
				Section("Settings") {
					ForEach(viewModel.settingsOptions) { option in
						NavigationLink(destination: option.destination) {
							Label(option.title, systemImage: option.iconName)
						}
					}
				}
				
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
			.searchable(text: $searchText)
			.searchPresentationToolbarBehavior(.avoidHidingContent)
			.listStyle(InsetGroupedListStyle())
			.navigationTitle("Profile")
		}
	}
}

#Preview {
	ProfileView(viewModel: ProfileViewModel())
}
