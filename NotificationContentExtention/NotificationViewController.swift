//
//  NotificationViewController.swift
//  NotificationContentExtention
//
//  Created by Himani Sharma on 10/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    // MARK: - Outlets.
    @IBOutlet var notificationView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - View Lifecycle.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        print("Content extension called - 1")
        let notificationContent = notification.request.content.mutableCopy() as? UNMutableNotificationContent
        titleLabel.text = notificationContent?.title
        bodyLabel.text = notificationContent?.body
        
        if notificationContent!.attachments.isEmpty {
            // no attachmens available
            self.imageView.isHidden = true
        } else {
            for attachment in notificationContent!.attachments {
                
                if attachment.url.startAccessingSecurityScopedResource() {
                    print("Attachment URL:\(attachment.url)")
                    do {
                        let imageData = try Data(contentsOf: (attachment.url))
                        imageView.image = UIImage(data: imageData)
                    } catch let error {
                        print("Error:\(error.localizedDescription)")
                    }
                    attachment.url.stopAccessingSecurityScopedResource()
                }
            }
        }
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        print("Content extension called")
        let actionIdentifier = response.actionIdentifier
        if actionIdentifier == "open" {
            completion (.dismissAndForwardAction)
        } else if actionIdentifier == "cancel" {
            completion(.dismiss)
        }
    }
}
