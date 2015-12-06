//
//  MyPostsController.swift
//  OpenRoom
//
//  Created by Lucas Haber on 12/6/15.
//  Copyright © 2015 lhaber. All rights reserved.
//

import UIKit
import Foundation
import Parse

protocol MyPostsControllerDelegate {
	func willClose()
}

class MyPostsController: UIViewController, UITableViewDataSource, UITableViewDelegate, CreateEditPostControllerDelegate {
	
	var delegate: MyPostsControllerDelegate!
	
	@IBOutlet var tableView: UITableView!
	var posts : [PFObject]! = []
	var selectedPost: PFObject? = nil
	var currentUserId: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableView.registerNib(UINib(nibName: "PostTableCell", bundle: nil), forCellReuseIdentifier: "PostTableCell")
		
		reload()
	}
	
	func reload() {
		let query = PFQuery(className:"Posts")
		query.includeKey("building")
		query.whereKey("createdBy", equalTo: PFObject(withoutDataWithClassName:"Users", objectId:self.currentUserId))
		query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				self.posts = objects
				self.tableView.reloadData()
				
			} else {
				print(error)
			}
		}
	}
	
	@IBAction func close() {
		delegate.willClose()
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func willClose() {
		selectedPost = nil
		reload()
		delegate.willClose()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "EditPost") {
			let vc = segue.destinationViewController as! CreateEditPostController;
			vc.delegate = self;
			vc.currentUserId = self.currentUserId;
			vc.post = selectedPost
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return posts.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let post = posts[indexPath.row]
		
		let cell = tableView.dequeueReusableCellWithIdentifier("PostTableCell", forIndexPath: indexPath) as! PostTableCell
		cell.buildingLabel.text = String((post["building"] as! PFObject)["name"])
		cell.roomLabel.text = String(post["roomNumber"])
		cell.dayLabel.text = String(post["dayOfWeek"])
		cell.likesLabel.hidden = true
		cell.likesStaticLabel.hidden = true
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm"
		cell.timeLabel.text = dateFormatter.stringFromDate(post["freeFrom"] as! NSDate) + " - " + dateFormatter.stringFromDate(post["freeUntil"] as! NSDate)
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 90
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		selectedPost = posts[indexPath.row]
		self.performSegueWithIdentifier("EditPost", sender: self)
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

}