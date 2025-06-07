//
//  VTSize.swift
//  Valetudo
//
//  Created by David Klopp on 17.05.25.
//
import Foundation

public struct VTSize: Decodable {
    public let x: Int
    public let y: Int
}

extension VTSize: Equatable {}
