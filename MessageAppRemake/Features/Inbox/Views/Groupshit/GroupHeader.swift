//
//  GroupHeader.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 23.12.2024.
//

import SwiftUI

struct GroupHeader: View {
	let chat: Chat
	let users: [User]
		
	var body: some View {
		VStack {
			
			CircularProfileImage(url: chat.imageUrl, wSize: 100, hSize: 100)
			
			Text(chat.name)
				.font(.title2)
				.fontWeight(.semibold)
			
			Text("Crated By \(users.first(where: { $0.id == chat.createdBy })?.name ?? "Unknown")")
				.font(.footnote)
				.foregroundStyle(.gray)
			
			Text("Created At \(chat.createdAt.formatted(.dateTime.day().month(.twoDigits).year()))")
				.font(.footnote)
				.foregroundStyle(.gray)
		}
	}
}

