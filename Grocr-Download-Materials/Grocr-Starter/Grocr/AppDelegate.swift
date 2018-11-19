/// Copyright (c) 2018 Razeware LLC





import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    FirebaseApp.configure()

    Database.database().isPersistenceEnabled = true

    return true
  }
}
