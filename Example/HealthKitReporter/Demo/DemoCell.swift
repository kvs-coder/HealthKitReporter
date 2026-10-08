//
//  DemoCell.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import UIKit

/// A demo row: section badge, title, library call, status and result
final class DemoCell: UITableViewCell {
    static let reuseIdentifier = "DemoCell"

    private let badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 9
        view.layer.cornerCurve = .continuous
        return view
    }()
    private let badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    private let liveLabel: UILabel = {
        let label = UILabel()
        label.text = "LIVE"
        label.font = .systemFont(ofSize: 10, weight: .heavy)
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    private let callLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    private let resultContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        return view
    }()
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        label.numberOfLines = 14
        return label
    }()
    private let statusContainerView = UIView()
    private let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        return imageView
    }()
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    private let rowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 12
        stackView.alignment = .top
        return stackView
    }()
    private var shownResult: DemoResult = .idle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubviews()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func configure(row: DemoRow, result: DemoResult) {
        let tint = row.section.tint
        badgeView.backgroundColor = tint
        badgeImageView.image = UIImage(systemName: row.section.symbol)
        titleLabel.text = row.title
        callLabel.text = row.call
        liveLabel.isHidden = !row.isLive
        resultContainerView.backgroundColor = tint.withAlphaComponent(0.08)
        resultContainerView.layer.borderColor = tint.withAlphaComponent(0.25).cgColor
        apply(result, tint: tint)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.contentView.transform = highlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
        }
    }

    private func apply(_ result: DemoResult, tint: UIColor) {
        let changed = result != shownResult
        shownResult = result
        resultLabel.text = result.text
        resultContainerView.isHidden = result == .idle
        switch result {
        case .idle:
            spinner.stopAnimating()
            statusImageView.image = UIImage(systemName: "play.circle.fill")
            statusImageView.tintColor = tint
        case .running:
            spinner.startAnimating()
            statusImageView.image = nil
            resultLabel.textColor = .secondaryLabel
        case .success:
            spinner.stopAnimating()
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            statusImageView.tintColor = .systemGreen
            resultLabel.textColor = .label
        case .failure:
            spinner.stopAnimating()
            statusImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            statusImageView.tintColor = .systemRed
            resultLabel.textColor = .systemRed
        }
        guard changed, result != .idle else {
            return
        }
        popStatus()
        resultContainerView.alpha = 0
        resultContainerView.transform = CGAffineTransform(translationX: 0, y: -6)
        UIView.animate(withDuration: 0.35, delay: 0.05, options: .curveEaseOut) {
            self.resultContainerView.alpha = 1
            self.resultContainerView.transform = .identity
        }
    }
    /// The status icon springs in when a result arrives
    private func popStatus() {
        statusImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.2,
            options: .allowUserInteraction
        ) {
            self.statusImageView.transform = .identity
        }
    }

    func addSubviews() {
        badgeView.addSubview(badgeImageView)
        resultContainerView.addSubview(resultLabel)
        statusContainerView.addSubview(statusImageView)
        statusContainerView.addSubview(spinner)
        [titleLabel, liveLabel, UIView()].forEach(titleStackView.addArrangedSubview)
        [titleStackView, callLabel, resultContainerView].forEach(textStackView.addArrangedSubview)
        textStackView.setCustomSpacing(10, after: callLabel)
        [badgeView, textStackView, statusContainerView].forEach(rowStackView.addArrangedSubview)
        contentView.addSubview(rowStackView)
    }

    func makeConstraints() {
        [rowStackView, badgeView, badgeImageView, statusContainerView, statusImageView, spinner, liveLabel, resultLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            rowStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            rowStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            rowStackView.topAnchor.constraint(equalTo: margins.topAnchor),
            rowStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),

            badgeView.widthAnchor.constraint(equalToConstant: 34),
            badgeView.heightAnchor.constraint(equalToConstant: 34),
            badgeImageView.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            badgeImageView.widthAnchor.constraint(equalToConstant: 20),
            badgeImageView.heightAnchor.constraint(equalToConstant: 20),

            statusContainerView.widthAnchor.constraint(equalToConstant: 28),
            statusContainerView.heightAnchor.constraint(equalToConstant: 28),
            statusImageView.topAnchor.constraint(equalTo: statusContainerView.topAnchor),
            statusImageView.bottomAnchor.constraint(equalTo: statusContainerView.bottomAnchor),
            statusImageView.leadingAnchor.constraint(equalTo: statusContainerView.leadingAnchor),
            statusImageView.trailingAnchor.constraint(equalTo: statusContainerView.trailingAnchor),
            spinner.centerXAnchor.constraint(equalTo: statusContainerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: statusContainerView.centerYAnchor),

            liveLabel.widthAnchor.constraint(equalToConstant: 34),
            liveLabel.heightAnchor.constraint(equalToConstant: 16),

            resultLabel.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 10),
            resultLabel.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -10),
            resultLabel.topAnchor.constraint(equalTo: resultContainerView.topAnchor, constant: 8),
            resultLabel.bottomAnchor.constraint(equalTo: resultContainerView.bottomAnchor, constant: -8)
        ])
    }
}
