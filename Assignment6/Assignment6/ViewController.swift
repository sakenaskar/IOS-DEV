import UIKit

struct Favorite {
    let imageName: String
    let title: String
    let description: String
}

class ViewController: UIViewController {

    // MARK: - Interface

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardStackView = UIStackView()

    private let favoriteImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let randomButton = UIButton(type: .system)

    private var imageAspectConstraint: NSLayoutConstraint?
    private var lastIndex: Int?

    // MARK: - Data

    private let favorites: [Favorite] = [
        Favorite(
            imageName: "intouchables",
            title: "1+1",
            description: "Необычная дружба двух совершенно разных людей меняет их жизни и помогает взглянуть на мир по-новому."
        ),
        Favorite(
            imageName: "spiderMan",
            title: "Человек-паук",
            description: "Питер Паркер получает необычные способности и учится использовать их, чтобы защищать людей."
        ),
        Favorite(
            imageName: "ironMan",
            title: "Железный человек",
            description: "Тони Старк создаёт высокотехнологичный костюм и решает использовать свои изобретения для защиты людей."
        ),
        Favorite(
            imageName: "avatar",
            title: "Аватар",
            description: "Джейк Салли отправляется на Пандору и оказывается перед выбором между приказом и защитой нового мира."
        ),
        Favorite(
            imageName: "interstellar",
            title: "Интерстеллар",
            description: "Команда исследователей отправляется сквозь космос, чтобы найти новый дом для человечества."
        ),
        Favorite(
            imageName: "cars",
            title: "Тачки",
            description: "Молния Маккуин попадает в маленький город и узнаёт, что дружба бывает важнее победы в гонке."
        ),
        Favorite(
            imageName: "harryPotter",
            title: "Гарри Поттер",
            description: "Первая часть: «Философский камень». Гарри узнаёт, что он волшебник, и начинает учиться в Хогвартсе."
        ),
        Favorite(
            imageName: "fightClub",
            title: "Бойцовский клуб",
            description: "Офисный работник знакомится с Тайлером Дёрденом и создаёт подпольный бойцовский клуб."
        ),
        Favorite(
            imageName: "americanPsycho",
            title: "Американский психопат",
            description: "За внешне идеальной жизнью финансиста Патрика Бэйтмана скрываются жестокость и мрачные тайны."
        ),
        Favorite(
            imageName: "django",
            title: "Джанго освобождённый",
            description: "Джанго обретает свободу и вместе с охотником за головами отправляется спасать свою жену."
        )
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        setupLayout()
        updateCard(at: 0)
    }

    // MARK: - Appearance

    private func setupAppearance() {
        view.backgroundColor = UIColor(
            red: 0.07,
            green: 0.07,
            blue: 0.10,
            alpha: 1
        )

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false

        cardStackView.axis = .vertical
        cardStackView.alignment = .center
        cardStackView.distribution = .fill
        cardStackView.spacing = 0

        favoriteImageView.contentMode = .scaleAspectFit
        favoriteImageView.backgroundColor = .clear
        favoriteImageView.isAccessibilityElement = true

        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFontMetrics(forTextStyle: .title1)
            .scaledFont(
                for: UIFont.systemFont(
                    ofSize: 30,
                    weight: .bold
                )
            )
        titleLabel.adjustsFontForContentSizeCategory = true

        descriptionLabel.textColor = UIColor.white
            .withAlphaComponent(0.75)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(
                for: UIFont.systemFont(
                    ofSize: 17,
                    weight: .regular
                )
            )
        descriptionLabel.adjustsFontForContentSizeCategory = true

        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.title = "Случайный фильм"
        buttonConfiguration.image = UIImage(systemName: "shuffle")
        buttonConfiguration.imagePadding = 10
        buttonConfiguration.baseBackgroundColor = UIColor(
            red: 0.24,
            green: 0.44,
            blue: 1,
            alpha: 1
        )
        buttonConfiguration.baseForegroundColor = .white
        buttonConfiguration.cornerStyle = .fixed
        buttonConfiguration.background.cornerRadius = 16
        buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 24,
            bottom: 16,
            trailing: 24
        )
        buttonConfiguration.titleTextAttributesTransformer =
            UIConfigurationTextAttributesTransformer { attributes in
                var result = attributes
                result.font = UIFont.systemFont(
                    ofSize: 17,
                    weight: .semibold
                )
                return result
            }

