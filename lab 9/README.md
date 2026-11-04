# Favorites List — UITableView & Custom Cells

UIKit-приложение: список любимых игр (22 шт.) в `UITableView` с кастомной ячейкой
(картинка, название, подзаголовок, рейтинг звёздами из SF Symbols).

## Структура
- `FavoriteItem.swift` — struct модели
- `FavoriteItems.swift` — массив данных (в одном месте)
- `FavoriteCell.swift` — подкласс `UITableViewCell` (только outlets + `configure(with:)`)
- `ViewController.swift` — `UITableViewDataSource`
- `Main.storyboard` — весь Auto Layout (таблица на Safe Area + prototype cell)

## Скриншоты
| iPhone SE (3rd gen) | iPhone 16 Pro Max |
|---|---|
| ![SE](screenshots/se.png) | ![Pro Max](screenshots/promax.png) |

## Запуск
Открыть `FavoritesList.xcodeproj` в Xcode 16+, выбрать симулятор, нажать Run.
