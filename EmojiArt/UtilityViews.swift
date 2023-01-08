//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by Sanjay Siddharth on 03/01/23.
//

import SwiftUI

struct OptionalImage : View {
    var uiImage : UIImage?
    var body: some View{
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    }
}
