//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Sanjay Siddharth on 28/12/22.
//

import SwiftUI

class EmojiArtDocument : ObservableObject {
    
    @Published private(set) var emojiArt : EmojiArtModel
    private(set) var testEmojis = "🌻🌼🌸🌺🌹🌷💐🍄🍁🪴🍀🌿🌳🎄🌵🌲🌴🐿️"
    
    init(){
        emojiArt = EmojiArtModel()
    }
    var emojis  : [EmojiArtModel.Emoji] {
         return emojiArt.emojis
    }
    var background : EmojiArtModel.background {
        return emojiArt.background
    }
    
    
    
    // MARK: - User Intents
    
    func setBackground(_ background : EmojiArtModel.background){
        emojiArt.background = background
    }
    
    func addEmoji(text : String , at location : (x:Int , y:Int) , size : Int){
        emojiArt.addEmoji(text, at: location, size: size)
    }
    
    
    
    
    
    
}
