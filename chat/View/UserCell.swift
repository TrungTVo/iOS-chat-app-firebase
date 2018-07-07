//
//  UserCell.swift
//  chat
//
//  Created by Trung Vo on 6/27/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            
            if let chatPartnerId = message?.chatPartnerId() {
                Database.database().reference().child("users").child(chatPartnerId).observeSingleEvent(of: .value) { (snapshot) in
                    if let dictionary = snapshot.value as? [String : AnyObject] {
                        self.textLabel?.text = dictionary["name"] as? String
                        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                            self.profileImageView.loadImageUsingCacheWithURL(urlString: profileImageUrl)
                        }
                    }
                }
            }
            self.detailTextLabel?.text = message?.text
            if let seconds = message?.timestamp?.doubleValue {
                let timestamp_date = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
                self.timeLabel.text = dateFormatter.string(from: timestamp_date as Date)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 66, y: (textLabel?.frame.origin.y)!, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 66, y: (detailTextLabel?.frame.origin.y)!, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "user-icon"))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 24
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        return timeLabel
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.addSubview(profileImageView)
        self.addSubview(timeLabel)
        
        // constraint
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 9).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

