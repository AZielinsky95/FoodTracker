//
//  ViewController.swift
//  FoodTracker
//
//  Created by Alejandro Zielinsky on 2018-05-18.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var caloriesTextField: UITextField!
    @IBOutlet weak var mealDescriptionTextField: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var mealNameTextField: UITextField!
        @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var meal: Meal?
    

    @IBAction func cancel(_ sender: UIBarButtonItem){
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem)
    {
      //
        let name = mealNameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        let calories = Int(caloriesTextField.text!)
        let desc = mealDescriptionTextField.text!
        
        
        meal = Meal(name: name,photo: photo, photoURLString: nil, rating: rating, calories: calories!, description: desc)
        
        RequestController.uploadMeal(meal: meal!)
        {
            DispatchQueue.main.async()
            {
                self.performSegue(withIdentifier: "unwind", sender: self);
            }
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
//        let name = mealNameTextField.text ?? ""
//        let photo = photoImageView.image
//        let rating = ratingControl.rating
//        let calories = Int(caloriesTextField.text!)
//        let desc = mealDescriptionTextField.text!
//
//
//        meal = Meal(name: name,photo: photo, photoURLString: nil, rating: rating, calories: calories!, description: desc)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mealNameTextField.delegate = self
        
        if let meal = meal {
            navigationItem.title = meal.name
            mealNameTextField.text   = meal.name
            photoImageView.image = meal.photo
            if let r = meal.rating
            {
            ratingControl.rating = r
            }
            else
            {
            ratingControl.rating = 0;
            }
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }

    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        mealNameTextField.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = mealNameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
}

