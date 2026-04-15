//
//  Int + Operators.swift
//  Valetudo
//
//  Created by David Klopp on 15.04.26.
//

prefix operator ++

prefix func ++ (value: inout Int) -> Int {
    value += 1
    return value
}

postfix operator ++

postfix func ++ (value: inout Int) -> Int {
    let oldValue = value
    value += 1
    return oldValue
}
