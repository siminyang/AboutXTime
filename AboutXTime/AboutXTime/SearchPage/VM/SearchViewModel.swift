//
//  SearchViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/19.
//

import Foundation
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filteredCapsules: [Int: [Capsule]] = [:]
    @Published var isSearching = false
    private var allCapsules: [Capsule]
    private var userBirthDate: Date

    init(capsules: [Capsule], userBirthDate: Date) {
        self.allCapsules = capsules
        self.userBirthDate = userBirthDate
        self.filteredCapsules = groupCapsulesByAge(capsules: capsules)
    }

    private func groupCapsulesByAge(capsules: [Capsule]) -> [Int: [Capsule]] {
        let calendar = Calendar.current
        let filteredCapsules = capsules.filter { capsule in
            capsule.recipients.contains { $0.status == 1 }
        }

        return Dictionary(grouping: filteredCapsules) { capsule in
            let ageAtOpen = calendar.dateComponents([.year], from: userBirthDate, to: capsule.openDate).year ?? 0
            return ageAtOpen
        }
    }

    func searchCapsules() {
        isSearching = true

        DispatchQueue.global().async {
            sleep(1)

            DispatchQueue.main.async {
                if self.searchText.isEmpty {
                    self.filteredCapsules = self.groupCapsulesByAge(capsules: self.allCapsules)
                } else {
                    var imageTag: Int?
                    if let mappedTag = labelMappingAllCases[self.searchText.lowercased()] {
                        imageTag = mappedTag
                    }

                    let filtered = self.allCapsules.filter { capsule in
                        capsule.creatorId.localizedCaseInsensitiveContains(self.searchText) ||
                        capsule.content.contains { content in
                            content.text.localizedCaseInsensitiveContains(self.searchText)
                        } ||
                        (capsule.emotionTagLabels?.contains { label in
                            label.localizedCaseInsensitiveContains(self.searchText)
                        } ?? false) ||
                        (imageTag != nil && capsule.imageTagLabels?.contains { label in
                            label == imageTag
                        } ?? false) ||
                        capsule.replyMessages?.contains { message in
                            message.text.localizedCaseInsensitiveContains(self.searchText)
                        } ?? false
                    }

                    self.filteredCapsules = self.groupCapsulesByAge(capsules: filtered)
                }
                self.isSearching = false
            }
        }
    }
}
