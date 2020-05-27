//
//  Item.swift
//  Tarkov Market Pal
//
//  Created by Will Chew on 2020-05-26.
//  Copyright © 2020 Will Chew. All rights reserved.
//

import Foundation

struct Item : Codable {
    let name : String
    let uid : String
    let price : Int
    let updated : String
    let imgBig : String
    let currency : String
    let slots : Int
    let diff24h : Double
    let diff7days : Double
    let traderPrice : Int
    let traderName : String
    
    
    enum CodingKeys : String, CodingKey {
        case name
        case uid
        case price
        case updated
        case imgBig
        case currency = "traderPriceCur"
        case slots
        case diff24h
        case diff7days
        case traderPrice
        case traderName
        
    }
}
