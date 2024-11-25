//
//  AppState.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.11.2024.
//

import Foundation
import Combine

protocol AppStateProtocol {
	var loadingPublisher: Published<Bool>.Publisher { get }
	var errorPublisher: Published<AppError?>.Publisher { get }
	func setLoading(_ isLoading: Bool)
	func setError(_ title: String, _ message: String)
	func clearError()
}

final class AppState: AppStateProtocol, ObservableObject {
	static let shared = AppState()
	
	@Published private(set) var isLoading: Bool = false
	@Published private(set) var appError: AppError? = nil
	
	var loadingPublisher: Published<Bool>.Publisher { $isLoading }
	var errorPublisher: Published<AppError?>.Publisher { $appError }
	
	private init() {}
	
	func setLoading(_ isLoading: Bool) {
		self.isLoading = isLoading
	}
	
	func setError(_ title: String, _ message: String) {
		self.isLoading = false
		self.appError = AppError(title: title, message: message)
	}
	
	func clearError() {
		self.appError = nil
	}
}
