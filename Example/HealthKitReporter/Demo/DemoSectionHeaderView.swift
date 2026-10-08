//
//  DemoSectionHeaderView.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import UIKit

/// Section title in the section's tint, after its symbol
final class DemoSectionHeaderView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 4,
            leading: 20,
            bottom: 4,
            trailing: 20
        )
        return stackView
    }()

    convenience init(section: DemoSection) {
        self.init(frame: .zero)
        iconImageView.image = UIImage(systemName: section.symbol)
        iconImageView.tintColor = section.tint
        titleLabel.text = section.title.uppercased()
        titleLabel.textColor = section.tint
        addSubviews()
        makeConstraints()
    }

    func addSubviews() {
        addSubview(stackView)
        [iconImageView, titleLabel, UIView()].forEach(stackView.addArrangedSubview)
    }

    func makeConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
