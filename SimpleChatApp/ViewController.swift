//
//  ViewController.swift
//  SimpleChatApp
//
//  Created by Shekhar Chaudhary on 01/02/20.
//  Copyright © 2020 Shekhar Chaudhary. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    
    var messagesArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        
        //Set self as the delegate for the delegate
        self.messageTextField.delegate = self
        
        //Add a tap gesture recognizer to tableview
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.messageTableView.addGestureRecognizer(tapGesture)
        
        //Retrieve messages from Parse
        self.retrieveMessages()
        
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        
        //Send button is tapped
        
        // Call the end editing method for TextField
        self.messageTextField.endEditing(true)
        
        //Disable the send button and textField
        self.messageTextField.isEnabled = false
        self.sendButton.isEnabled = false
        
        //Create a PFObject
        var newMessageObject: PFObject = PFObject(className: "Message")
        
        //Set Text Key to the text of the messageTextField
        newMessageObject["Text"] = self.messageTextField.text

        //Save the PFObject
        newMessageObject.saveInBackground { (success: Bool, error: Error?) in
            
            if(success){
                //Message have been saved Yay!
                //Retrieve the latest messages and reload the table
                self.retrieveMessages()
                NSLog("Message Saved Successfully")
            }
            else{
                //Something Bad happened
                NSLog(error.debugDescription)
            }
            
            DispatchQueue.main.async(){
                
                //Enable the send button and textField
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
                
            }
            
        }
       
    }
    
    func retrieveMessages(){
        
        //Create a new PFQuery
        let query:PFQuery = PFQuery(className: "Message")
        
        //Call find Objects in background
        query.findObjectsInBackground { (objects: [AnyObject]!, error: Error!) -> Void in
            
            //Clear messagesArray
            self.messagesArray = [String]()
            
            //Loop through the objects array
            for messageObject in objects{
                
                //Retrieve the Text column valueof each PFObject
                let messageText:String? = (messageObject as! PFObject)["Text"] as? String
            
                //Assign to our messagesArray
                if messageText != nil{
                    self.messagesArray.append(messageText!)
                }
            }
            
            DispatchQueue.main.async {
                
                //Reload tableView
                self.messageTableView.reloadData()
            }
        }
    }
    
    @objc func tableViewTapped(){
        
        //Force the textField to end editing
        self.messageTextField.endEditing(true)
    }
    
    // MARK: TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //Perform an animatoion to grow dock view
        self.view.layoutIfNeeded()
               
               UIView.animate(withDuration: 0.5, animations: {
                   
                   self.dockViewHeightConstraint.constant = 380
                   self.view.layoutIfNeeded()
                   
               }, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //Perform an animatoion to Set back dock view to orignal size
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    // MARK: Tableview Delegate Methods
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create a Table cell
        let cell = self.messageTableView.dequeueReusableCell(withIdentifier: "MessageCell")!
        
        //Customize the cell
        cell.textLabel?.text = messagesArray[indexPath.row]
        
        //Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagesArray.count
    }

}

