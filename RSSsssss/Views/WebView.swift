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

	private var _scrollInsets: UIEdgeInsets = .zero

	let contentHeightChangeCallback: ((CGFloat) -> Void)?
	var scrollOffsetCallbacks: [(CGPoint) -> Void] = []

	init(htmlString: String, contentHeightChangeCallback: ((CGFloat) -> Void)? = nil) {
		self.htmlString = Self.injectStyling(into: htmlString)
		self.url = nil
		self.contentHeightChangeCallback = contentHeightChangeCallback
	}

	init(url: URL, contentHeightChangeCallback: ((CGFloat) -> Void)? = nil) {
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

		webView.scrollView.contentInset = _scrollInsets
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}

	private static func injectStyling(into inputHtml: String) -> String {
		guard !inputHtml.contains("<html>") else { return inputHtml }

		let scaling = ##"<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />"##
		let style = """
		<style>
		img { max-width: 100%; margin-bottom: 16pt; }
		iframe { max-width: 100% }
		div { max-width: 100% }
		body { background-color: #fff; color: #111; }
		body { font-family: Helvetica, Arial, sans-serif; }

		@media screen and (prefers-color-scheme: dark) {
			body { background-color: #000; color: #ddd; }
			a { color: #0af; }
		}
		</style>
		"""

		return scaling + style + inputHtml
	}

	class Coordinator: NSObject, WKNavigationDelegate {
		let parent: WebView

		let webView: WKWebView = {
			let config = WKWebViewConfiguration()
			let webView = WKWebView(frame: .zero, configuration: config)
			return webView
		}()

		init(parent: WebView) {
			self.parent = parent
			super.init()
			webView.navigationDelegate = self
		}

		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			parent.contentHeightChangeCallback?(webView.scrollView.contentSize.height)


			let js = """
			var imgs = document.getElementsByTagName("img");

			for (var i = 0; i < imgs.length; i++) {
				imgs[i].removeAttribute("width");
				imgs[i].removeAttribute("height");
			}

			var iframes = document.getElementsByTagName("iframe");

			for (var i = 0; i < iframes.length; i++) {
				iframes[i].removeAttribute("width");
				iframes[i].removeAttribute("height");
			}
			"""

			webView.evaluateJavaScript(js) { _, error in
				if let error = error {
					print("Error cleaning elements: \(error)")
				}
			}
		}
	}
}

extension WebView {
	func scrollInsets(_ insets: UIEdgeInsets) -> Self {
		var new = self
		new._scrollInsets = insets
		return new
	}
}
