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

    private let badgeView = UIView()
    private let badgeImageView = UIImageView()
    private let titleLabel = UILabel()
    private let callLabel = UILabel()
    private let statusImageView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let liveLabel = UILabel()
    private let resultContainer = UIView()
    private let resultLabel = UILabel()
    private var shownResult: DemoResult = .idle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildViews()
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
        resultContainer.backgroundColor = tint.withAlphaComponent(0.08)
        resultContainer.layer.borderColor = tint.withAlphaComponent(0.25).cgColor
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
        resultContainer.isHidden = result == .idle
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
        resultContainer.alpha = 0
        resultContainer.transform = CGAffineTransform(translationX: 0, y: -6)
        UIView.animate(withDuration: 0.35, delay: 0.05, options: .curveEaseOut) {
            self.resultContainer.alpha = 1
            self.resultContainer.transform = .identity
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

    private func buildViews() {
        selectionStyle = .none
        badgeView.layer.cornerRadius = 9
        badgeView.layer.cornerCurve = .continuous
        badgeImageView.tintColor = .white
        badgeImageView.contentMode = .scaleAspectFit
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        callLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        callLabel.textColor = .secondaryLabel
        callLabel.numberOfLines = 0
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        spinner.hidesWhenStopped = true
        liveLabel.text = "LIVE"
        liveLabel.font = .systemFont(ofSize: 10, weight: .heavy)
        liveLabel.textColor = .white
        liveLabel.backgroundColor = .systemRed
        liveLabel.textAlignment = .center
        liveLabel.layer.cornerRadius = 4
        liveLabel.layer.masksToBounds = true
        resultContainer.layer.cornerRadius = 10
        resultContainer.layer.cornerCurve = .continuous
        resultContainer.layer.borderWidth = 1
        resultLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        resultLabel.numberOfLines = 14

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, liveLabel, UIView()])
        titleRow.spacing = 8
        titleRow.alignment = .center
        let textStack = UIStackView(arrangedSubviews: [titleRow, callLabel, resultContainer])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.setCustomSpacing(10, after: callLabel)
        let statusContainer = UIView()
        statusContainer.addSubview(statusImageView)
        statusContainer.addSubview(spinner)
        let row = UIStackView(arrangedSubviews: [badgeView, textStack, statusContainer])
        row.spacing = 12
        row.alignment = .top
        badgeView.addSubview(badgeImageView)
        resultContainer.addSubview(resultLabel)
        contentView.addSubview(row)

        [row, badgeView, badgeImageView, statusContainer, statusImageView, spinner, liveLabel, resultLabel]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            row.topAnchor.constraint(equalTo: margins.topAnchor),
            row.bottomAnchor.constraint(equalTo: margins.bottomAnchor),

            badgeView.widthAnchor.constraint(equalToConstant: 34),
            badgeView.heightAnchor.constraint(equalToConstant: 34),
            badgeImageView.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            badgeImageView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            badgeImageView.widthAnchor.constraint(equalToConstant: 20),
            badgeImageView.heightAnchor.constraint(equalToConstant: 20),

            statusContainer.widthAnchor.constraint(equalToConstant: 28),
            statusContainer.heightAnchor.constraint(equalToConstant: 28),
            statusImageView.topAnchor.constraint(equalTo: statusContainer.topAnchor),
            statusImageView.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor),
            statusImageView.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor),
            statusImageView.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor),
            spinner.centerXAnchor.constraint(equalTo: statusContainer.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor),

            liveLabel.widthAnchor.constraint(equalToConstant: 34),
            liveLabel.heightAnchor.constraint(equalToConstant: 16),

            resultLabel.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 10),
            resultLabel.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -10),
            resultLabel.topAnchor.constraint(equalTo: resultContainer.topAnchor, constant: 8),
            resultLabel.bottomAnchor.constraint(equalTo: resultContainer.bottomAnchor, constant: -8)
        ])
    }
}
