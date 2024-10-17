//
//  OpenedCapsulesViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/18.
//

import Foundation
import Combine
import SwiftUI

class OpenedCapsulesViewModel: ObservableObject {
    @Published var birthDate: Date? {
        didSet {
            if let date = birthDate {
                UserDefaults.standard.set(date, forKey: "birthDate")
            }
        }
    }

    init() {
        if let savedDate = UserDefaults.standard.object(forKey: "birthDate") as? Date {
            self.birthDate = savedDate
        } else {
            self.birthDate = nil
        }
    }

    var needsBirthDate: Bool {
        return birthDate == nil
    }
}
