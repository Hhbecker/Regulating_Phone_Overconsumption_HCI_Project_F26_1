import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.tgMint.ignoresSafeArea()

            // Decorative layer, kept separate from the buttons
            Image("GrassIllustration")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("TouchGrass")
                        .font(.system(size: 46, weight: .bold))   // Outfit in the prototype
                    Text("Welcome to TouchGrass, look through our menu of digital obstacles, then choose which social media apps to apply them to.")
                        .font(.system(size: 21, weight: .medium))
                        .fixedSize(horizontal: false, vertical: true)
                }

                SetupAgendaCard()

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    NavigationLink(value: Route.obstacles) {
                        HStack(spacing: 10) {
                            Text("See the obstacles")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .buttonStyle(PrimaryActionStyle())

                    NavigationLink(value: Route.rules) {
                        Text("Skip to my rules")
                    }
                    .buttonStyle(SecondaryActionStyle())
                }
                .padding(.bottom, 168)   // keeps the buttons above the grass
            }
            .padding(.horizontal, 28)
            .padding(.top, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .foregroundStyle(Color.tgInk)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack { WelcomeView() }
}
