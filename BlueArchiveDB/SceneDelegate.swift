//
//  SceneDelegate.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/22.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import CoreSpotlight
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
	var window: UIWindow?
	func scene(_: UIScene, continue userActivity: NSUserActivity)
	{
		Logger.spotlight.debug("\(userActivity.activityType)")
		if userActivity.activityType == CSSearchableItemActionType
		{
			let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as! String
			Logger.spotlight.debug("uniqueIdentifier: \(uniqueIdentifier)")
			presentCharacterInfoViewController(with: uniqueIdentifier)
		} else if userActivity.activityType == CSQueryContinuationActionType
		{
			if let searchQuery = userActivity.userInfo?[CSSearchQueryString] as? String
			{
				Logger.spotlight.info("「\(searchQuery)」で検索してたよ")
				let storyboard = UIStoryboard(name: "Main", bundle: nil)
				if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterSelect") as? CharacterSelect
				{
					viewController.SearchString = searchQuery
					viewController.modalTransitionStyle = .crossDissolve
					viewController.modalPresentationStyle = .fullScreen
					window?.rootViewController = viewController
					window?.makeKeyAndVisible()
				}
			}
		}
	}

	func scene(_: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>)
	{
		Logger.urlschema.log("URL Contexts: \(urlContexts)")
		guard let url = urlContexts.first?.url else
		{
			// No URL found
			Logger.urlschema.fault("No URL found")
			return
		}

		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else
		{
			// Invalid URL
			Logger.urlschema.fault("Invalid URL")
			return
		}

		let host = components.host

		switch host
		{
		case "home":
			// Home button pressed
			presentHomeViewController()
		default:
			Logger.urlschema.log("Host did not match any case: \(String(describing: host))")
		}

		window?.makeKeyAndVisible()
	}

	private func presentHomeViewController()
	{
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let viewController = storyboard.instantiateViewController(withIdentifier: "Home") as? ViewController
		{
			window?.rootViewController = viewController
		} else
		{
			Logger.urlschema.fault("Error: Failed to instantiate HomeViewController")
		}
	}

	private func presentCharacterInfoViewController(with uniqueIdentifier: String)
	{
		Logger.spotlight.info("uniqueIdentifier Func: \(uniqueIdentifier)")
		// もしunitIdが"studentData_"から始まる場合は
		if uniqueIdentifier.hasPrefix("studentData_")
		{
			// uniqueIdentifierの値のstudentData_以降の値を取得する
			let studentId = Int(uniqueIdentifier.dropFirst("studentData_".count))
			Logger.spotlight.log("studentId: \(studentId ?? 0)")
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterInfo") as? CharacterInfo
			{
				viewController.unitId = studentId!
				viewController.modalTransitionStyle = .crossDissolve
				viewController.modalPresentationStyle = .fullScreen
				window?.rootViewController = viewController
				window?.makeKeyAndVisible()
			}
		}

		func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions)
		{
			// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
			// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
			// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
			guard let _ = (scene as? UIWindowScene) else { return }
		}
	}
}
