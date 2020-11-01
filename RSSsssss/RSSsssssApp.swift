//
//  RSSsssssApp.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import SwiftUI

@main
struct RSSsssssApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	@StateObject private var rssController = RSSController(coreDataStack: CoreDataStack())

    var body: some Scene {
        WindowGroup {
			NavigationView {
				FeedListView()
			}
			.environmentObject(rssController.stack)
			.environmentObject(rssController)
        }
    }
}

//struct CoreDataKey: EnvironmentKey {
//	static var defaultValue = CoreDataStack()
//}
