//
//  UIViewFirstResponder.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 30/5/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import UIKit

extension UIView {
    
    func findFirstResponder() -> UIView? {
        
        if self.isFirstResponder {
            return self
        }
        
        for subView in self.subviews {
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        
        return nil
    }
}
