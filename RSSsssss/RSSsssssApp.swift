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

	@StateObject private var coreDataStack = CoreDataStack()

    var body: some Scene {
        WindowGroup {
            AddFeedView()
				.environment(\.managedObjectContext, coreDataStack.mainContext)
				.environmentObject(coreDataStack)
        }
    }
}

//struct CoreDataKey: EnvironmentKey {
//	static var defaultValue = CoreDataStack()
//}
