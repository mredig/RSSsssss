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

	let contentHeightChangeCallback: (CGFloat) -> Void

	init(htmlString: String, contentHeightChangeCallback: @escaping (CGFloat) -> Void) {
		self.htmlString = htmlString
		self.url = nil
		self.contentHeightChangeCallback = contentHeightChangeCallback
	}

	init(url: URL, contentHeightChangeCallback: @escaping (CGFloat) -> Void) {
		self.url = url
		self.htmlString = nil
		self.contentHeightChangeCallback = contentHeightChangeCallback
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
		Coordinator(parent: self)
	}

	class Coordinator: NSObject, WKNavigationDelegate {
		let parent: WebView

		let webView: WKWebView = {
			let config = WKWebViewConfiguration()
//			config.preferences.minimumFontSize = 160
			let webView = WKWebView(frame: .zero, configuration: config)
			return webView
		}()

		init(parent: WebView) {
			self.parent = parent
			super.init()
			webView.navigationDelegate = self
		}

		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			parent.contentHeightChangeCallback(webView.scrollView.contentSize.height)
		}
	}
}
