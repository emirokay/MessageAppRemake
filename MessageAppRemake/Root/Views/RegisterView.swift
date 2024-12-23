//
//  RegisterView.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 24.11.2024.
//

import SwiftUI

struct RegisterView: View {
	@ObservedObject var viewModel: ContentViewModel
	@Environment(\.dismiss) var dismiss
	
	@State private var fullName: String = ""
	@State private var email: String = ""
	@State private var password: String = ""
	@State private var confirmPassword: String = ""
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .center) {
				Spacer()
				
				HeaderView(title: "Sign Up", subtitle: "Create your account to get started.")
				
				Spacer()
				
				InputFieldView(icon: "person", placeholder: "Full name", text: $fullName)
				InputFieldView(icon: "envelope", placeholder: "Email", text: $email)
				InputFieldView(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
				InputFieldView(icon: "lock", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
				
				Button {
					viewModel.createUser(withEmail: email, password: password, confirmPassword: confirmPassword, fullname: fullName)
				} label: {
					PrimaryButtonStyle(text: "Sign Up", sysyemImage: "arrow.right", backgroundColor: .blue, width: 120)
				}
				.padding(.top, 10)
				
				Spacer()
				Spacer()
				
				HStack {
					Text("Already have an account?")
						.foregroundColor(.gray)
					Button("Log in") {
						dismiss()
					}
					.bold()
				}
				.padding(.bottom)
			}
		}
	}
}

#Preview {
	RegisterView(viewModel: ContentViewModel())
}
