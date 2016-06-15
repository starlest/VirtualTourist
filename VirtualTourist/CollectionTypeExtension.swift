//
//  CollectionTypeExtension.swift
//  VirtualTourist
//
//  Created by Edwin Chia on 15/6/16.
//  Copyright © 2016 Edwin Chia. All rights reserved.
//

extension CollectionType {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}