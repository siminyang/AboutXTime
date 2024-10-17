//
//  FormatDateManager.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/10/10.
//

import Foundation

func formatDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}
