//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Sanjay Siddharth on 27/12/22.
//

import Foundation


struct EmojiArtModel {
    var background = background.blank
    var emojis = [Emoji]()
    
    struct Emoji : Identifiable,Hashable{
        let id : Int
        let text : String
        var x : Int
        var y : Int
        var size : Int
        
        init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    init(){}
    private var uniqueEmojiId = 0
    
    
    
    mutating func addEmoji(_ text : String , at location : (x:Int,y:Int),size : Int){
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, x: location.x, y: location.y, size: size))
    }
    
}
