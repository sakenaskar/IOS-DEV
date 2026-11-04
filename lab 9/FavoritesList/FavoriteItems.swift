import Foundation

/// Все данные списка лежат в одном месте.
enum FavoriteItems {
    static let all: [FavoriteItem] = [
        FavoriteItem(title: "Counter-Strike 2", subtitle: "Tactical shooter · Valve · 2023", imageName: "cs2", rating: 5),
        FavoriteItem(title: "Need for Speed: Most Wanted", subtitle: "Racing · EA Black Box · 2005", imageName: "nfs", rating: 5),
        FavoriteItem(title: "The Legend of Zelda: Breath of the Wild", subtitle: "Action-adventure · Nintendo · 2017", imageName: "zelda", rating: 5),
        FavoriteItem(title: "Dota 2", subtitle: "MOBA · Valve · 2013", imageName: "dota2", rating: 4),
        FavoriteItem(title: "Rust", subtitle: "Survival · Facepunch Studios · 2018", imageName: "rust", rating: 4),
        FavoriteItem(title: "Assassin's Creed II", subtitle: "Action-adventure · Ubisoft Montreal · 2009", imageName: "ac", rating: 5),
        FavoriteItem(title: "Minecraft", subtitle: "Sandbox · Mojang · 2011", imageName: "minecraft", rating: 5),
        FavoriteItem(title: "Grand Theft Auto V", subtitle: "Open world · Rockstar North · 2013", imageName: "gta", rating: 5),
        FavoriteItem(title: "Far Cry 3", subtitle: "Open-world shooter · Ubisoft Montreal · 2012", imageName: "farcry", rating: 4),
        FavoriteItem(title: "The Witcher 3: Wild Hunt", subtitle: "RPG · CD Projekt Red · 2015", imageName: "witcher3", rating: 5),
        FavoriteItem(title: "Red Dead Redemption 2", subtitle: "Western open world · Rockstar Games · 2018", imageName: "rdr2", rating: 5),
        FavoriteItem(title: "Cyberpunk 2077", subtitle: "RPG · CD Projekt Red · 2020", imageName: "cyberpunk", rating: 4),
        FavoriteItem(title: "Elden Ring", subtitle: "Action RPG · FromSoftware · 2022", imageName: "eldenring", rating: 5),
        FavoriteItem(title: "God of War", subtitle: "Action-adventure · Santa Monica Studio · 2018", imageName: "godofwar", rating: 5),
        FavoriteItem(title: "Hollow Knight", subtitle: "Metroidvania · Team Cherry · 2017", imageName: "hollowknight", rating: 4),
        FavoriteItem(title: "Portal 2", subtitle: "Puzzle · Valve · 2011", imageName: "portal2", rating: 5),
        FavoriteItem(title: "Half-Life 2", subtitle: "Shooter · Valve · 2004", imageName: "halflife2", rating: 5),
        FavoriteItem(title: "The Elder Scrolls V: Skyrim", subtitle: "RPG · Bethesda · 2011", imageName: "skyrim", rating: 4),
        FavoriteItem(title: "Stardew Valley", subtitle: "Farming sim · ConcernedApe · 2016", imageName: "stardew", rating: 4),
        FavoriteItem(title: "Terraria", subtitle: "Sandbox · Re-Logic · 2011", imageName: "terraria", rating: 3),
        FavoriteItem(title: "Hades", subtitle: "Roguelike · Supergiant Games · 2020", imageName: "hades", rating: 5),
        FavoriteItem(title: "The Last of Us Part II", subtitle: "Action-adventure · Naughty Dog · 2020", imageName: "tlou", rating: 4),
    ]
}