        randomButton.configuration = buttonConfiguration
        randomButton.addTarget(
            self,
            action: #selector(randomButtonTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardStackView)

        [
            favoriteImageView,
            titleLabel,
            descriptionLabel,
            randomButton
        ].forEach {
            cardStackView.addArrangedSubview($0)
        }

        [
            scrollView,
            contentView,
            cardStackView,
            favoriteImageView,
            titleLabel,
            descriptionLabel,
            randomButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        cardStackView.setCustomSpacing(
            20,
            after: favoriteImageView
        )
        cardStackView.setCustomSpacing(
            12,
            after: titleLabel
        )
        cardStackView.setCustomSpacing(
            32,
            after: descriptionLabel
        )

        // Заполняем доступную ширину, но не превышаем 680 pt.
        let preferredCardWidth = cardStackView.widthAnchor
            .constraint(
                equalTo: contentView.widthAnchor,
                constant: -48
            )
        preferredCardWidth.priority = .defaultHigh

        // Центрируем карточку, если она помещается на экране.
        let preferredCenterY = cardStackView.centerYAnchor
            .constraint(equalTo: contentView.centerYAnchor)
        preferredCenterY.priority = .defaultLow

        // Описание не растягиваем слишком широко на iPad.
        let preferredDescriptionWidth = descriptionLabel.widthAnchor
            .constraint(equalTo: cardStackView.widthAnchor)
        preferredDescriptionWidth.priority = .defaultHigh

        // Компактная кнопка с максимальной шириной 360 pt.
        let preferredButtonWidth = randomButton.widthAnchor
            .constraint(equalToConstant: 360)
        preferredButtonWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),

            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),
            contentView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            contentView.heightAnchor.constraint(
                greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor
            ),

            cardStackView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),
            cardStackView.topAnchor.constraint(
                greaterThanOrEqualTo: contentView.topAnchor,
                constant: 32
            ),
            cardStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -32
            ),
            cardStackView.widthAnchor.constraint(
                lessThanOrEqualToConstant: 680
            ),
            cardStackView.widthAnchor.constraint(
                lessThanOrEqualTo: contentView.widthAnchor,
                constant: -48
            ),
            preferredCardWidth,
            preferredCenterY,

            favoriteImageView.widthAnchor.constraint(
                equalTo: cardStackView.widthAnchor
            ),
            favoriteImageView.heightAnchor.constraint(
                lessThanOrEqualToConstant: 440
            ),

            titleLabel.widthAnchor.constraint(
                equalTo: cardStackView.widthAnchor
            ),

            descriptionLabel.widthAnchor.constraint(
                lessThanOrEqualTo: cardStackView.widthAnchor
            ),
            descriptionLabel.widthAnchor.constraint(
                lessThanOrEqualToConstant: 600
            ),
            preferredDescriptionWidth,

            randomButton.widthAnchor.constraint(
                lessThanOrEqualTo: cardStackView.widthAnchor
            ),
            randomButton.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 56
            ),
            preferredButtonWidth
        ])
    }

    // MARK: - Actions

    @objc private func randomButtonTapped() {
        let availableIndices = favorites.indices.filter {
            $0 != lastIndex
        }

        guard let index = availableIndices.randomElement()
            ?? favorites.indices.first else {
            return
        }

        updateCard(at: index)
    }

    // MARK: - Content

    private func updateCard(at index: Int) {
        guard favorites.indices.contains(index) else {
            return
        }

        let favorite = favorites[index]
        let image = UIImage(named: favorite.imageName)

        favoriteImageView.image = image
        favoriteImageView.accessibilityLabel = favorite.title
        titleLabel.text = favorite.title
        descriptionLabel.text = favorite.description

        updateImageAspectRatio(for: image)

        lastIndex = index
    }

    private func updateImageAspectRatio(for image: UIImage?) {
        imageAspectConstraint?.isActive = false

        let ratio: CGFloat

        if let image,
           image.size.width > 0,
           image.size.height > 0 {
            ratio = image.size.height / image.size.width
        } else {
            ratio = 9.0 / 16.0
        }

        let constraint = favoriteImageView.heightAnchor.constraint(
            equalTo: favoriteImageView.widthAnchor,
            multiplier: ratio
        )

        // Для высоких постеров сохраняем ограничение высоты.
        // Aspect Fit при этом продолжает показывать картинку целиком.
        constraint.priority = .defaultHigh
        constraint.isActive = true

        imageAspectConstraint = constraint
    }
}
