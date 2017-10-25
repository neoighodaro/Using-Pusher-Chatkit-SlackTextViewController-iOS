//
//  LoginViewController.swift
//  Chattr
//
//  Created by Neo Ighodaro on 24/10/2017.
//  Copyright © 2017 CreativityKills Co. All rights reserved.
//


import UIKit
import Alamofire

class LoginViewController: UIViewController {
    var username: String!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var textField: UITextField!
}

extension LoginViewController {
    // MARK: Initialise
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.isEnabled = false
        
        self.loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        self.textField.addTarget(self, action: #selector(typingUsername), for: .editingChanged)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) -> Void {
        if segue.identifier == "loginSegue" {
            let ctrl = segue.destination as! UINavigationController
            let actualCtrl = ctrl.viewControllers.first as! RoomListTableViewController
            actualCtrl.username = self.username
        }
    }
    
    // MARK: Helpers
    @objc func typingUsername(_ sender: UITextField) {
        self.loginButton.isEnabled = sender.text!.characters.count >= 3
    }
    
    @objc func loginButtonPressed(_ sender: Any) {
        let payload: Parameters = ["username": self.textField.text!]
        
        self.loginButton.isEnabled = false
        
        Alamofire.request(AppConstants.ENDPOINT + "/users", method: .post, parameters: payload).validate().responseJSON { (response) in
            switch response.result {
            case .success(_):
                self.username = self.textField.text!
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            case .failure(let error):
                print(error)
            }
        }
    }
}
