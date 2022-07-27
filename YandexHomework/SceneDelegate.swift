//
//  SceneDelegate.swift
//  YandexHomework
//
//  Created by Fedor Penin on 27.07.2022.
//

import UIKit
import CocoaLumberjack

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let navigationController = UINavigationController(rootViewController: HomeViewController())
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        configureNavbarTitle()
        window?.makeKeyAndVisible()

        DDLog.add(DDOSLogger.sharedInstance)
        dynamicLogLevel = .info
        testLogger()
    }
}

private extension SceneDelegate {

    func testLogger() {
        DDLogVerbose("Verbose")
        DDLogDebug("Debug")
        DDLogInfo("Info")
        DDLogWarn("Warn")
        DDLogError("Error")
    }

    func configureNavbarTitle() {
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = 24
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.paragraphStyle: style]
    }
}
