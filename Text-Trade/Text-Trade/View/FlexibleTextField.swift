//
//  FlexibleTextField.swift
//  Text-Trade
//
//  Created by Steven Perrin on 3/11/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit

class FlexibleTextField: UITextField {

   private var padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    
    override func awakeFromNib() {
        setupView()
        super.awakeFromNib()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func setupView() {
        let placeholder = NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        self.attributedPlaceholder = placeholder
    }

}
