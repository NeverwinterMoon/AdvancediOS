import RxSwift
import RxCocoa
import RxExtensions
import Core

class SettingsNavigationModel: TabBarChildViewModel, SettingsPresentingViewModel {

    let isActive = BehaviorRelay<Bool>(value: false)

    let tabBarItemTitle = Property(L10n.SettingsNavigation.TabBarItem.title)

    private(set) lazy var presentSettings = makePresentSettings(withFactory: settingsFactory)

    weak var settingsPresenter: SettingsPresenter?

    init(settingsFactory: SettingsViewModelFactoryProtocol) {
        self.settingsFactory = settingsFactory
    }

    private let settingsFactory: SettingsViewModelFactoryProtocol

}

protocol SettingsNavigationModelFactoryProtocol: SettingsViewModelFactoryProtocol {
    func makeSettingsNavigationModel() -> SettingsNavigationModel
}

extension SettingsNavigationModelFactoryProtocol {

    func makeSettingsNavigationModel() -> SettingsNavigationModel {
        return SettingsNavigationModel(settingsFactory: self)
    }

}

class SettingsNavigationModelFactory: SettingsNavigationModelFactoryProtocol {
    let themeProvider: ThemeProvider

    init(themeProvider: ThemeProvider) {
        self.themeProvider = themeProvider
    }
}
