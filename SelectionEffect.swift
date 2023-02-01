//
//  SelectionEffect.swift
//  EmojiArt
//
//  Created by Sanjay Siddharth on 09/01/23.
//

import SwiftUI

struct SelectionEffect : ViewModifier {
    var emoji : EmojiArtModel.Emoji
    func body(content: Content) -> some View {
        content
            .overlay(
                emoji.selected ? RoundedRectangle(cornerRadius: 0).strokeBorder(lineWidth: 2).foregroundColor(Color.blue) : nil
            )
    }
}

extension View {
    func selectionEffect(for emoji : EmojiArtModel.Emoji) -> some View {
        modifier(SelectionEffect(emoji: emoji))
    }
}
