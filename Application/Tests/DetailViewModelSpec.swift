// swiftlint:disable function_body_length

import Quick
import Nimble
import ReactiveSwift
import Result

@testable import Application

class DetailViewModelSpec: QuickSpec {
    override func spec() {

        var viewModel: DetailViewModel!

        beforeEach {
            viewModel = DetailViewModel()
        }

        describe("DetailViewModel") {
            it("should initialize with a false isActive") {
                expect(viewModel.isActive.value).to(beFalse())
            }

            describe("selectionResult") {
                it("should intialize as nil") {
                    expect(viewModel.selectionResult.value).to(beNil())
                }

                it("should update with the value of a selection presentation") {
                    let presenter = StubSelectionPresenter()
                    viewModel.selectionPresenter = presenter

                    let selectionValue = "Test selection input"

                    presenter.selectionPresentation.signal
                        .skipNil()
                        .observeValues { viewModel in
                            viewModel.input.value = selectionValue
                            viewModel.submit.apply().start()
                        }

                    viewModel.presentSelection.apply(false).start()

                    expect(viewModel.selectionResult.value).to(equal(selectionValue))
                }

                it("should be used to set the default value of the selection view model") {
                    let presenter = StubSelectionPresenter()
                    viewModel.selectionPresenter = presenter

                    let value = "Test selection input"

                    presenter.selectionPresentation.signal
                        .skipNil()
                        .take(first: 1)
                        .observeValues { viewModel in
                            viewModel.input.value = value
                            viewModel.submit.apply().start()
                    }

                    viewModel.presentSelection.apply(false).start()

                    var defaultValue: String??

                    presenter.selectionPresentation.signal
                        .skipNil()
                        .observeValues { viewModel in
                            defaultValue = viewModel.input.value
                    }

                    viewModel.presentSelection.apply(false).start()

                    expect(defaultValue).to(equal(value))
                }
            }

            describe("title") {
                it("should be the correct value") {
                    expect(viewModel.title.value).to(equal(L10n.Detail.title))
                }
            }
        }

    }
}

// swiftlint:enable function_body_length
