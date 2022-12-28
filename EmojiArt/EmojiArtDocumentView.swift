//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Sanjay Siddharth on 27/12/22.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    private(set) var testEmojis = "🌻🌼🌸🌺🌹🌷💐🍄🍁🪴🍀🌿🌳🎄🌵🌲🌴🐿️"
    let defaultEmojiSize : CGFloat = 40
    @ObservedObject var document : EmojiArtDocument
    var body: some View {
        VStack(spacing: 0){
            background
            palette
        }
    }
    var background : some View {
        GeometryReader{ geometry in
            ZStack{
                Color.yellow
                ForEach(document.emojis){emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for:emoji)))
                        .position(position(for: emoji, in: geometry))
                }
            }.onDrop(of: [.plainText], isTargeted: nil){ providers , location in
                return drop(provider:providers,at: location , in: geometry)
            }
        }
    }
    var palette : some View {
        emojiScrollingView(emojis:testEmojis)
            .font(.system(size: defaultEmojiSize))
    }
    
    // MARK: - Helper Functions
    private func position(for emoji : EmojiArtModel.Emoji,in geometry : GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates(at:(emoji.x,emoji.y),in:geometry)
    }
    private func convertFromEmojiCoordinates(at location : (x:Int,y:Int), in geometry : GeometryProxy) -> CGPoint{
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x+CGFloat(location.x), y: center.y + CGFloat(location.y))
    }
    private func fontSize(for emoji : EmojiArtModel.Emoji) -> CGFloat {
        return CGFloat(emoji.size)
    }
    private func drop(provider: [NSItemProvider] , at location: CGPoint , in geometry : GeometryProxy) -> Bool{
        return provider.loadObjects(ofType: String.self){string in
            if let emoji = string.first , emoji.isEmoji {
                document.addEmoji(text: String(emoji), at: convertToEmojiCoordinates(at: location, in: geometry), size: Int(defaultEmojiSize))
            }
        }
    }
    private func convertToEmojiCoordinates(at location : CGPoint , in geometry : GeometryProxy)->(x:Int,y:Int){
        let center = geometry.frame(in: .local).center
        let coordinates = CGPoint(
            x: location.x - center.x,
            y: location.y - center.y)
        return (Int(coordinates.x),Int(coordinates.y))
    }
    
}
// MARK: - Palette's Emoji Scrolling View
struct emojiScrollingView : View{
    let emojis : String
    var body : some View {
        ScrollView(.horizontal){
            HStack{
                ForEach(emojis.map{String($0)},id: \.self){emoji in
                    Text(emoji)
                        .onDrag{NSItemProvider(object: emoji as NSString)}
                }
            }
        }
    }
    
}

// MARK: - Preview:
struct ContentView_Previews: PreviewProvider {
    let document = EmojiArtDocument()
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
