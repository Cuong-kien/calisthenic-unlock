import SwiftUI
import UIKit

struct SpriteConfig {
    let imageName: String
    let frameCount: Int
    let columns: Int
    let fps: Double

    var rows: Int { Int(ceil(Double(frameCount) / Double(columns))) }
}

struct SpriteAnimationView: View {
    let config: SpriteConfig
    var maxWidth: CGFloat = .infinity
    @State private var frameIndex: Int = 0

    private var frameAspectRatio: CGFloat {
        guard let img = UIImage(named: config.imageName) else { return 1 }
        return (img.size.width / CGFloat(config.columns)) / (img.size.height / CGFloat(config.rows))
    }

    var body: some View {
        let col = CGFloat(frameIndex % config.columns)
        let row = CGFloat(frameIndex / config.columns)

        Color.clear
            .aspectRatio(frameAspectRatio, contentMode: .fit)
            .frame(maxWidth: maxWidth)
            .overlay(
                GeometryReader { geo in
                    Image(config.imageName)
                        .resizable()
                        .frame(
                            width: geo.size.width * CGFloat(config.columns),
                            height: geo.size.height * CGFloat(config.rows)
                        )
                        .offset(x: -col * geo.size.width, y: -row * geo.size.height)
                }
                .clipped()
            )
            .onChange(of: config.imageName) { _, _ in
                frameIndex = 0
            }
            .allowsHitTesting(false)
            .task(id: config.imageName) {
                frameIndex = 0
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(1.0 / config.fps))
                    if Task.isCancelled { break }
                    frameIndex = (frameIndex + 1) % config.frameCount
                }
            }

    }
}
