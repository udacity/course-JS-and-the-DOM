import UIKit
import SwiftUI // Required for UIHostingController and MainTabView

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // 1. Create the SwiftUI view that will be the root view
        let mainTabView = MainTabView()

        // 2. Create a UIHostingController to host the SwiftUI view
        let hostingController = UIHostingController(rootView: mainTabView)

        // 3. Create a new UIWindow
        window = UIWindow(frame: UIScreen.main.bounds)

        // 4. Set the hosting controller as the root view controller of the window
        window?.rootViewController = hostingController

        // 5. Make the window key and visible
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: UISceneSession Lifecycle (If you were using Scenes)
    // If your project supports scenes (iOS 13+), you might configure them here or in SceneDelegate.
    // For this setup, we are directly setting the rootViewController on the window,
    // which is simpler for projects not explicitly using SceneDelegate.

    /*
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    */
}
