//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Sanjay Siddharth on 28/12/22.
//

import SwiftUI

class EmojiArtDocument : ObservableObject {
    
    @Published private(set) var emojiArt : EmojiArtModel {
        didSet{
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }

    }
    
    
    
    init(){
        emojiArt = EmojiArtModel()
        addEmoji(text: "🌺", at: (-200,-50), size: 80)
        addEmoji(text: "🐸", at: (100,150), size: 100)
    }
    var emojis  : [EmojiArtModel.Emoji] {
         return emojiArt.emojis
    }
    var background : EmojiArtModel.background {
        return emojiArt.background
    }
    @Published var backgroundImage : UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    private func fetchBackgroundImageDataIfNecessary(){
        
        backgroundImage = nil //  set existing background to nil cos we know its gonna change
        switch emojiArt.background{
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async{ [weak self] in
                    if self?.background == EmojiArtModel.background.url(url)
                    {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
            
        }
        
    }
    
    var selectedEmojis = Set<EmojiArtModel.Emoji>()
    
    
    // MARK: - User Intents
    
    func setBackground(_ background : EmojiArtModel.background){
        emojiArt.background = background
    }
    
    func addEmoji(text : String , at location : (x:Int , y:Int) , size : Int){
        emojiArt.addEmoji(text, at: location, size: size)
    }
    
    func touchEmoji(emoji: EmojiArtModel.Emoji){
        emojiArt.touchEmoji(emoji: emoji)
    }
    
    func touchBackground(){
        emojiArt.touchBackground()
    }
    func moveEmoji(emoji : EmojiArtModel.Emoji , by : CGSize){
        if let index = emojiArt.emojis.firstIndex(where: {$0.id == emoji.id}){
            emojiArt.emojis[index].x += Int(by.width)
            emojiArt.emojis[index].y += Int(by.height)

        }
    }
    func scaleEmoji(emoji : EmojiArtModel.Emoji , by scale : CGFloat){
        if let index = emojiArt.emojis.firstIndex(where: {$0.id == emoji.id}){
            emojiArt.emojis[index].size = Int(CGFloat(emojiArt.emojis[index].size)*scale)
        }
    }
    func deleteEmoji(emoji:EmojiArtModel.Emoji){
        emojiArt.deleteEmoji(emoji: emoji)
    }
    
    
    
    
}
