//
//  SimpleError.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/2/20.
//

import Foundation

public struct SimpleError: Error {
	public let message: String
	public let attachment: Any?
}

extension SimpleError {
	public init(message: String) {
		self.message = message
		self.attachment = nil
	}
}
