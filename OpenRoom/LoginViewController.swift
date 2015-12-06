//
//  ViewController.swift
//  OpenRoom
//
//  Created by Lucas Haber on 12/4/15.
//  Copyright © 2015 lhaber. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
	
	@IBOutlet var loginButton: UIButton!
	
	@IBOutlet var usernameField: UITextField!
	@IBOutlet var passwordField: UITextField!
	
	var currentUserId: String?

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func tapLogin() {
		
		let query = PFQuery(className:"Users")
		query.whereKey("username", equalTo: usernameField.text!)
		query.whereKey("password", equalTo: passwordField.text!)
		query.findObjectsInBackgroundWithBlock {
			(objects: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				if objects?.count == 1  {
					self.currentUserId = (objects![0] as PFObject).objectId
					dispatch_async(dispatch_get_main_queue()){
						self.performSegueWithIdentifier("DisplayLoggedIn", sender: self)
					}
				}
				else if objects?.count == 0 {
					let user = PFObject(className:"Users")
					user["username"] = self.usernameField.text
					user["password"] = self.passwordField.text
					user.saveInBackground()
				}
			} else {
				print(error)
			}
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "DisplayLoggedIn") {
			let vc = segue.destinationViewController as! PostsController;
			vc.currentUserId = self.currentUserId
		}
	}
}

