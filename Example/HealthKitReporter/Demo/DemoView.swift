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

    private let headerView = DemoHeaderView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var results = [DemoRow: DemoResult]()
    private lazy var dataSource = UITableViewDiffableDataSource<DemoSection, DemoRow>(
        tableView: tableView
    ) { [unowned self] tableView, indexPath, row in
        let cell = tableView.dequeueReusableCell(withIdentifier: DemoCell.reuseIdentifier, for: indexPath)
        (cell as? DemoCell)?.configure(row: row, result: results[row] ?? .idle)
        return cell
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildViews()
    }

    required init?(coder: NSCoder) {
        nil
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
        let container = tableView.tableHeaderView
        let width = tableView.bounds.width
        guard let container = container, width > 0 else {
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

    private func buildViews() {
        backgroundColor = .systemGroupedBackground
        tableView.backgroundColor = .clear
        tableView.register(DemoCell.self, forCellReuseIdentifier: DemoCell.reuseIdentifier)
        tableView.delegate = self
        tableView.sectionHeaderTopPadding = 12
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        let container = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            headerView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        tableView.tableHeaderView = container
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
        let icon = UIImageView(image: UIImage(systemName: section.symbol))
        icon.tintColor = section.tint
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        icon.setContentHuggingPriority(.required, for: .horizontal)
        let label = UILabel()
        label.text = section.title.uppercased()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = section.tint
        label.setContentHuggingPriority(.required, for: .horizontal)
        let stack = UIStackView(arrangedSubviews: [icon, label, UIView()])
        stack.spacing = 6
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20)
        return stack
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 12)
        UIView.animate(withDuration: 0.35, delay: 0.02 * Double(indexPath.row % 8), options: .curveEaseOut) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }
}
