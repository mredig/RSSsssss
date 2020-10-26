//
//  FeedViewModel.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import Combine

class FeedViewModel: NSObject, ObservableObject {
	let feedURL: URL

	@Published var state: State = .idle

	private var bag: Set<AnyCancellable> = []

	let parsingDelegate = ParsingDelegate()

	init(feedURL: URL) {
		self.feedURL = feedURL
		super.init()
		loadFeed()
	}

	private func loadFeed() {
		state = .loading
		FeedGrabber.getFeed(feedURL)
			.receive(on: RunLoop.main)
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { data in
					self.state = .loaded(String(data: data, encoding: .utf8) ?? "")

					let parser = XMLParser(data: data)
					parser.delegate = self.parsingDelegate
					if parser.parse() {
						print("success parsing")
					} else if let error = parser.parserError {
						print("Error parsing: \(error)")
					} else {
						print("Unspecified error while parsing")
					}

					print(self.parsingDelegate.rootNode)

				})
			.store(in: &bag)
	}

	enum State {
		case idle
		case loading
		case loaded(String)
		case error(Error)
	}
}

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
			\(tabs)Node: \(elementName) (\(indentation))
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
