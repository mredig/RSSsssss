//
//  WebView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/31/20.
//

import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {

	let htmlString: String?
	let url: URL?

	init(htmlString: String) {
		self.htmlString = htmlString
		self.url = nil
	}

	init(url: URL) {
		self.url = url
		self.htmlString = nil
	}

	func makeUIView(context: Context) -> WKWebView {
		context.coordinator.webView
	}

	func updateUIView(_ webView: WKWebView, context: Context) {
		if let html = htmlString {
			webView.loadHTMLString(html, baseURL: nil)
		}
		if let url = url {
			let request = URLRequest(url: url)
			webView.load(request)
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	class Coordinator {
		let webView = WKWebView()
	}
}
