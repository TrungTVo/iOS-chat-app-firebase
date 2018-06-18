//
//  ViewController.swift
//  chat
//
//  Created by Trung Vo on 6/1/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named: "write-icon")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserLoggedIn()
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserLoggedIn() {
        // user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavbarTitle()
        }
    }
    
    func fetchUserAndSetupNavbarTitle() {
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["name"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.setupNavBarWithUser(user: user)
            }
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User) {
        // wrapper
        let titleView = UIView()
        titleView.backgroundColor = UIColor.yellow
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        
        // profile image view
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 16
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        if user.profileImageUrl != nil {
            profileImageView.loadImageUsingCacheWithURL(urlString: user.profileImageUrl!)
        }
        
        // user name label view
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        
        // container
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(profileImageView)
        container.addSubview(nameLabel)
        titleView.addSubview(container)
        
        container.heightAnchor.constraint(equalToConstant: 80).isActive = true
        container.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        container.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        profileImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 10).isActive = true
        profileImageView.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.4).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        
        nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 0.4).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: container.widthAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        /*
        nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        */
    }
    
    @objc func showChatController() {
        /*
        let chatController = ChatLogController()
        navigationController?.pushViewController(chatController, animated: true)
        */
        print(123)
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
}
