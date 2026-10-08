//
//  DemoViewController.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import UIKit

/// Binds **DemoView** to **DemoViewModel**; holds no HealthKit logic
final class DemoViewController: UIViewController {
    private let baseView: DemoView
    private let viewModel: DemoViewModel
    private var cancellables = Set<AnyCancellable>()

    init(
        baseView: DemoView = DemoView(),
        viewModel: DemoViewModel = DemoViewModel()
    ) {
        self.baseView = baseView
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        view = baseView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demo"
        navigationItem.largeTitleDisplayMode = .never
        bindUI()
        viewModel.input.launched.send()
    }

    private func bindUI() {
        viewModel.output.sections
            .sink { [unowned self] sections in
                baseView.render(sections: sections)
            }
            .store(in: &cancellables)
        viewModel.output.results
            .sink { [unowned self] results in
                baseView.render(results: results)
            }
            .store(in: &cancellables)
        viewModel.output.progress
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] progress in
                baseView.render(progress: progress)
            }
            .store(in: &cancellables)
        baseView.rowSelected
            .subscribe(viewModel.input.run)
            .store(in: &cancellables)
    }
}
