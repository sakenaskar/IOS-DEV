import UIKit

class FavoriteCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    // 5 звёзд, подключены слева направо
    @IBOutlet var starImageViews: [UIImageView]!

    /// Полностью перезаполняет ячейку из одного элемента
    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        for (index, starView) in starImageViews.enumerated() {
            let symbol = index < item.rating ? "star.fill" : "star"
            starView.image = UIImage(systemName: symbol)
        }
    }
}
