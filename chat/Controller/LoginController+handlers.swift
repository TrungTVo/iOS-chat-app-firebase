//
//  LoginController+handlers.swift
//  chat
//
//  Created by Trung Vo on 6/4/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit

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
}
