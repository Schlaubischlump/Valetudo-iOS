//
//  String + Localization.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation
import MarkdownKit

extension String {
    func localized(comment: String? = nil) -> String {
        NSLocalizedString(self, comment: comment ?? "")
    }

    /* func localized(comment: String? = nil) -> String {
         // capitilize words and preserve all uppercase words
         self.localized(comment: comment).capitalized
         /*    .split(separator: " ")
             .map { word in
                 word.prefix(1).uppercased() + word.dropFirst()
             }
             .joined(separator: " ")*/
     } */

    func localizedUppercase(comment: String? = nil) -> String {
        localized(comment: comment).uppercased()
    }

    func localizedMarkdown(comment: String? = nil) -> NSAttributedString {
        let markdownParser = MarkdownParser()
        return markdownParser.parse(localized(comment: comment))
    }
}
