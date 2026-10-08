//
//  DemoView.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import UIKit

/// The demo list: a header and one row per public method, grouped by section
final class DemoView: UIView {
    /// Rows the user taps
    let rowSelected = PassthroughSubject<DemoRow, Never>()

    private let headerView: DemoHeaderView = {
        let headerView = DemoHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    /// Sized by hand in layoutSubviews, since a table header view doesn't follow Auto Layout
    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 12
        tableView.register(DemoCell.self, forCellReuseIdentifier: DemoCell.reuseIdentifier)
        return tableView
    }()
    private var results = [DemoRow: DemoResult]()
    private lazy var dataSource = UITableViewDiffableDataSource<DemoSection, DemoRow>(
        tableView: tableView
    ) { [unowned self] tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: DemoCell.reuseIdentifier, for: indexPath)
        (cell as? DemoCell)?.configure(row: row, result: results[row] ?? .idle)
        return cell
    }

    convenience init() {
        self.init(frame: .zero)
        backgroundColor = .systemGroupedBackground
        tableView.delegate = self
        addSubviews()
        makeConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        sizeHeaderToFit()
    }

    func render(sections: [DemoSection]) {
        var snapshot = NSDiffableDataSourceSnapshot<DemoSection, DemoRow>()
        snapshot.appendSections(sections)
        sections.forEach { snapshot.appendItems($0.rows, toSection: $0) }
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    /// Reconfigures only the rows whose result changed, animating the new height
    func render(results newResults: [DemoRow: DemoResult]) {
        let changed = newResults.filter { results[$0.key] != $0.value }.map(\.key)
        results = newResults
        guard !changed.isEmpty else {
            return
        }
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(changed)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func render(progress: (done: Int, total: Int)) {
        headerView.render(done: progress.done, total: progress.total)
    }

    private func sizeHeaderToFit() {
        let container = headerContainerView
        let width = tableView.bounds.width
        guard width > 0 else {
            return
        }
        let size = container.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        if container.frame.size != size {
            container.frame.size = size
            tableView.tableHeaderView = container
        }
    }

    func addSubviews() {
        addSubview(tableView)
        headerContainerView.addSubview(headerView)
        tableView.tableHeaderView = headerContainerView
    }

    func makeConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let headerMargins = headerContainerView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerView.leadingAnchor.constraint(equalTo: headerMargins.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: headerMargins.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 8),
            headerView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -8)
        ])
    }
}
// MARK: - UITableViewDelegate
extension DemoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSource.itemIdentifier(for: indexPath).map(rowSelected.send)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = dataSource.sectionIdentifier(for: section) else {
            return nil
        }
        return DemoSectionHeaderView(section: section)
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 12)
        UIView.animate(
            withDuration: 0.35,
            delay: 0.02 * Double(indexPath.row % 8),
            options: .curveEaseOut
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }
}
