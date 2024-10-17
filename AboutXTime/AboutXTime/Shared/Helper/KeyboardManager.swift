//
//  KeyboardManager.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/18.
//

import Foundation
import UIKit

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
