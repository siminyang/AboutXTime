//
//  PendingCapsulesViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/11/12.
//

import Foundation
import Combine

class PendingCapsulesViewModel {
    @Published var capsules: [Capsule] = []
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    func fetchCapsules() {

        guard let userId = UserDefaults.standard.string(forKey: "userUID") else {
            print("Failed to get UID from UserDefaults.")
            return
        }

        FirebaseManager.shared.fetchUserCapsules(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let capsules):
                    self?.capsules = capsules
                    print(">>>>>>> Fetched capsules: \(capsules)")
                case .failure(let error):
                    self?.errorMessage = "Error fetching capsules: \(error.localizedDescription)"
                }
            }
        }
    }
}
