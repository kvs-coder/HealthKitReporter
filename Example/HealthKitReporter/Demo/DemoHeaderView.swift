//
//  DemoHeaderView.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import UIKit

/// Gradient header with a beating heart and how many demos ran
final class DemoHeaderView: UIView {
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.systemPink.cgColor, UIColor.systemOrange.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        return layer
    }()
    private let heartImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.tintColor = .white
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .bold)
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "HealthKitReporter"
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Every public API, running against your Health data"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .white
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true
        return progressView
    }()
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
        label.textColor = .white
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    convenience init() {
        self.init(frame: .zero)
        addSubviews()
        makeConstraints()
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

    func addSubviews() {
        layer.addSublayer(gradientLayer)
        layer.shadowColor = UIColor.systemPink.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 8)
        addSubview(stackView)
        titleStackView.addArrangedSubview(heartImageView)
        titleStackView.addArrangedSubview(titleLabel)
        [titleStackView, subtitleLabel, progressView, progressLabel].forEach(stackView.addArrangedSubview)
        stackView.setCustomSpacing(16, after: subtitleLabel)
    }

    func makeConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }

    private func startHeartbeat() {
        guard heartImageView.layer.animation(forKey: "heartbeat") == nil else {
            return
        }
        let beat = CAKeyframeAnimation(keyPath: "transform.scale")
        beat.values = [1, 1.18, 1, 1.12, 1]
        beat.keyTimes = [0, 0.15, 0.3, 0.45, 1]
        beat.duration = 1.2
        beat.repeatCount = .infinity
        heartImageView.layer.add(beat, forKey: "heartbeat")
    }
}
