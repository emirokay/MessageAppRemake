//
//  LoginView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

struct LoginView: View {
	@State private var email: String = ""
	@State private var password: String = ""
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .center) {
				Spacer()
				
				// Title Section
				HeaderView(title: "Login", subtitle: "Please sign in to continue.")
				
				Spacer()
				
				// Input Fields
				InputFieldView(icon: "envelope", placeholder: "Email", text: $email)
				InputFieldView(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
				
				// Login Button
				Button("Login") {
					//Login action
				}
				.primaryButtonStyle()
				.padding(.top, 10)
				
				Spacer()
				Spacer()
				
				// Sign Up Section
				HStack {
					Text("Don't have an account?")
						.foregroundColor(.gray)
					NavigationLink("Sign up", destination: RegisterView())
						.bold()
				}
				.padding(.bottom)
			}
			.padding()
		}
	}
	
	
}

#Preview {
	LoginView()
}
