//
//  NotificationTableViewCell.swift
//  DelamiEcommerceApp
//
//  Created by Himani Sharma on 09/05/18.
//  Copyright © 2018 Nish-Ranosys. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var readMarkLabel: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var imageStack: UIStackView!
    
    // MARK: - ViewSetup methods
    func setUpMethod(notification: NotificationModel, index: Int) {
        if let title = notification.title {
            titleLabel.text = title
        } else {
            titleLabel.isHidden = true
        }
        descriptionLabel.text = notification.description
        
        // Set date and Time accordingly.
        if let createdDate = notification.sentDate {
            let dateAndTime = self.getLocalTimeFrom(UTCTime: createdDate)
            dateAndTimeLabel.text = dateAndTime
        }
        
        if let imageURL = notification.image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if imageURL != "" {
                 notificationImageView.isHidden = false
                if let url = URL(string: imageURL) {
                    
                    let request = URLRequest(url: url)
                    DispatchQueue.global(qos: .background).async {
                        self.notificationImageView.setImageWithUrlRequest(request, placeHolderImage: Image.placeholder, success: { (_, _, image, _) -> Void in
                            DispatchQueue.main.async(execute: {
                                self.notificationImageView.alpha = 0.0
                                self.notificationImageView.image = image
                                UIView.animate(withDuration: 0.5, animations: {self.notificationImageView.alpha = 1.0})
                            })
                        }, failure: nil)
                    }
                }
            } else {
                notificationImageView.isHidden = true
            }
        } else {
            notificationImageView?.isHidden = true
        }
        if !notification.isMessageReaded {
            readMarkLabel.backgroundColor = #colorLiteral(red: 0.2784313725, green: 0.7254901961, blue: 0.4392156863, alpha: 1)
            self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            readMarkLabel.backgroundColor = #colorLiteral(red: 0.4509803922, green: 0.4509803922, blue: 0.4509803922, alpha: 1)
            self.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        }
    }
    
    /* Convert Date and Time according to UTC format */
    
    func getLocalTimeFrom(UTCTime: String) -> String {
        let UTCDateFormatter = DateFormatter()
        UTCDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        UTCDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone //
        
        let dateInUTC: Date? = UTCDateFormatter.date(from: UTCTime) // utc format
        let seconds: Int = NSTimeZone.system.secondsFromGMT() // offset second
        
        let localDateFormatter = DateFormatter()
        localDateFormatter.dateFormat = "dd-MM-yyyy, hh:mm a"
        localDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: seconds) as TimeZone
        
        // formatted string
        //        return localDateFormatter.string(from: dateInUTC!)
        
        // if today's date then it will show "Today"
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = SystemConstant.dateFormatterPattern.localized() // "dd-MM-yyyy"
        //  Get the result string
        let todaysDate = formatter.string(from: date)
        
        let utcDateAndTime = localDateFormatter.string(from: dateInUTC!).components(separatedBy: ",")
        let utcDate = utcDateAndTime.first
        
        return utcDate == todaysDate ? ConstantString.today.localized() + ", " + utcDateAndTime.last! : localDateFormatter.string(from: dateInUTC!)
    }
    
    // MARK: - Cell Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.readMarkLabel.layer.cornerRadius = readMarkLabel.frame.width/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
