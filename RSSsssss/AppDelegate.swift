//
//  AppDelegate.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

	let rssController = RSSController(coreDataStack: CoreDataStack())

	override init() {
		super.init()

		rssController.refreshAllFeeds()
	}
}
