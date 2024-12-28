//
//  Untitled.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 17.12.2024.
//

import SwiftUI

struct UserDetailsView: View {
	var user: User?
	
	var body: some View {
		NavigationStack {
			VStack {
				CircularProfileImage(url: user?.profileImageURL, wSize: 130, hSize: 130)
					.padding(.top)
				Text(user?.name ?? "")
					.font(.title).bold()
				Text(user?.email ?? "")
					.foregroundStyle(.gray)
				Text(user?.about ?? "")
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding()
					.background(Color(.systemGray6))
					.cornerRadius(10)
					.padding(.horizontal)
				
				Spacer()
			}
			.navigationTitle("Contact Info")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	UserDetailsView(user: MockData.mocUser)
}
