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
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinates(at: (0,0), in: geometry))
                )
                .gesture(doubleTapToZoom(in : geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                }
                else{
                    ForEach(document.emojis){emoji in
                        Text(emoji.text)
                            .gesture(touchEmoji(emoji: emoji)
                                .simultaneously(with: deleteEmoji(emoji: emoji))
                                .simultaneously(with: dragEmojis()))
                            
                            .selectionEffect(for: emoji)
                            .scaleEffect(zoomScale)
                            .font(.system(size: fontSize(for:emoji)))
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText,.url,.image], isTargeted: nil){ providers , location in
                return drop(provider:providers,at: location , in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()).simultaneously(with: touchBackground()))
        }
    }
    var palette : some View {
        emojiScrollingView(emojis:testEmojis)
            .font(.system(size: defaultEmojiSize))
    }
    
    // MARK: - Helper Functions
    private func isSelected()->Bool{
        for emoji in document.emojis{
            if emoji.selected == true {
                return true
            }
        }
        return false
    }
    
    
    private func position(for emoji : EmojiArtModel.Emoji,in geometry : GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates(at:(emoji.x,emoji.y),in:geometry)
    }
    private func convertFromEmojiCoordinates(at location : (x:Int,y:Int), in geometry : GeometryProxy) -> CGPoint{
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x+CGFloat(location.x) * zoomScale + panOffset.width,
                       y: center.y + CGFloat(location.y) * zoomScale + panOffset.height)
    }
    private func fontSize(for emoji : EmojiArtModel.Emoji) -> CGFloat {
        return CGFloat(emoji.size)
    }
    private func drop(provider: [NSItemProvider] , at location: CGPoint , in geometry : GeometryProxy) -> Bool{
        var found = provider.loadObjects(ofType: URL.self){ url in
            document.setBackground(EmojiArtModel.background.url(url.imageURL))
            
        }
        if !found{
            found = provider.loadObjects(ofType: UIImage.self){ image in
                if let data = image.jpegData(compressionQuality: 1.0){
                    document.setBackground(EmojiArtModel.background.imageData(data))
                }
                
            }
        }
        if !found{
            found = provider.loadObjects(ofType: String.self){string in
                if let emoji = string.first , emoji.isEmoji {
                    document.addEmoji(text: String(emoji), at: convertToEmojiCoordinates(at: location, in: geometry), size: Int(defaultEmojiSize) / Int(zoomScale))
                }
            }
        }
        return found
    }
    private func convertToEmojiCoordinates(at location : CGPoint , in geometry : GeometryProxy)->(x:Int,y:Int){
        let center = geometry.frame(in: .local).center
        let coordinates = CGPoint(
            x: (location.x - panOffset.width - center.x)/zoomScale,
            y: (location.y - panOffset.height - center.y)/zoomScale)
        return (Int(coordinates.x),Int(coordinates.y))
    }
 // MARK: - Gestures and helpers
    
    @State private var steadyStatePanOffset:CGSize = CGSize.zero
    @GestureState private var gesturePanOffset : CGSize = CGSize.zero
    
    private var panOffset : CGSize {
        (
            steadyStatePanOffset + gesturePanOffset
        )*zoomScale
    }
    private func panGesture()->some Gesture {
        DragGesture()
            .updating($gesturePanOffset){latestDragGestureValue , gesturePanOffset , transaction in
                
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded{finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
                
            }
    }
    
    @State private var steadyStateZoomScale:CGFloat = 1
    @GestureState private var gestureZoomScale : CGFloat = 1
    
    private var zoomScale : CGFloat {
        steadyStateZoomScale*gestureZoomScale
    }
    
    private func zoomToFit(_ image : UIImage? , in size : CGSize){
        if let image = image , image.size.width > 0 , image.size.height > 0 , size.width > 0 , size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    private func doubleTapToZoom(in size : CGSize) -> some Gesture{
        TapGesture(count:2)
            .onEnded{
                withAnimation{
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale){
                latestGestureScale,gestureZoomScale,transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded{
                gestureScaleAtEnd in
                if isSelected()==false{
                    steadyStateZoomScale *= gestureScaleAtEnd
                }
                else{
                    for emoji in document.emojis{
                        if emoji.selected == true {
                            document.scaleEmoji(emoji: emoji, by: gestureScaleAtEnd)
                        }
                    }
                }
            }
    }
    
    // MARK: - selection and deselection of Emojis
    
    
    private func touchEmoji(emoji : EmojiArtModel.Emoji) -> some Gesture{
        TapGesture(count: 1)
            .onEnded{
                withAnimation{
                    document.touchEmoji(emoji: emoji)
                }
            }
    }
    private func touchBackground() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                withAnimation{
                    document.touchBackground()
                }
            }
        
    }
    
    
    //MARK: - Dragging of Emojis
    
    
    @GestureState private var dragEmojiOffset:CGSize = CGSize.zero
    private func dragEmojis() -> some Gesture {
        DragGesture()
            .updating($dragEmojiOffset){
                latestGestureValue , dragEmojiOffset , transaction in
                dragEmojiOffset = latestGestureValue.distance/zoomScale
                
            }
            .onChanged{
                value in
                for emoji in document.emojis {
                    if emoji.selected == true {
                        document.moveEmoji(emoji: emoji , by : value.distance / zoomScale)
                    }
                }

                
            }
            .onEnded{
                finalGestureValue in
                for emoji in document.emojis {
                    if emoji.selected == true {
                        document.moveEmoji(emoji: emoji , by : finalGestureValue.distance / zoomScale)
                    }
                }
            }
        
    }
    
    
    //MARK: - Deletion of Emojis
    
    private func deleteEmoji(emoji : EmojiArtModel.Emoji) -> some Gesture {
        TapGesture(count: 2)
            .onEnded{
                withAnimation(Animation.linear(duration: 4.0)){
                    document.deleteEmoji(emoji: emoji)
                }
            }
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


extension DragGesture.Value {
    var distance: CGSize{
        location-startLocation
    }
}
