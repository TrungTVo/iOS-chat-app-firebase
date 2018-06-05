//
//  LoginController+handlers.swift
//  chat
//
//  Created by Trung Vo on 6/4/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImage = info["UIImagePickerControllerEditedImage"]
        let originalImage = info["UIImagePickerControllerOriginalImage"]
        
        var selectedImagePicker: UIImage?
        
        if editedImage != nil {
            selectedImagePicker = editedImage as? UIImage
        } else if originalImage != nil {
            selectedImagePicker = originalImage as? UIImage
        }
        if selectedImagePicker != nil {
            profileImageView.image = selectedImagePicker
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel picker!")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentationControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    @objc func handleLogin() {
        // get string data from text fields
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            else {
                print("Form is not valid!")
                return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                let errcode = AuthErrorCode(rawValue: error!._code)
                if errcode == AuthErrorCode.invalidEmail {
                    print ("Invalid email!")
                } else if errcode == AuthErrorCode.missingEmail {
                    print ("This email is not existed!")
                } else if errcode == AuthErrorCode.wrongPassword {
                    print ("Wrong password!")
                }
                return
            }
            print("Successfully logged in!")
            // fade log in view controller away after log-in/registering
            self.dismiss(animated: true, completion: nil)
            
            Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
            }, withCancel: nil)
        }
    }
    
    @objc func handleRegister() {
        // get string data from text fields
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let name = nameTextField.text
            else {
                print("Form is not valid!")
                return
        }
        // authenticate user
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            if error != nil {
                let errcode = AuthErrorCode(rawValue: error!._code)
                if (errcode == .emailAlreadyInUse) {
                    print("This email is already used!")
                } else if (errcode == AuthErrorCode.weakPassword) {
                    print("This is weak password!")
                }
                return
            }
            print("Successfully authenticated user!")
            
            // save it to Firebase database
            var ref: DatabaseReference!
            ref = Database.database().reference(fromURL: "https://chat-app-50062.firebaseio.com/")
            let usersReference = ref.child("users").child((user?.user.uid)!)
            let values = ["name": name, "email": email]
            usersReference.updateChildValues(values, withCompletionBlock: {
                (err, ref) in
                if err != nil {
                    print (err)
                    return
                }
                print("Save user successfully to Firebase database!")
                
                // fade log in view controller away after log-in/registering
                self.dismiss(animated: true, completion: nil)
                
                Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.navigationItem.title = dictionary["name"] as? String
                    }
                }, withCancel: nil)
            })
        }
    }
}
