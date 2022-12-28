//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Sanjay Siddharth on 27/12/22.
//

import Foundation

extension EmojiArtModel {
    enum background {
        case blank
        case url(URL)
        case imageData(Data)
    }
}
