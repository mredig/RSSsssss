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

    var body: some Scene {
        WindowGroup {
			NavigationView {
				FeedListScreen()
			}
			.environmentObject(appDelegate.rssController.stack)
			.environmentObject(appDelegate.rssController)
        }
    }
}

//struct CoreDataKey: EnvironmentKey {
//	static var defaultValue = CoreDataStack()
//}
