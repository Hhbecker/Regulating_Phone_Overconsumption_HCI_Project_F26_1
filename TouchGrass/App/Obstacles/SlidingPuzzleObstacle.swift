import SwiftUI

struct SlidingPuzzleObstacle: View {
    var onComplete: () -> Void
    @State private var tiles = SlidingPuzzleObstacle.shuffled()

    private static let solved = [1, 2, 3, 4, 5, 6, 7, 8, 0]   // 0 is the empty space

    var body: some View {
        VStack(spacing: 16) {
            Text("Slide the tiles back into order, 1 to 8.")
                .foregroundStyle(Color.tgMuted)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(tiles, id: \.self) { value in
                    tile(value)
                }
            }
            .frame(maxWidth: 320)
        }
    }

    @ViewBuilder
    private func tile(_ value: Int) -> some View {
        if value == 0 {
            Color.clear.aspectRatio(1, contentMode: .fit)
        } else {
            Button { tap(value) } label: {
                Text("\(value)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(Color.tgForest)
                    .background(Color.tgCard, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
    }

    private func tap(_ value: Int) {
        guard let i = tiles.firstIndex(of: value),
              let blank = tiles.firstIndex(of: 0),
              Self.neighbors(of: blank).contains(i) else { return }
        withAnimation(.snappy) { tiles.swapAt(i, blank) }
        if tiles == Self.solved {
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                onComplete()
            }
        }
    }

    /// Shuffles by making random legal moves, so the puzzle is always solvable.
    private static func shuffled() -> [Int] {
        var t = solved
        var blank = 8
        var previous = -1
        for _ in 0..<80 {
            let options = neighbors(of: blank).filter { $0 != previous }
            guard let pick = options.randomElement() else { continue }
            t.swapAt(blank, pick)
            previous = blank
            blank = pick
        }
        return t == solved ? shuffled() : t
    }

    private static func neighbors(of i: Int) -> [Int] {
        let row = i / 3, col = i % 3
        var n: [Int] = []
        if row > 0 { n.append(i - 3) }
        if row < 2 { n.append(i + 3) }
        if col > 0 { n.append(i - 1) }
        if col < 2 { n.append(i + 1) }
        return n
    }
}
