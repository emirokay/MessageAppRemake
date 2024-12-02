//
//  StartNewChat.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 1.12.2024.
//

import SwiftUI

struct NewChatView: View {
	@State var searchText = ""
	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		NavigationStack{
			SearchBarView(searchText: $searchText)
			List{
				Section {
					ZStack(alignment: .leading) {
						NavigationLink(destination: NewGroupChatView()) {
							EmptyView()
						}.opacity(0.0)
						Label("New Group", systemImage: "person.2")
					}
				}
				//List of contacts
				Section("Friends"){
					Text("MocUser")
					Text("MocUser")
					Text("MocUser")
				}
			}
			.navigationTitle("New Chat")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button{
						dismiss()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.foregroundStyle(.gray)
					}
				}
			}
		}
    }
}

#Preview {
	@Previewable @State var bool = false
	Button("Toggle") {
		bool.toggle()
	}
	.onAppear() {
		bool.toggle()
	}
	.sheet(isPresented: $bool, content: {
		NewChatView()
	})
}
