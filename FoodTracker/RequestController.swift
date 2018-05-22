//
//  RequestController.swift
//  FoodTracker
//
//  Created by Alejandro Zielinsky on 2018-05-21.
//  Copyright © 2018 Alejandro Zielinsky. All rights reserved.
//

import Foundation
import UIKit;

class RequestController {

   static var sessionConfig = URLSessionConfiguration.default
   static var token : String = ""
   static var username: String = ""
   static var password: String = ""
    
    
    static func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    static func downloadImage(url: URL,completion: @escaping (UIImage?) -> Void)
    {
        print("Download Started")
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                let img = UIImage(data: data);
                completion(img);
            }
        }
    }
    
    static func login(username:String,password:String,completion: @escaping () -> Void)
    {
        // let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard var URL = URL(string: "https://cloud-tracker.herokuapp.com/login") else {return}
        let URLParams = [
            "username": username,
            "password": password,
            ]
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: [])
            
            guard let results = json as? [String:Any] else {
                print("Error getting JSON Object");
                return;
            }
            
            token = results["token"] as! String;
            completion();
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    static func signUp(username:String,password:String, completion:@escaping () -> Void)
    {
        // let sessionConfig = URLSessionConfiguration.default
         let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

         guard var URL = URL(string: "https://cloud-tracker.herokuapp.com/signup") else {return}
         let URLParams = [
            "username": username,
            "password": password,
            ]
         URL = URL.appendingQueryParameters(URLParams)
         var request = URLRequest(url: URL)
         request.httpMethod = "POST"

         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            guard let results = json as? [String:Any] else {
                print("Error getting JSON Object");
                return;
            }
        
            token = results["token"] as! String;
            self.username = results["username"] as! String;
            self.password = results["password"] as! String;
            
            completion();

        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    static func getMeals(completion: @escaping ([Meal]?) -> Void)
    {
        //let sessionConfig = URLSessionConfiguration.default
        var allMeals = [Meal]();
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        guard let url = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Headers
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        request.addValue(self.token, forHTTPHeaderField: "token")
        
        //  //4kqxtujSsyAH8qtiVpysvwqV
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any?]]
            
            guard let results = json! else {
                print("Error getting JSON Object");
                return;
            }
            
            
            for dict in results
            {
                let meal = Meal(dict: dict);
                
                allMeals.append(meal!);
            }
            
            completion(allMeals);
        })
        
        
        
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    static func uploadImage(meal: Meal, completion: @escaping (String) -> Void ) {
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let url = URL(string: "https://api.imgur.com/3/image") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Headers
        
        request.addValue("Client-ID 887c27b7d390539", forHTTPHeaderField: "Authorization")
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        let dataImage : Data = UIImagePNGRepresentation(meal.photo!)!
        
        let uploadTask = session.uploadTask(with: request, from: dataImage) { (data, response, error) in
            if (error == nil) {
                let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any?]
                let dataKey = jsonResult!["data"] as! [String:Any]
                let linkURL = dataKey["link"] as! String
                
                completion(linkURL)
            }
        }
        
        uploadTask.resume()
    }
    
    static func uploadMeal(meal:Meal,completion: @escaping () -> Void)
    {
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        guard var URL = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals") else {return}
        
        let URLParams = [
            "title": meal.name,
            "description": meal.mealDescription,
            "calories": String(meal.calories),
            ]
        
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        // Headers
        
        request.addValue(self.token, forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String,Dictionary<String,Any?>>
            
    
            guard let results = json! else {
                print("Error getting JSON Object");
                return;
            }
            
            let mealDict = results["meal"]
            
            let id = mealDict!["id"] as! Int
            meal.mealID = String(id)
            
            uploadImage(meal: meal, completion: { (linkURL) in
                meal.photoURL = linkURL;
                
                uploadPhoto(meal: meal, completion:
                {
                    uploadRating(meal: meal, completion:
                        {
                            completion();
                    })
                })
            })
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    
    static func uploadPhoto(meal:Meal,completion: @escaping () -> Void)
    {
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard var URL = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals/\(meal.mealID!)/photo") else {return}
        
        let URLParams = [
            "imagePath": meal.photoURL!,
            ]
        
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        // Headers
        
        request.addValue(self.token, forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            completion();
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

    
    static func uploadRating(meal:Meal, completion: @escaping () -> Void)
    {
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard var URL = URL(string: "https://cloud-tracker.herokuapp.com/users/me/meals/\(meal.mealID!)/rate") else {return}
        
        let URLParams = [
            "rating": String(meal.rating!),
            ]
        
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        
        // Headers
        
        request.addValue(self.token, forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        /* Start a new Task */
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
            
            completion();
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }

 
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
     */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}

