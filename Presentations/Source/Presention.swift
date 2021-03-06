import UIKit
import RxSwift
import RxCocoa
import Action
import RxExtensions

public protocol Presentation: class {
    typealias MakePresent = (_ presentedViewController: UIViewController, _ animated: Bool) -> Completable
    var viewController: UIViewController { get }
    var present: CompletableAction<Bool> { get }
}

/// A dismissible presentation (e.g. navigation push, modal presentation, etc.).
///
/// Presentation are single use. After the present command has been executed, a new presentation will need to be created
/// to start a another presentation.
public class DismissablePresentation: Presentation {
    public typealias MakeDismiss = (_ presentedViewController: UIViewController, _ animated: Bool) -> Completable

    public let viewController: UIViewController

    /// The action that begins executing the producer returned from the present producer (provided by the MakePresent
    /// closure at initialization time). The action's execution signal completes when the signal producer's signal
    /// completes.
    ///
    /// This action is only enabled when the view controller has not yet been presented.
    public let present: CompletableAction<Bool>

    /// The action that begins executing the producer returned from the dismiss producer (provided by the MakeDismiss
    /// closure at initialization time). The action's execution signal completes when the signal producer's signal
    /// completes.
    ///
    /// This action is only enabled after presentation completes.
    public let dismiss: CompletableAction<Bool>

    /// Sends () and then completes when the view controller dismisses (either through the the dismiss action or a value
    /// is sent along the didDismiss signal provided at initialization).
    ///
    /// This action will be disabled while the
    public let didDismiss: Observable<()>

    /// - Parameter viewController: The view controller being presented.
    /// - Parameter present: A closure that returns a signal producer that will be created and started when the present
    ///             action is executed. This signal producer should present the associated view controller.
    /// - Parameter dismiss: A closure that returns a signal producer that will be created and started when the dismiss
    ///             action is executed. This signal producer should dismiss the associated view controller.
    /// - Parameter didDismiss: Should send a value and then complete when the view controller did dismiss. In the case
    ///             of a view controller being presented in a navigation controller, this may be a signal that sends ()
    ///             when the view controller's parent becomes nil.
    public init(presentedViewController viewController: UIViewController, present: @escaping MakePresent, dismiss: @escaping MakeDismiss, didDismiss: Observable<()>) {
        self.viewController = viewController

        let canPresent = Variable<Bool>(true)
        let canDismiss = Variable<Bool>(false)

        self.present = CompletableAction<Bool>(enabledIf: canPresent.asObservable()) { [weak viewController] animated -> Completable in
            guard let viewController = viewController else {
                return Completable.empty()
            }
            return present(viewController, animated)
        }

        self.dismiss = CompletableAction<Bool>(enabledIf: canDismiss.asObservable()) { [weak viewController] animated -> Completable in
            guard let viewController = viewController else {
                return Completable.empty()
            }
            return dismiss(viewController, animated)
        }

        self.didDismiss = Observable
            .merge([
                self.dismiss.completed,
                didDismiss,
            ])
            .take(1)

        let falseDuringPresentation = self.present.executing
            .filter { $0 }
            .map { _ in return false }

        falseDuringPresentation
            .bind(to: canPresent)
            .disposed(by: disposeBag)

        let falseDuringDismissActionExecution = self.dismiss.executing
            .filter { $0 }
            .map { _ in return false }

        let trueAfterFirstPresentation = self.present.completed
            .map { true }
            .take(1)

        Observable
            .merge([
                trueAfterFirstPresentation,
                falseDuringDismissActionExecution,
                self.didDismiss.map { false },
            ])
            .distinctUntilChanged()
            .bind(to: canDismiss)
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()

}
