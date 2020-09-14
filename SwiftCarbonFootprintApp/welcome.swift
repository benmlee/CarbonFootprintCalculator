//
//  welcome.swift
//  SwiftCarbonFootprintApp
//
//  Created by  Ben Lee on 5/25/20.
//  Copyright © 2020  Ben Lee. All rights reserved.
//

import AuthenticationServices
import Foundation
import UIKit
import Firebase
import Security
import FirebaseUI

class welcome : UIViewController, FUIAuthDelegate {
    let authUI = FUIAuth.defaultAuthUI()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                // Transition to next view
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
            }
        }
    }

    @IBAction func logInTapped(_ sender: UIButton) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                // Transition to next view
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
            } else {
                // No user is signed in.
                self.login()
            }
        }
    }

    func login() {

        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [
          FUIGoogleAuth(), FUIEmailAuth()
        ]
        self.authUI?.providers = providers
        let authViewController = authUI?.authViewController()
        self.present(authViewController!, animated: true)

    }

    @IBAction func logoutUser(_ sender: AnyObject) {
        //try! Auth.auth().signOut()
        try? authUI?.signOut()
    }

     // Handler for result of Google/FB sign-up flows
   func application(_ app: UIApplication, open url: URL,
                    options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
       let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String?
    if (FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication!))! {
       return true
     }
     // other URL handling goes here.
     return false
   }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
      // handle user and error as necessary
        if user != nil {
            // User is signed in.
            // Transition to next view
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
        }
    }
}
