//
//  DemoHeaderView.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import UIKit

/// Gradient header with a beating heart and how many demos ran
final class DemoHeaderView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let heartView = UIImageView(image: UIImage(systemName: "heart.fill"))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let progressLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildViews()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        startHeartbeat()
    }

    func render(done: Int, total: Int) {
        progressLabel.text = "\(done) of \(total) demos ran"
        UIView.animate(withDuration: 0.4) {
            self.progressView.setProgress(total == 0 ? 0 : Float(done) / Float(total), animated: true)
        }
    }

    private func startHeartbeat() {
        guard heartView.layer.animation(forKey: "heartbeat") == nil else {
            return
        }
        let beat = CAKeyframeAnimation(keyPath: "transform.scale")
        beat.values = [1, 1.18, 1, 1.12, 1]
        beat.keyTimes = [0, 0.15, 0.3, 0.45, 1]
        beat.duration = 1.2
        beat.repeatCount = .infinity
        heartView.layer.add(beat, forKey: "heartbeat")
    }

    private func buildViews() {
        gradientLayer.colors = [UIColor.systemPink.cgColor, UIColor.systemOrange.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 24
        gradientLayer.cornerCurve = .continuous
        layer.addSublayer(gradientLayer)
        layer.shadowColor = UIColor.systemPink.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 8)

        heartView.tintColor = .white
        heartView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .bold)
        titleLabel.text = "HealthKitReporter"
        titleLabel.font = .systemFont(ofSize: 28, weight: .heavy)
        titleLabel.textColor = .white
        subtitleLabel.text = "Every public API, running against your Health data"
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        progressView.progressTintColor = .white
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        progressLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        progressLabel.textColor = .white
        progressLabel.text = " "
        progressLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let titleRow = UIStackView(arrangedSubviews: [heartView, titleLabel])
        titleRow.spacing = 10
        titleRow.alignment = .center
        let stack = UIStackView(arrangedSubviews: [titleRow, subtitleLabel, progressView, progressLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.setCustomSpacing(16, after: subtitleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
}
