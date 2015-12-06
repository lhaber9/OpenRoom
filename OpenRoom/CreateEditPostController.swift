//
//  CreatePostViewController.swift
//  OpenRoom
//
//  Created by Lucas Haber on 12/5/15.
//  Copyright © 2015 lhaber. All rights reserved.
//

import UIKit
import Foundation
import Parse

protocol CreateEditPostControllerDelegate {
	func willClose()
}

class CreateEditPostController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	
	var delegate: CreateEditPostControllerDelegate!
	
	@IBOutlet var roomNumberField: UITextField!
	@IBOutlet var buildingPicker: UIPickerView!
	@IBOutlet var fromTimePicker: UIDatePicker!
	@IBOutlet var toTimePicker: UIDatePicker!
	
	@IBOutlet var closeButton: UIButton!
	@IBOutlet var submitButton: UIButton!
	@IBOutlet var deleteButton: UIButton!
	
	var buildings:[PFObject]! = []
	var currentUserId: String?
	var post: PFObject?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let query = PFQuery(className:"Buildings")
		query.orderByAscending("name")
		query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
			if error == nil {
				
				self.buildings = objects
				self.buildingPicker.reloadAllComponents()
				
				// Select row if post has a building
				if self.post!["building"] != nil {
					var row = 0
					for (index, building) in self.buildings.enumerate() {
						if building.objectId == self.post!["building"].objectId {
							row = index
						}
					}
					self.buildingPicker.selectRow(row, inComponent: 0, animated: false)
				}
				
			} else {
				print(error)
			}
		}
		
		fromTimePicker.datePickerMode = UIDatePickerMode.Time
		toTimePicker.datePickerMode = UIDatePickerMode.Time
		
		if post == nil {
			post = PFObject(className:"Posts")
		}
		else {
			deleteButton.hidden = false
			fromTimePicker.date = post!["freeFrom"] as! NSDate
			toTimePicker.date = post!["freeUntil"] as! NSDate
			roomNumberField.text = String(post!["roomNumber"])
		}
		
	}
	
	@IBAction func close() {
		delegate.willClose()
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	@IBAction func delete() {
		post?.deleteInBackground()
		close()
	}
	
	@IBAction func submit() {
		
		post!["building"] = PFObject(withoutDataWithClassName:"Buildings", objectId:String(buildings[buildingPicker.selectedRowInComponent(0)].objectId!))
		post!["createdBy"] = PFObject(withoutDataWithClassName:"Users", objectId:self.currentUserId)
		post!["roomNumber"] = Int(self.roomNumberField.text!)
		
		let calendar = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
	
		let fromDateComponents = NSDateComponents()
		fromDateComponents.day = calendar.component(NSCalendarUnit.Day, fromDate: NSDate())
		fromDateComponents.month = calendar.component(NSCalendarUnit.Month, fromDate: NSDate())
		fromDateComponents.year = calendar.component(NSCalendarUnit.Year, fromDate: NSDate())
		fromDateComponents.hour = calendar.component(NSCalendarUnit.Hour, fromDate: fromTimePicker.date)
		fromDateComponents.minute = calendar.component(NSCalendarUnit.Minute, fromDate: fromTimePicker.date)
		
		let toDateComponents = NSDateComponents()
		toDateComponents.day = calendar.component(NSCalendarUnit.Day, fromDate: NSDate())
		toDateComponents.month = calendar.component(NSCalendarUnit.Month, fromDate: NSDate())
		toDateComponents.year = calendar.component(NSCalendarUnit.Year, fromDate: NSDate())
		toDateComponents.hour = calendar.component(NSCalendarUnit.Hour, fromDate: toTimePicker.date)
		toDateComponents.minute = calendar.component(NSCalendarUnit.Minute, fromDate: toTimePicker.date)

		post!["hourMinuteStart"] = (100 * fromDateComponents.hour) + fromDateComponents.minute
		post!["hourMinuteEnd"] = (100 * toDateComponents.hour) + toDateComponents.minute
		
		post!["freeFrom"] = calendar.dateFromComponents(fromDateComponents)
		post!["freeUntil"] = calendar.dateFromComponents(toDateComponents)
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "EEEE"
		post!["dayOfWeek"] = dateFormatter.stringFromDate(calendar.dateFromComponents(fromDateComponents)!)
		
		post!.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
			self.close()
		}
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return String(buildings[row]["name"]);
	}
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return buildings.count
	}
}