import SwiftUI

struct ObstaclesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                BackButton()
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Digital obstacles")
                    .font(.system(size: 34, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                Text("Tap one to try it. You’ll face your chosen obstacle each time you open a blocked app.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.tgMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Obstacle.allCases) { obstacle in
                        NavigationLink(value: Route.obstacleDemo(obstacle)) {
                            ObstacleRow(obstacle: obstacle)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            NavigationLink(value: Route.rules) {
                HStack(spacing: 10) {
                    Text("Next: create rules")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(PrimaryActionStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .tgScreen()
    }
}

private struct ObstacleRow: View {
    let obstacle: Obstacle

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: obstacle.symbol)
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(Color.tgForest)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.tgTile)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(obstacle.title)
                    .font(.system(size: 19, weight: .semibold))
                Text(obstacle.detail)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.tgSubtle)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.tgForest)
                .accessibilityHidden(true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.tgCard)
        )
        .foregroundStyle(Color.tgInk)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    NavigationStack { ObstaclesView() }
}
