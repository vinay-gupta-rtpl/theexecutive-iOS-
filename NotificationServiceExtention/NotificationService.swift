//
//  NotificationService.swift
//  NotificationServiceExtention
//
//  Created by Himani Sharma on 10/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
       /* if let notificationId = request.content.userInfo["notification_id"] as? String {
            
           // API call for read status update
            NotificationModel().updateReadStatus(notificationId: notificationId, success: { _ in
                
            }, failure: { _ in
                
            })
        } */
        
        if let bestAttemptContent = bestAttemptContent {
            if let urlString = request.content.userInfo["image_url"] as? String, let fileUrl = URL(string: urlString) {
                // Modify the notification content here...
                bestAttemptContent.title = "\(bestAttemptContent.title)"
                bestAttemptContent.subtitle = "\(bestAttemptContent.subtitle)"
                bestAttemptContent.body = "\(bestAttemptContent.body)"
                
                URLSession.shared.downloadTask(with: fileUrl) { (location, _, _) in
                    if let location = location {
                        // Move temporary file to remove .tmp extension
                        let tmpDirectory = NSTemporaryDirectory()
                        let tmpFile = "file:".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
                        let tmpUrl = URL(string: tmpFile)!
                        try? FileManager.default.moveItem(at: location, to: tmpUrl)
                        // Add the attachment to the notification content
                        if let attachment = try? UNNotificationAttachment(identifier: fileUrl.lastPathComponent, url: tmpUrl) {
                            self.bestAttemptContent?.attachments = [attachment]
                        }}
                    // Serve the notification content
                    contentHandler(self.bestAttemptContent!)
                    }.resume()
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
            print("Time expired for notification.")
        }
    }
}
