//
//  String + Localization.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

extension String {
    func localized(comment: String? = nil) -> String {
        NSLocalizedString(self, comment: comment ?? "")
    }
}
