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
				MainTabView()
			} else {
				LoginView(viewModel: viewModel)
			}
		}
		.overlay(loadingOverlay)
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
	
	private var loadingOverlay: some View {
		Group {
			if viewModel.isLoading {
				LoadingView(show: true)
			}
		}
	}
}

#Preview {
	ContentView()
}
