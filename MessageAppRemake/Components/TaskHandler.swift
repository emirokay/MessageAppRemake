//
//  TaskHandler.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 27.12.2024.
//

class TaskHandler {
	static func performTaskWithLoading(_ task: @escaping () async throws -> Void) {
		let appState = AppState.shared
		appState.setLoading(true)
		Task {
			defer { appState.setLoading(false) }
			do {
				try await task()
			} catch {
				appState.setError("Operation Failed", error.localizedDescription)
			}
		}
	}
	
	static func performTask(_ task: @escaping () async throws -> Void) {
		let appState = AppState.shared
		Task {
			do {
				try await task()
			} catch {
				appState.setError("Operation Failed", error.localizedDescription)
			}
		}
	}
}

