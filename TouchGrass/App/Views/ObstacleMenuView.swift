//  ObstacleMenuView.swift — "Digital obstacles": tap one to try it.

import SwiftUI

struct ObstacleMenuView: View {
    var onNext: (() -> Void)? = nil
    @State private var trying: ObstacleKind?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Digital obstacles")
                    .font(.tgTitle)
                    .foregroundStyle(Color.tgInk)
                Text("Tap one to try it. You’ll face your chosen obstacle each time you open a blocked app.")
                    .foregroundStyle(Color.tgMuted)
                    .padding(.bottom, 8)

                ForEach(ObstacleKind.allCases) { kind in
                    Button { trying = kind } label: { ObstacleRow(kind: kind) }
                        .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .safeAreaInset(edge: .bottom) {
            if let onNext {
                Button(action: onNext) {
                    Label("Next: set up permissions", systemImage: "arrow.right")
                }
                .buttonStyle(TGPrimaryButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
        .background(Color.tgMint.ignoresSafeArea())
        .sheet(item: $trying) { kind in
            ObstacleView(kind: kind) { trying = nil }
        }
    }
}

struct ObstacleRow: View {
    let kind: ObstacleKind

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: kind.symbol)
                .font(.title2)
                .frame(width: 56, height: 56)
                .background(Color.tgChip, in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text(kind.title).font(.headline)
                Text(kind.detail).font(.subheadline).foregroundStyle(Color.tgMuted)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(Color.tgMuted)
        }
        .foregroundStyle(Color.tgInk)
        .padding(16)
        .background(Color.tgCard, in: RoundedRectangle(cornerRadius: 22))
    }
}
