//
//  ContentView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import SwiftUI

struct ContentView: View {

	@StateObject var siteVM = SiteViewModel()

    var body: some View {
		NavigationView {
			VStack {
				TextField("Input a url with an rss feed.", text: $siteVM.siteInput)
					.padding(8)
					.background(Color(.secondarySystemBackground))
					.cornerRadius(8)
					.padding()

				viewModelView

				Spacer()
			}
			.navigationTitle("Add new Feed")
		}
    }

	@ViewBuilder private var viewModelView: some View {
		switch siteVM.state {
		case .idle:
			Text("Input a url with an rss feed.")
		case .loading(let site):
			Text("Loading \(site)")
		case .loaded:
			List() {
				if siteVM.rssLinks.isEmpty {
					Text("\(siteVM.siteTitle) has no detected RSS feeds")
				} else {
					ForEach(siteVM.rssLinks, id: \.self) { link in
						Text("\(link)")
					}
				}
			}
			.listStyle(GroupedListStyle())
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
