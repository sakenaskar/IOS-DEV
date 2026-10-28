//
//  ViewController.swift
//  Assignment7
//
//  Variant A - Profile
//  Вся верстка и констрейнты в Main.storyboard, тут только данные
//

import UIKit

struct Profile {
    let name: String
    let subtitle: String
    let posts: Int
    let followers: Int
    let following: Int
    let about: String

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? (parts.last?.first.map(String.init) ?? "") : ""
        return (first + last).uppercased()
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!

    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var aboutLabel: UILabel!

    var isFollowing = false

    let profile = Profile(
        //name: "Aigerim Bekova",
        name: "Maximilian Alexander von Habsburg",   // long text test
        subtitle: "iOS Developer · Almaty",
        posts: 128,
        followers: 4200,
        following: 312,
        about: "Building banking apps in Swift. I like clean architecture, coffee and long walks in the mountains around Almaty."
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        fillData()
    }

    func fillData() {
        avatarLabel.text = profile.initials
        nameLabel.text = profile.name
        subtitleLabel.text = profile.subtitle

        postsCountLabel.text = shortNumber(profile.posts)
        followersCountLabel.text = shortNumber(profile.followers)
        followingCountLabel.text = shortNumber(profile.following)

        aboutLabel.text = profile.about
    }

    // 4200 -> 4.2K
    func shortNumber(_ n: Int) -> String {
        if n >= 1_000_000 {
            return String(format: "%.1fM", Double(n) / 1_000_000)
        } else if n >= 1000 {
            return String(format: "%.1fK", Double(n) / 1000)
        }
        return "\(n)"
    }

    @IBAction func followTapped(_ sender: UIButton) {
        isFollowing.toggle()
        followButton.setTitle(isFollowing ? "Following" : "Follow", for: .normal)
    }

    @IBAction func messageTapped(_ sender: UIButton) {
        print("message tapped")
    }
}
