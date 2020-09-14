//
//  UserSettings.swift
//  SwiftCarbonFootprintApp
//
//  Created by  Ben Lee on 7/6/20.
//  Copyright © 2020  Ben Lee. All rights reserved.
//

import AuthenticationServices
import Foundation
import UIKit
import Firebase
import Security
import FirebaseUI

class UserSettings: UIViewController, FUIAuthDelegate {

    @IBOutlet weak var displayNameLabel: UILabel!
    let user = Auth.auth().currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        displayNameLabel.text = "Welcome " + String(user.displayName ?? "user")
    }

    @IBAction func changeUserDisplayName(_ sender: UIButton) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter details?",
                                                message: "Enter your preferred display name",
                                                preferredStyle: .alert)

        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in

            //getting the input values from user
            let displayName = alertController.textFields?[0].text
            
            self.displayNameLabel.text = "Welcome " + String(displayName ?? "user")
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = displayName
            changeRequest?.commitChanges { (error) in
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }

        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signUserOut(_ sender: UIButton) {
        try? Auth.auth().signOut()
        self.returnToWelcome()
    }

    @IBAction func deleteAccount(_ sender: UIButton) {
        self.user.delete { error in
          if let error = error {
            if let errCode = AuthErrorCode(rawValue: error._code) {
                 self.displayErrorMessage(displayMessage:
                                          "Error: Could not delete account at this time.")
            }
          } else {
            // Account deleted.
            self.returnToWelcome()
          }
        }
    }

    @IBAction func resetUserPassword(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: self.user.email!) { error in
            // Error Message
            if let error = error {
                if let errCode = AuthErrorCode(rawValue: error._code) {
                     self.displayErrorMessage(displayMessage: "Error: Could not reset password at this time.")
                }
                return
            }
        }
    }

    @IBAction func updateUserEmailAddress(_ sender: UIButton) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter details?",
                                                message: "Enter your preferred email address",
                                                preferredStyle: .alert)

        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            let email = alertController.textFields?[0].text
            let confirmEmail = alertController.textFields?[1].text

            if email == confirmEmail {
                Auth.auth().currentUser?.updateEmail(to: email!) { (error) in
                    // Error Message
                    if let error = error {
                        if let errCode = AuthErrorCode(rawValue: error._code) {
                            self.displayErrorMessage(displayMessage: "Error: Could not update user email address at this time.")
                        }
                        return
                    }
                }
            }
        }

        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }

        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Email"
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "Confirm Email"
        }

        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }

    // Storyboard transition back to Welcome view.
    func returnToWelcome() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "Welcome")
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }

    func displayErrorMessage(displayMessage: String) {
        // An error happened.
        let alert = UIAlertController(title: "Alert",
                                      message: displayMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
