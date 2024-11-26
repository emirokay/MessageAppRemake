//
//  ContentView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	
	var body: some View {
		Group {
			if viewModel.userSession != nil {
				InboxView()
			} else if viewModel.userSession != nil {
				ProgressView("Loading user data...")
			}  else {
				LoginView(viewModel: viewModel)
			}
		}
		.overlay {
			LoadingView(show: viewModel.isLoading)
		}
		.alert(item: $viewModel.appError) { appError in
			Alert(
				title: Text(appError.title),
				message: Text(appError.message),
				dismissButton: .default(Text("OK")) {
					viewModel.clearError()
				}
			)
		}
	}
}

#Preview {
	ContentView()
}
