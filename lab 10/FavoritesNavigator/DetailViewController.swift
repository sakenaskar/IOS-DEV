import UIKit

final class DetailViewController: UIViewController {

    var item: FavoriteItem?

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var starImageViews: [UIImageView]!   // 5 штук, подключай слева направо
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item else { return }

        navigationItem.title = item.title
        posterImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description

        for (index, starView) in starImageViews.enumerated() {
            starView.image = UIImage(systemName: index < item.rating ? "star.fill" : "star")
        }
    }
}
