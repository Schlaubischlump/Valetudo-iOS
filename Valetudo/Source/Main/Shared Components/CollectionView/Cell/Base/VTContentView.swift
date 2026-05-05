//
//  VTContentView.swift
//  Valetudo
//
//  Created by David Klopp on 03.05.26.
//

import UIKit

@MainActor
protocol VTContentView: UIContentView {
    associatedtype Configuration: UIContentConfiguration

    var currentConfiguration: Configuration! { get }

    init(configuration: Configuration)

    func setupViews()

    func apply(configuration: Configuration)
}
