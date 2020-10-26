//
//  ParsingDelegate.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation

class ParsingDelegate: NSObject, XMLParserDelegate {
	var currentPath: [String] = [] {
		didSet {
			print(currentPath)
		}
	}

	var rootNode: ParsedNode?
	var currentNode: ParsedNode?

	func parserDidStartDocument(_ parser: XMLParser) {
		rootNode = ParsedNode(elementName: "root")
		currentNode = rootNode
	}

	func parserDidEndDocument(_ parser: XMLParser) {
		currentNode = nil
	}

	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		currentPath.append(elementName)

		let newNode = ParsedNode(
			elementName: elementName,
			attributes: attributeDict,
			parent: currentNode)
		currentNode?.children.append(newNode)
		currentNode = newNode
	}

	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		assert(currentPath.last == elementName, "Mismatched last element: \(elementName) and \(currentPath.last ?? "")")

		_ = currentPath.popLast()

		currentNode = currentNode?.parent
	}

	func parser(_ parser: XMLParser, foundCharacters string: String) {
		let clean = string.trimmingCharacters(in: .whitespacesAndNewlines)
		currentNode?.content.append(Data(clean.utf8))
	}

	func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
		currentNode?.content.append(CDATABlock)
	}
}
