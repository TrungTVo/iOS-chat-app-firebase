//
//  LoginController.swift
//  chat
//
//  Created by Trung Vo on 6/1/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    // global variables
    var nameTextField : UITextField = UITextField()
    var emailTextField : UITextField = UITextField()
    var passwordTextField : UITextField = UITextField()
    
    // create input container view
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        // handle action
        button.addTarget(self, action: #selector(handleLoginRegister), for: UIControlEvents.touchUpInside)
        
        return button
    }()
    
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

    // logo image at the top
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "telegram-app")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // create segmented control for login and register
    let loginRegisterSegmentationControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: UIControlEvents.valueChanged)
        return sc
    }()

    // handle clicking login or register button
    @objc func handleLoginRegisterChange() {
        // changing button title
        let title = loginRegisterSegmentationControl.titleForSegment(at: loginRegisterSegmentationControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        // handle adding or removing name text field for each control
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentationControl.selectedSegmentIndex == 0 ? 100:150
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentationControl.selectedSegmentIndex == 0 ? 0:1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentationControl.selectedSegmentIndex == 0 ? 0.5:1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentationControl.selectedSegmentIndex == 0 ? 0.5:1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    // create all text fields with specified placeholder title
    func createTextField(title: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = title
        tf.translatesAutoresizingMaskIntoConstraints = false
        if title == "Password" {
            tf.isSecureTextEntry = true
        }
        return tf
    }

    // separator line between text fields
    func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        // add subview to main view
        self.view.addSubview(profileImageView)
        self.view.addSubview(loginRegisterSegmentationControl)
        self.view.addSubview(inputsContainerView)
        self.view.addSubview(loginRegisterButton)
        
        // set up input container view
        setupImageProfileView()
        setupLoginSegmentedControl()
        setupInputsContainerView()
        setupLoginRegisterButton()
    }
    
    func setupImageProfileView() {
        profileImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentationControl.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    func setupLoginSegmentedControl() {
        loginRegisterSegmentationControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginRegisterSegmentationControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentationControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentationControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainerView() {
        inputsContainerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        // create text fields
        nameTextField = createTextField(title: "Name")
        let nameSeparator = createSeparator()
        emailTextField = createTextField(title: "Email")
        let emailSeparator = createSeparator()
        passwordTextField = createTextField(title: "Password")
        let passwordSeparator = createSeparator()
        
        // add name, email, password to log in page
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparator)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparator)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeparator)
        
        // set up text fields
        setupTextFields(tf_child: nameTextField, tf_parent: nil, view_parent: inputsContainerView, separator: nameSeparator)
        setupTextFields(tf_child: emailTextField, tf_parent: nameTextField, view_parent: inputsContainerView, separator: emailSeparator)
        setupTextFields(tf_child: passwordTextField, tf_parent: emailTextField, view_parent: inputsContainerView, separator: passwordSeparator)
    }

    func setupTextFields(tf_child: UITextField, tf_parent: UITextField?, view_parent: UIView, separator: UIView) {
        if tf_parent != nil {
            tf_child.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
            tf_child.topAnchor.constraint(equalTo: (tf_parent?.bottomAnchor)!).isActive = true
            tf_child.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
            if tf_child == emailTextField {
                emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
                emailTextFieldHeightAnchor?.isActive = true
            } else if tf_child == passwordTextField {
                passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
                passwordTextFieldHeightAnchor?.isActive = true
            }
        } else {
            tf_child.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
            tf_child.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
            tf_child.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
            nameTextFieldHeightAnchor = tf_child.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
            nameTextFieldHeightAnchor?.isActive = true
        }
        // add separator line under name text field
        separator.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: tf_child.bottomAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    func setupLoginRegisterButton() {
        loginRegisterButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1.0)
    }
}

