//
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation

class ParsedNode: CustomDebugStringConvertible {
	var parent: ParsedNode?
	var children: [ParsedNode] = []
	var attributes: [String: String]
	var content = Data()
	var elementName: String

	init(elementName: String, attributes: [String: String] = [:], parent: ParsedNode? = nil) {
		self.parent = parent
		self.attributes = attributes
		self.elementName = elementName
	}

	private func consoleOutput(_ indentation: Int) -> String {
		let tabs = Array(repeating: "\t", count: indentation).joined()

		return """
			\(tabs)Node: \(elementName)
			\(tabs)Attributes: \(attributes.map { "\(tabs)\t\($0.key): \($0.value)" } )
			\(tabs)Content: \(String(data: content, encoding: .utf8) ?? String(describing: content))
			\(tabs)Children:\n\(children
									.map { $0.consoleOutput(indentation + 1) }
									.reduce("", { $0 + $1 }))

			"""
	}

	var debugDescription: String {
		consoleOutput(0)
	}
}

