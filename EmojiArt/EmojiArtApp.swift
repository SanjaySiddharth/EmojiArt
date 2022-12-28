//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Sanjay Siddharth on 27/12/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
