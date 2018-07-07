//
//  ChatMessageCell.swift
//  chat
//
//  Created by Trung Vo on 6/29/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        // ios 9 constraints
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
