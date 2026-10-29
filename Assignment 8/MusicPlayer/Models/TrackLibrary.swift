//
//  TrackLibrary.swift
//  MusicPlayer
//
//  Все треки в одном месте. Файлы лежат в папке Music,
//  обложки в Assets.xcassets
//

import Foundation

enum TrackLibrary {

    static let tracks: [Track] = [
        Track(title: "Billie Jean", artist: "Michael Jackson",
              fileName: "billie_jean", coverImageName: "cover_billie_jean"),
        Track(title: "Bad", artist: "Michael Jackson",
              fileName: "bad", coverImageName: "cover_bad"),
        Track(title: "Smooth Criminal", artist: "Michael Jackson",
              fileName: "smooth_criminal", coverImageName: "cover_smooth_criminal"),
        Track(title: "Stronger", artist: "Kanye West",
              fileName: "stronger", coverImageName: "cover_stronger"),
        Track(title: "Flashing Lights", artist: "Kanye West feat. Dwele",
              fileName: "flashing_lights", coverImageName: "cover_flashing_lights"),
        Track(title: "No Church in the Wild", artist: "Kanye West & Jay-Z feat. Frank Ocean",
              fileName: "no_church_in_the_wild", coverImageName: "cover_no_church_in_the_wild"),
        Track(title: "Chanel", artist: "Frank Ocean",
              fileName: "chanel", coverImageName: "cover_chanel"),
        Track(title: "I Think", artist: "Tyler, The Creator",
              fileName: "i_think", coverImageName: "cover_i_think"),
        Track(title: "Miss the Rage", artist: "Trippie Redd feat. Playboi Carti",
              fileName: "miss_the_rage", coverImageName: "cover_miss_the_rage"),
        Track(title: "Long Time (Intro)", artist: "Playboi Carti",
              fileName: "long_time", coverImageName: "cover_long_time")
    ]
}
