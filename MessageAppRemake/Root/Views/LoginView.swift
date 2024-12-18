//
//  LoginView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

struct LoginView: View {
	@ObservedObject var viewModel: ContentViewModel
	@State private var email: String = ""
	@State private var password: String = ""
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .center) {
				Spacer()
				
				HeaderView(title: "Login", subtitle: "Please sign in to continue.")
				
				Spacer()
				
				InputFieldView(icon: "envelope", placeholder: "Email", text: $email)
				InputFieldView(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
				
				Button {
					viewModel.login(email: email, password: password)
				} label: {
					PrimaryButtonStyle(text: "Login", sysyemImage: "arrow.right", backgroundColor: .blue, width: 120)
				}
				.padding(.top, 10)
				
				Spacer()
				Spacer()
				
				HStack {
					Text("Don't have an account?")
						.foregroundColor(.gray)
					NavigationLink("Sign up", destination: RegisterView(viewModel: viewModel))
						.bold()
				}
				.padding(.bottom)
			}
			.padding()
		}
	}
}

#Preview {
	LoginView(viewModel: ContentViewModel())
}
