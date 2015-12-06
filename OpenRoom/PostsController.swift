//
//  PostsController.swift
//  OpenRoom
//
//  Created by Lucas Haber on 12/4/15.
//  Copyright © 2015 lhaber. All rights reserved.
//

import UIKit
import Foundation
import Parse

class PostsController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CreateEditPostControllerDelegate, MyPostsControllerDelegate {
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var createButton: UIButton!
	@IBOutlet var myPostsButton: UIButton!
	@IBOutlet var buildingPicker: UIPickerView!
	
	@IBOutlet var filtersView: UIView!
	@IBOutlet var filterExpandBarView: UIView!
	@IBOutlet var filterExpandedConstraint: NSLayoutConstraint!
	@IBOutlet var filterCollapsedConstraint: NSLayoutConstraint!
	@IBOutlet var timePicker: UIDatePicker!
	@IBOutlet var dayLabel: UILabel!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var dayControl: UISegmentedControl!
	
	var buildings:[PFObject]! = []
	var posts : [PFObject]! = []
	var likeCounts : [Int]! = []
	var filtersExpanded: Bool = false
	
	var currentDayString: String = "Monday"
	var currentUserId: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		timePicker.datePickerMode = UIDatePickerMode.Time
		timePicker.date = NSDate()
		currentDayString = dayStringFromDate(NSDate())
		
		filterExpandBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "expandBarTapped"))
		
		initDayPicker()
		initBuildingPicker()
		
		self.tableView.registerNib(UINib(nibName: "PostTableCell", bundle: nil), forCellReuseIdentifier: "PostTableCell")
		
		reloadTable(timePicker.date)
	}
	
	func reloadTable(time: NSDate!) {
		
		dayLabel.text = currentDayString
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm"
		timeLabel.text = dateFormatter.stringFromDate(time)
		
		let query = PFQuery(className:"Posts")
		query.includeKey("building")
		
		if (buildingPicker.selectedRowInComponent(0) > 0) {
			let innerQuery = PFQuery(className: "Buildings")
			innerQuery.whereKey("name", equalTo: self.buildings[buildingPicker.selectedRowInComponent(0) - 1]["name"])
			query.whereKey("building", matchesQuery: innerQuery)
		}
		
		query.whereKey("dayOfWeek", equalTo: currentDayString)
		query.whereKey("hourMinuteStart", lessThanOrEqualTo: hourMinuteFromDate(time))
		query.whereKey("hourMinuteEnd", greaterThanOrEqualTo: hourMinuteFromDate(time))
		query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				self.posts = objects
				self.likeCounts = []
				
				for post in self.posts {
					
					let likesQuery = PFQuery(className: "Likes")
					likesQuery.whereKey("post", equalTo: post)
					likesQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
						
						self.likeCounts.append((objects?.count)!)
						
						self.tableView.reloadData()
					}
				}
				self.tableView.reloadData()
			} else {
				print(error)
			}
		}
	}
	
	func initBuildingPicker() {
		let query = PFQuery(className:"Buildings")
		query.orderByAscending("name")
		query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				
				self.buildings = objects
				self.buildingPicker.reloadAllComponents()
				
			} else {
				print(error)
			}
		}
	}
	
	func initDayPicker() {
		
		let weekDay = dayStringFromDate(timePicker.date)
	
		dayControl.selectedSegmentIndex = indexFromDay(weekDay);
		
	}
	
	func indexFromDay(dayString: String) -> Int {
		switch dayString {
		case "Monday":
			return 0
			
		case "Tuesday":
			return 1
			
		case "Wednesday":
			return 2
			
		case "Thursday":
			return 3
			
		case "Friday":
			return 4
			
		case "Saturday":
			return 5
			
		case "Sunday":
			return 6
			
		default:
			return 0
		}
	}
	
	func dayStringFromIndex(index: Int) -> String {
		switch index {
		case 0:
			return "Monday"
			
		case 1:
			return "Tuesday"
			
		case 2:
			return "Wednesday"
			
		case 3:
			return "Thursday"
			
		case 4:
			return "Friday"
			
		case 5:
			return "Saturday"
			
		case 6:
			return "Sunday"
			
		default:
			return "Monday"
			
		}
	}
	
	func dayStringFromDate(date: NSDate!) -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEE"
		return dateFormatter.stringFromDate(date)
	}
	
	func hourMinuteFromDate(date: NSDate!) -> Int {
		let calendar = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!

		let hours = calendar.component(NSCalendarUnit.Hour, fromDate:date)
		let minutes = calendar.component(NSCalendarUnit.Minute, fromDate: date)
		
		return (100*hours) + minutes
	}
	
	func expandBarTapped() {
		if (filtersExpanded) {
			UIView.animateWithDuration(0.333, animations: { () -> Void in
				self.filterExpandedConstraint.priority = 200;
				self.filterCollapsedConstraint.priority = 900;
				self.view.layoutIfNeeded()
			})
			
			filtersExpanded = false
		}
		else {
			UIView.animateWithDuration(0.333, animations: { () -> Void in
				self.filterExpandedConstraint.priority = 900;
				self.filterCollapsedConstraint.priority = 200;
				self.view.layoutIfNeeded()
			})

			filtersExpanded = true
		}
	}
	
	@IBAction func myPosts() {
		self.performSegueWithIdentifier("ShowMyPosts", sender: self)
	}
	
	@IBAction func createPost() {
		self.performSegueWithIdentifier("CreatePost", sender: self)
	}
	
	@IBAction func changeTime() {
		reloadTable(timePicker.date)
	}
	
	@IBAction func logout() {
		self.performSegueWithIdentifier("Logout", sender: self)
	}
	
	@IBAction func changeDay() {
		
		currentDayString = dayStringFromIndex(dayControl.selectedSegmentIndex)
		
		reloadTable(timePicker.date)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "CreatePost") {
			let vc = segue.destinationViewController as! CreateEditPostController;
			vc.delegate = self;
			vc.currentUserId = self.currentUserId;
		}
		else if (segue.identifier == "ShowMyPosts") {
			let vc = segue.destinationViewController as! MyPostsController;
			vc.delegate = self;
			vc.currentUserId = self.currentUserId;
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
		
		if (self.likeCounts.count > indexPath.row) {
			cell.likesLabel.text = String(self.likeCounts[indexPath.row])
		}
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm"
		cell.timeLabel.text = dateFormatter.stringFromDate(post["freeFrom"] as! NSDate) + " - " + dateFormatter.stringFromDate(post["freeUntil"] as! NSDate)
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 90
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		let post = posts[indexPath.row]
		
		let like = PFObject(className: "Likes")
		like["user"] = PFObject(withoutDataWithClassName:"Users", objectId:currentUserId)
		like["post"] = PFObject(withoutDataWithClassName:"Posts", objectId:post.objectId)
		like.saveInBackground()
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		reloadTable(timePicker.date)
	}
	
	// CreatePostsControllerDelegate
	
	func willClose() {
		reloadTable(timePicker.date)
	}
	
	// PickerViewDelegate
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		
		if row == 0 {
			return "All"
		}
		
		return String(buildings[row - 1]["name"]);
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return buildings.count + 1
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		reloadTable(timePicker.date)
	}
}
