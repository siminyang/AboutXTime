//
//  OpenedCapsulesViewModel.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/18.
//

import SwiftUI
import NVActivityIndicatorView
import Firebase

class OpenedCapsulesViewModel: ObservableObject {
    @Published var birthDate: Date? {
        didSet {
            if let date = birthDate {
                UserDefaults.standard.set(date, forKey: "birthDate")
            }
        }
    }

    @Published var capsules: [Capsule] = []
    @Published var isLoading: Bool = false

    var needsBirthDate: Bool {
        return birthDate == nil
    }
    private var listener: ListenerRegistration?
    var onCapsulesUpdated: (([Capsule]) -> Void)?

    init() {
        if let savedDate = UserDefaults.standard.object(forKey: "birthDate") as? Date {
            self.birthDate = savedDate
        } else {
            self.birthDate = nil
        }
    }

    func fetchCapsulesInBackground() {
        guard !isLoading else { return }
        isLoading = true

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let userId = UserDefaults.standard.string(forKey: "userUID") else {
                print("Failed to get UID from UserDefaults.")
                return
            }

            self?.listener = FirebaseManager.shared.fetchUserCapsules(userId: userId) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    switch result {
                    case .success(let capsules):
                        self?.capsules = capsules
                        print(">>>>>>> Fetched opened capsules: \(capsules)")
                        self?.onCapsulesUpdated?(capsules)

                    case .failure(let error):
                        print("Error fetching capsules: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
