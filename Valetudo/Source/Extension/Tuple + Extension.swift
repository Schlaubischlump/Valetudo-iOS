//
//  Any + Extension.swift
//  Valetudo
//
//  Created by David Klopp on 18.09.25.
//

// allow nicer Scala-like tuple notation
infix operator => : AdditionPrecedence

func => <K, V>(key: K, value: V) -> (K, V) {
    return (key, value)
}
