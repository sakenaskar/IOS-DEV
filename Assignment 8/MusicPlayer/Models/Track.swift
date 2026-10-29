//
//  Track.swift
//  MusicPlayer
//

import Foundation

struct Track {
    let title: String
    let artist: String
    let fileName: String        // без расширения, например "neon_steppe"
    let coverImageName: String  // имя картинки в Assets
    var fileExtension: String = "mp3"
}
