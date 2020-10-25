//
//  ContentView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import SwiftUI

struct ContentView: View {

	@StateObject var siteVM = SiteViewModel(site: URL(string: "https://mikespsyche.com")!)

    var body: some View {
		switch siteVM.state {
		case .idle:
			Text("idle")
		case .loading:
			Text("loading")
		case .loaded:
			List(siteVM.rssLinks, id: \.self) { link in
				Link("\(link)", destination: link)
			}
		case .error(let error):
			Text("Error: \(error as NSError)")
		}

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
