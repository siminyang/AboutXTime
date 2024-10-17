//
//  CreateViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import Foundation

class CreateCapsulesViewModel {

    enum CapsuleType: Int, CaseIterable {
        case selfToSelf = 0
        case selfToOther
        case withFriends

        var title: String {
            switch self {
            case .selfToSelf: return "創建膠囊送給自己"
            case .selfToOther: return "創建膠囊送給對方"
            case .withFriends: return "與多位好友共同創建"
            }
        }
    }

    let capsuleTypes = CapsuleType.allCases
}
