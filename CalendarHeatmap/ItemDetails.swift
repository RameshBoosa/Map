//
//  ItemDetails.swift
//  CalendarHeatmap_Example
//
//  Created by Venkateswara Rao Meda on 22/05/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

// MARK: - ItemDetails
struct ItemDetails: Codable, Hashable {
    let items: [Item]?
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Item
struct Item: Codable, Hashable {
    let start, end: End?
    let eventType: String?
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - End
struct End: Codable, Hashable {
    let dateTime: String?
    let timeZone: String?
}
