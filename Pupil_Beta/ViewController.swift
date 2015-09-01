//
//  ViewController.swift
//  Pupil_Beta
//
//  Created by David Hurng on 8/28/15.
//  Copyright (c) 2015 Pupil. All rights reserved.
//

import UIKit

import Parse

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!

    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var docViewHeightConstraint: NSLayoutConstraint!
    //array to hold the data
    var messagesArray:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        
        //set self as delegate for txt view
        self.messageTextField.delegate = self
        
        //add tap gesture recofnizer
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        
        self.messageTableView.addGestureRecognizer(tapGesture)
        
        //retrieve
        self.retrieveMessages()
    }
//        let testObject = PFObject(className: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            println("Object has been saved.")
//        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonTapped(sender: UIButton) {
    
        //send button is tapped
        
        
        //call the end editing method for text field
        self.messageTextField.endEditing(true)
        
        //disable send and textfield
        self.messageTextField.enabled = false
        self.sendButton.enabled = false
        
        //create a pfobject
        var newMessageObject:PFObject = PFObject(className: "Message")
        
        //set text key to txt of messagetextfield
        newMessageObject["Text"] = self.messageTextField.text
        
        //save the obj
        newMessageObject.saveInBackgroundWithBlock {
            (success:Bool, error:NSError?) -> Void in
            
            if(success) {
                //Message has been saved
                
                //retrieve latest message
                self.retrieveMessages()
                
                NSLog("Saved!")
                
            } else {
                //error
                NSLog(error!.description)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                //enable txt and send
                self.sendButton.enabled = true
                self.messageTextField.enabled = true
                
                //clear it
                self.messageTextField.text = ""
            }

        }
    }
    
    func retrieveMessages() {
        //create new pfquery
        var query:PFQuery = PFQuery(className:"Message")
        
        query.findObjectsInBackgroundWithBlock {(objects:[AnyObject]?, error:NSError?) -> Void in
            //clear messages array
            self.messagesArray = [String]()
            
            //loop thru obj in array
            for messageObject in objects! {
                
                //get text column val of pfobj
                let messageText:String? = (messageObject as! PFObject)["Text"] as? String
                
                //assign into messagesArray
                if messageText != nil {
                    self.messagesArray.append(messageText!)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                //reload tableview
                self.messageTableView.reloadData()
            }
        }
    }
    
    func tableViewTapped() {
        //textfield end editing
        self.messageTextField.endEditing(true)
    }
    
    //MARK: textfield delegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.docViewHeightConstraint.constant = 320
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    //MARK:  table view delegate methods
    func textFieldDidEndEditing(textField: UITextField) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.docViewHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
        
            }, completion: nil)
    }
    

    //asking for cell in particular row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //create a table cell
        let cell = self.messageTableView.dequeueReusableCellWithIdentifier("MessageCell") as! UITableViewCell
        
        //customize the cell
        cell.textLabel?.text = self.messagesArray[indexPath.row]
        
        //return the cell
        return cell
    }
    
    //return rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }

}

