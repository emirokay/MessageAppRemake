//
//  AppError.swift
//  MessageAppRemake
//
//  Created by Emir Okay on 25.11.2024.
//

import Foundation

struct AppError: Identifiable {
	let id = UUID()
	let title: String
	let message: String
}
