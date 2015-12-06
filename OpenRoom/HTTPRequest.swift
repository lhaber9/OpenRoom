//
//  HTTPRequest.swift
//  OpenRoom
//
//  Created by Lucas Haber on 12/4/15.
//  Copyright © 2015 lhaber. All rights reserved.
//

import Foundation


class HTTPRequest : NSObject {
	
	static func makeRequest() {
		var urlString = "http://api.shephertz.com" // Your Normal URL String
		var url = NSURL(fileURLWithPath: <#T##String#>) // Creating URL
		var request = NSURLRequest(URL: url!)// Creating Http Request
		
		// Creating NSOperationQueue to which the handler block is dispatched when the request completes or failed
		var queue: NSOperationQueue = NSOperationQueue()
		
	}
	
	
 
	// Sending Asynchronous request using NSURLConnection
	NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{(response:NSURLResponse!, responseData:NSData!, error: NSError!) -&gt;Void in
 
	if error != nil {
		println(error.description)
		self.removeActivityIndicator()
	}
	else {
		//Converting data to String
		var responseStr:NSString = NSString(data:responseData, encoding:NSUTF8StringEncoding)
	}
	})
	
}