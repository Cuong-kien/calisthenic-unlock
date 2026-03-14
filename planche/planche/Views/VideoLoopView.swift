import AVKit
import SwiftUI

struct VideoLoopView: View {
    let videoName: String
    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .onAppear {
                guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else { return }
                let item = AVPlayerItem(url: url)
                let qp = AVQueuePlayer()
                looper = AVPlayerLooper(player: qp, templateItem: item)
                player = qp
                qp.isMuted = true
                qp.play()
            }
            .onDisappear {
                player?.pause()
                player = nil
                looper = nil
            }
    }
}
