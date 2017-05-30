//
//  InputTextView.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 29/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import UIKit

class InputTextView: UIView {
    
    let messageTextField = UITextField()
    let sendButton = UIButton()
    
    typealias ButtonClickHandler = (String) -> ()
    var buttonPressed: ButtonClickHandler?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGray
        
        self.messageTextField.translatesAutoresizingMaskIntoConstraints = false
        self.messageTextField.backgroundColor = UIColor.white
        self.messageTextField.layer.cornerRadius = 8
        self.messageTextField.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.messageTextField.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.messageTextField.layer.shadowOpacity = 1.0
        self.messageTextField.layer.shadowRadius = 0.0
        self.messageTextField.layer.masksToBounds = false
        self.messageTextField.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0)
        
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.addTarget(self, action: #selector(InputTextView.sendButtonPressed), for: .touchUpInside)
        self.sendButton.setTitle("Enviar", for: .normal)
        self.sendButton.tintColor = UIColor.white
        
        self.addSubview(messageTextField)
        self.addSubview(sendButton)
        
        let views: [String: Any] = ["messageTextField" : messageTextField, "sendButton" : sendButton]
        let metrics = ["hmargin" : 15, "vmargin" : 5]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vmargin-[messageTextField]-vmargin-|",
                                                           options: [],
                                                           metrics: metrics,
                                                           views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-vmargin-[messageTextField]-hmargin-[sendButton]-hmargin-|",
                                                           options: NSLayoutFormatOptions.alignAllCenterY,
                                                           metrics: metrics,
                                                           views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func sendButtonPressed() {
        if let message = self.messageTextField.text {
            self.messageTextField.text = ""
            buttonPressed?(message)
        }
    }

}
