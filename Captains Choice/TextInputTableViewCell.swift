//
//  TextInputTableViewCell.swift
//  Captains Choice
//
//  Created by John Malatras on 1/30/17.
//  Copyright © 2017 John Malatras. All rights reserved.
//

import Foundation
import UIKit

protocol CustomDelegate: class {
    func nameEntered(tag: Int, text: String)
    func handicapEntered(tag: Int, text: String)

}

class TextInputTableViewCell: UITableViewCell {
    @IBOutlet weak var NameTF: UITextField!
    @IBOutlet weak var HandicapTF: UITextField!
    
    weak var delegate: CustomDelegate?

    @IBAction func NameTextEntered(_ sender: UITextField) {
        delegate?.nameEntered(tag: sender.tag, text: sender.text!)
    }
    
    @IBAction func HandicapTextEntered(_ sender: UITextField) {
        delegate?.handicapEntered(tag: sender.tag, text: sender.text!)
    }

    @IBAction func HandicapTextChanged(_ sender: UITextField) {
        delegate?.handicapEntered(tag: sender.tag, text: sender.text!)
    }
}

