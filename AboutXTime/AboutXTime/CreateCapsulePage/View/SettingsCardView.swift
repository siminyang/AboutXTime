//
//  SettingsCardView.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import SwiftUI

struct SettingsCardView: View {
    @Binding var isAnonymous: Bool
    @Binding var isLocationLocked: Bool
    @Binding var openDate: Date
    @Binding var recipient: String
    @Binding var currentLatitude: Double?
    @Binding var currentLongitude: Double?
    @Binding var currentRadius: Int

    private var userId: String {
        return UserDefaults.standard.string(forKey: "userUID") ?? "defaultUserId"
    }

    var capsuleId: String?
    var isRecipientEditable: Bool {
        recipient.isEmpty || (isLessThan(recipient) && recipient != userId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            if isRecipientEditable {
                Text("收件人ID")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.bottom, 10)
            } else {
                Text("收件人ID")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                    .hidden()
            }

            if isRecipientEditable {
                CustomIdTextField(text: $recipient, placeholder: "請輸入 Recipient ID", isEditable: isRecipientEditable)
                    .frame(height: 40)
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.bottom, 10)
            } else {
                CustomIdTextField(text: $recipient, placeholder: "請輸入 Recipient ID", isEditable: isRecipientEditable)
                    .frame(height: 40)
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                    .hidden()
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                VStack(alignment: .leading) {
                    Text("開啟日期")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .frame(alignment: .leading)

                    Text("-------- 至少需為十分鐘後 --------")
                        .foregroundColor(.white)
                        .font(.caption2)
                        .frame(alignment: .leading)
                        .padding(.top, 4)
                }
            }

            DatePicker(
                "",
                selection: $openDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(CompactDatePickerStyle())
            .background(.white.opacity(0.4))
            .cornerRadius(10)
            .font(.subheadline)
            .foregroundColor(.white)
            .frame(height: 50)
            .tint(STColor.CC1.color)

            HStack {
                Image(systemName: "person.fill.questionmark")
                    .foregroundColor(.white)
                Toggle("匿名寄送", isOn: $isAnonymous)
                    .font(.subheadline)
                    .tint(STColor.CC2.color)
            }
            .padding(.vertical, 5)

            HStack {
                Image(systemName: "location.fill.viewfinder")
                    .foregroundColor(.white)
                Toggle("在指定範圍內開啟", isOn: $isLocationLocked)
                    .padding(.vertical, 5)
                    .tint(STColor.CC2.color)
                    .font(.subheadline)
                    .onChange(of: isLocationLocked) {
                        if isLocationLocked {
                            getCurrentLocation()
                        }
                    }
            }
            Spacer()

            if isLocationLocked {
                let longitude = currentLongitude ?? 0.0
                let longitudeDirection = longitude >= 0 ? "E" : "W"
                let formattedLongitude = String(format: "%.5f", abs(longitude)) + "°" + longitudeDirection

                let latitude = currentLatitude ?? 0.0
                let latitudeDirection = latitude >= 0 ? "N" : "S"
                let formattedLatitude = String(format: "%.5f", abs(latitude)) + "°" + latitudeDirection

                Text("現在地點 [ \(formattedLongitude), \(formattedLatitude) ]")
                    .padding(.vertical, 5)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)

                RangeSelectorView(radius: $currentRadius)
            }

            Spacer()
        }
        .padding()
    }

    private func getCurrentLocation() {
        LocationManager.shared.requestLocation { latitude, longitude in
            self.currentLatitude = latitude
            self.currentLongitude = longitude
        }
    }

    private func validateRecipientInput() {
        if recipient.trimmingCharacters(in: .whitespaces).isEmpty {
            return
        } else if !isLessThan(recipient) {
            recipient = ""
        }
    }

    private func isLessThan(_ recipient: String) -> Bool {
        return recipient.count < 30
    }
}
