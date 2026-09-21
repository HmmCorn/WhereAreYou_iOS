//
//  MapAccentMarker.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/17/26.
//

import UIKit

/// 말풍선(내부에 accentColor 점 + 텍스트) + 핀으로 구성된 마커 이미지를 만들기 위한 렌더링 전용 뷰
enum MapAccentMarker {

    // MARK: - Public

    static func size(for name: String) -> CGSize {
        let bubbleSize = bubbleSize(for: name)
        return CGSize(
            width: max(bubbleSize.width, pinSize.width) + shadowMargin * 2,
            height: bubbleSize.height + bubbleSpacing + pinSize.height + shadowMargin
        )
    }

    static func anchor(for name: String) -> CGPoint {
        // 핀 이미지(물방울 모양)의 뾰족한 하단 끝이 좌표를 가리키도록 지정
        CGPoint(x: 0.5, y: 1.0)
    }

    static func renderImage(accentColor: UIColor, name: String, pinImage: UIImage?) -> UIImage {
        let size = size(for: name)
        let container = makeView(accentColor: accentColor, name: name, size: size, pinImage: pinImage)
        container.frame = CGRect(origin: .zero, size: size)
        container.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            container.drawHierarchy(in: container.bounds, afterScreenUpdates: true)
        }
    }

}

// MARK: - Private

private extension MapAccentMarker {

    // MARK: - Constants

    /// 말풍선 그림자가 잘리지 않도록 캔버스에 추가로 확보하는 여백
    static let shadowMargin: CGFloat = 8
    /// 말풍선과 핀 사이 간격 (말풍선 꼬리가 이 영역에 그려짐)
    static let bubbleSpacing: CGFloat = 6
    static let bubbleHeight: CGFloat = 26
    static let bubbleHorizontalPadding: CGFloat = 10
    static let bubbleTailHeight: CGFloat = 6
    static let bubbleTailWidth: CGFloat = 10
    static let pinSize = CGSize(width: 32, height: 32)
    static let dotSize = CGSize(width: 8, height: 8)
    static let dotTextSpacing: CGFloat = 6
    static let nameFont: UIFont = .boldPreferredFont(forTextStyle: .caption1)

    // MARK: - Helpers

    static func bubbleSize(for name: String) -> CGSize {
        let textWidth = (name as NSString).size(withAttributes: [.font: nameFont]).width
        let width = ceil(textWidth) + dotSize.width + dotTextSpacing + bubbleHorizontalPadding * 2
        return CGSize(width: width, height: bubbleHeight)
    }

    // MARK: - View Building

    static func makeView(accentColor: UIColor, name: String, size: CGSize, pinImage: UIImage?) -> UIView {
        let container = UIView(frame: CGRect(origin: .zero, size: size))
        let bubbleSize = bubbleSize(for: name)

        let bubbleView = makeBubbleView(accentColor: accentColor, name: name, size: bubbleSize)
        bubbleView.frame = CGRect(
            x: (size.width - bubbleSize.width) / 2,
            y: shadowMargin,
            width: bubbleSize.width,
            height: bubbleSize.height
        )
        container.addSubview(bubbleView)

        let tailView = makeTailView()
        tailView.frame = CGRect(
            x: (size.width - bubbleTailWidth) / 2,
            y: bubbleView.frame.maxY,
            width: bubbleTailWidth,
            height: bubbleTailHeight
        )
        container.addSubview(tailView)

        let pinImageView = UIImageView(image: pinImage)
        pinImageView.contentMode = .scaleAspectFit
        pinImageView.frame = CGRect(
            x: (size.width - pinSize.width) / 2,
            y: tailView.frame.maxY,
            width: pinSize.width,
            height: pinSize.height
        )
        container.addSubview(pinImageView)

        return container
    }

    static func makeBubbleView(accentColor: UIColor, name: String, size: CGSize) -> UIView {
        let bubbleView = UIView()
        bubbleView.backgroundColor = .systemBackground
        bubbleView.layer.cornerRadius = size.height / 2
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.3
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowRadius = 3

        let dotView = UIView()
        dotView.backgroundColor = accentColor
        dotView.layer.cornerRadius = dotSize.height / 2
        dotView.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = nameFont
        nameLabel.textColor = .label
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        bubbleView.addSubview(dotView)
        bubbleView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: bubbleHorizontalPadding),
            dotView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: dotSize.width),
            dotView.heightAnchor.constraint(equalToConstant: dotSize.height),

            nameLabel.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: dotTextSpacing),
            nameLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -bubbleHorizontalPadding),
            nameLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
        ])

        return bubbleView
    }

    static func makeTailView() -> UIView {
        let tailView = TriangleView()
        tailView.backgroundColor = .clear
        tailView.fillColor = .systemBackground
        return tailView
    }

}

/// 말풍선 꼬리를 그리기 위한 아래방향 삼각형 뷰
private final class TriangleView: UIView {

    var fillColor: UIColor = .systemBackground {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(fillColor.cgColor)
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        context.closePath()
        context.fillPath()
    }

}
