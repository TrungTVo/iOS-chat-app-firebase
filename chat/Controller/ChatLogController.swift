//
//  ChatLogController.swift
//  chat
//
//  Created by Trung Vo on 6/18/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    
    func observeMessages() {
        if let currentUserId = Auth.auth().currentUser?.uid {
            let userMessagesRef = Database.database().reference().child("user-messages").child(currentUserId)
            userMessagesRef.observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                print("message ID: " + messageId)
                let messageRef = Database.database().reference().child("messages").child(messageId)
                messageRef.observe(.value, with: { (snap) in
                    if let dictionary = snap.value as? [String : AnyObject] {
                        let message = Message()
                        message.fromId = dictionary["fromId"] as? String
                        message.toId = dictionary["toId"] as? String
                        message.text = dictionary["text"] as? String
                        message.timestamp = dictionary["timestamp"] as? NSNumber
                        
                        if message.chatPartnerId() == self.user?.id {
                            self.messages.append(message)
                            DispatchQueue.global(qos: .userInteractive).async {
                                DispatchQueue.main.async {
                                    self.collectionView?.reloadData()
                                }
                            }
                        }
                
                    }
                }, withCancel: nil)
            }, withCancel: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: "cellId")
        setupInputComponents()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ChatMessageCell
        cell.backgroundColor = UIColor.white
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    let sendButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Send", for: UIControlState.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSend), for: UIControlEvents.touchDown)
        return button
    }()
    
    lazy var inputTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Enter message"
        textfield.delegate = self
        textfield.translatesAutoresizingMaskIntoConstraints = false
        return textfield
    }()
    
    let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()
    
    @objc func handleSend() {
        // save text message into firebase database
        let mess_ref = Database.database().reference(fromURL: "https://chat-app-50062.firebaseio.com/").child("messages")
        let childmess_ref = mess_ref.childByAutoId()
        
        // IDs of sender and recipient
        let toId = user?.id
        let fromId = Auth.auth().currentUser?.uid
        // timestamp for message
        let timestamp: NSNumber = NSDate().timeIntervalSince1970 as NSNumber
        
        // dictionary to store into database
        let value = ["text": inputTextField.text!, "toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
        childmess_ref.setValue(value) { (error, ref) in
            if error != nil {
                print (error!)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!)
            userMessagesRef.updateChildValues([childmess_ref.key:1])
            let recipientMessagesRef = Database.database().reference().child("user-messages").child(toId!)
            recipientMessagesRef.updateChildValues([childmess_ref.key:1])
        }
        
        // clear input textfield
        inputTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func setupInputComponents() {
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        view.addSubview(separator)
        
        separator.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // ios 9 constraints
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // adding send button
        containerView.addSubview(sendButton)
        containerView.addSubview(inputTextField)
        
        // ios 9 constraints
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    }

}
