//
//  Extensions.swift
//  chat
//
//  Created by Trung Vo on 6/11/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit
let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWithURL(urlString: String) {
        self.image = nil
        // check if profile image stored in cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage as? UIImage
            return
        }
        // otherwise, fire off new download image
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print (error!)
                return
            }
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async {
                    // store profile image url in cache
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage
                    }
                }
            }
        }.resume()
    }
}
