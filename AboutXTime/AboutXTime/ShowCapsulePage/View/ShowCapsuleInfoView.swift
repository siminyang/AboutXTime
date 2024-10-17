//
//  ShowCapsuleInfoView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/17.
//

import Foundation
import SwiftUI

struct ShowCapsuleInfoView: View {
    let capsule: Capsule
    let userId: String
    let fromWhom: String
    let toWhom: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("From")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer(minLength: 8)

                if capsule.isAnonymous {
                    Text("Anonymous")
                    .foregroundColor(.white)

                } else {
                    Text(fromWhom)
                        .foregroundColor(.white)
                }

                Text("\(formatToMinute(date: capsule.createdDate))")
                    .foregroundColor(.white)

                Spacer(minLength: 16)

                if capsule.isLocationLocked {
                    let longitude = capsule.location?.longitude ?? 0.0
                    let latitude = capsule.location?.latitude ?? 0.0

                    let longitudeDirection = longitude >= 0 ? "E" : "W"
                    let roundedLongitude = String(format: "%.1f", abs(longitude)) + "°" + longitudeDirection

                    let latitudeDirection = latitude >= 0 ? "N" : "S"
                    let roundedLatitude = String(format: "%.1f", abs(latitude)) + "°" + latitudeDirection

                    Text("[\(roundedLongitude), \(roundedLatitude)]")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .leading) {
                Text("To")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer(minLength: 8)

                Text(toWhom)
                    .foregroundColor(.white)
                Text("\(formatToMinute(date: capsule.openDate))")
                    .foregroundColor(.white)

                Spacer(minLength: 16)

                if capsule.isLocationLocked {
                    let longitude = capsule.location?.longitude ?? 0.0
                    let latitude = capsule.location?.latitude ?? 0.0

                    let longitudeDirection = longitude >= 0 ? "E" : "W"
                    let roundedLongitude = String(format: "%.1f", abs(longitude)) + "°" + longitudeDirection

                    let latitudeDirection = latitude >= 0 ? "N" : "S"
                    let roundedLatitude = String(format: "%.1f", abs(latitude)) + "°" + latitudeDirection

                    Text("[\(roundedLongitude), \(roundedLatitude)]")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

func formatToMinute(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
}
