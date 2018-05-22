//
//  SignUpViewController.swift
//  FoodTracker
//
//  Created by Alejandro Zielinsky on 2018-05-21.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    

    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

     // UserDefaults.standard.removeObject(forKey: "username")
     //   UserDefaults.standard.removeObject(forKey: "password")
      if (hasUserDefaults() == false)
       {
         pageTitle.text = "Sign Up!"
       }
        else
       {
         pageTitle.text = "Login!"
       }
    }
    
    func hasUserDefaults() -> Bool
    {
        return ((UserDefaults.standard.string(forKey: "username") != nil) &&
               (UserDefaults.standard.string(forKey: "password") != nil))
    }

    
    @IBAction func submit(_ sender: UIButton)
    {
        
        if(hasUserDefaults())
        {
            RequestController.login(username: usernameTextField.text!, password: passwordTextField.text!)
            {
               DispatchQueue.main.async()
               {
                let mealTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "mealTableViewController") as! MealTableViewController
                self.navigationController?.pushViewController(mealTableViewController, animated: true)
               }
            }
        }
        else
        {
            RequestController.signUp(username: usernameTextField.text!, password: passwordTextField.text!, completion:
            {
                DispatchQueue.main.async()
                {
                 UserDefaults.standard.set(self.usernameTextField.text!, forKey: "username")
                 UserDefaults.standard.set(self.passwordTextField.text!, forKey: "password")
                 let mealTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "mealTableViewController") as! MealTableViewController
                 self.navigationController?.pushViewController(mealTableViewController, animated: true)
                }
            })
        }
        
        
    }
}

extension SignUpViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField)
//    {
//        // Disable the Save button while editing.
//
//    }
}
