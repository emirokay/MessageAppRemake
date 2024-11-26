//
//  InboxView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 26.11.2024.
//

import SwiftUI

struct InboxView: View {
	@StateObject private var viewModel = InboxViewModel()
	
    var body: some View {
		NavigationStack {
			VStack {
				if let user = viewModel.currentUser {
					Text(user.name)
					Text(user.email)
					Text(user.about ?? "")
				}
				Text(viewModel.currentUser?.name ?? "no name")
				Text(viewModel.currentUser?.email ?? "no mail")
				Text(viewModel.currentUser?.about ?? "no abt")
				
				Button("sign out") {
					viewModel.signOut()
				}
			}
		}
    }
}

#Preview {
    InboxView()
}
