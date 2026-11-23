import SwiftUI

struct RulesView: View {
    @EnvironmentObject private var store: RulesStore
    @State private var editing: ObstacleRule?
    @State private var isDone = false

    /// Called when the user taps "Done" on the final screen.
    let onFinish: () -> Void

    var body: some View {
        Group {
            if isDone { doneContent } else { listContent }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .tgScreen()
        .sheet(item: $editing) { rule in
            let exists = store.contains(rule)
            RuleEditorView(
                rule: rule,
                title: exists ? "Edit rule \(store.number(for: rule))" : "New rule",
                isExisting: exists,
                onSave: { store.save($0) },
                onDelete: { store.delete(rule) }
            )
        }
    }

    // MARK: List

    private var listContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                BackButton()
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Create obstacle rules")
                    .font(.system(size: 34, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                Text("Each rule sets which obstacles appear, when they kick in, when the rule is active, and which apps it covers.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.tgMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)

            HStack {
                Text("\(store.rules.count) of \(RulesStore.limit) rules")
                    .font(.system(size: 15, weight: .bold))
                Spacer()
                HStack(spacing: 5) {
                    ForEach(0..<RulesStore.limit, id: \.self) { index in
                        Capsule()
                            .fill(index < store.rules.count ? Color.tgForest : Color.tgForest.opacity(0.2))
                            .frame(width: 22, height: 8)
                    }
                }
                .accessibilityHidden(true)
            }
            .padding(.horizontal, 4)

            ScrollView {
                VStack(spacing: 10) {
                    if store.rules.isEmpty { emptyState }

                    ForEach(Array(store.rules.enumerated()), id: \.element.id) { index, rule in
                        RuleCard(number: index + 1, rule: rule) { editing = rule }
                    }

                    if store.canAdd {
                        addRuleButton
                    } else {
                        Text("You’ve reached the limit of \(RulesStore.limit) rules. Edit or delete one to make room.")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.tgMuted)
                            .padding(.top, 4)
                    }
                }
            }

            Button(store.rules.isEmpty ? "Create a rule to finish" : "Finish setup") {
                isDone = true
            }
            .buttonStyle(PrimaryActionStyle())
            .disabled(store.rules.isEmpty)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 36))
                .foregroundStyle(Color.tgForest)
            Text("No rules yet")
                .font(.system(size: 19, weight: .semibold))
            Text("Start with one for the apps that keep you up at night.")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.tgMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white.opacity(0.45))
        )
    }

    private var addRuleButton: some View {
        Button {
            editing = ObstacleRule()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                Text(store.rules.isEmpty ? "Create your first rule" : "Add another rule")
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color.tgForest)
            .frame(maxWidth: .infinity, minHeight: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.tgForest, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            )
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: Done

    private var doneContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 14) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.tgForest)
                            .frame(width: 52, height: 52)
                            .background(Circle().fill(Color.tgMint))
                            .accessibilityHidden(true)

                        Text("You’re all set")
                            .font(.system(size: 30, weight: .bold))
                            .accessibilityAddTraits(.isHeader)

                        Text(doneText)
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: 0xD9F3E7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.tgForest)
                    )

                    ForEach(Array(store.rules.enumerated()), id: \.element.id) { index, rule in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rule \(index + 1) · \(rule.obstaclesText)")
                                .font(.system(size: 16, weight: .bold))
                            Text(rule.appsText)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.tgMuted)
                            Text(rule.scheduleText)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.tgMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.tgCard)
                        )
                    }
                }
            }

            VStack(spacing: 10) {
                Button("Edit rules") { isDone = false }
                    .buttonStyle(SecondaryActionStyle(height: 56, fontSize: 17, cornerRadius: 18))
                Button("Done") { onFinish() }
                    .buttonStyle(PrimaryActionStyle(height: 56))
            }
        }
    }

    private var doneText: String {
        let count = store.rules.count
        let subject = count == 1 ? "Your rule is" : "Your \(count) rules are"
        return "\(subject) active. TouchGrass steps in only when a rule applies."
    }
}

// MARK: - Rule card

private struct RuleCard: View {
    let number: Int
    let rule: ObstacleRule
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Rule \(number)")
                        .font(.system(size: 19, weight: .semibold))
                    Spacer()
                    Text("Edit")
                        .font(.system(size: 14, weight: .bold))
                        .underline()
                        .foregroundStyle(Color.tgForest)
                }
                RuleDetailRow(symbol: "shield", text: rule.obstaclesText)
                RuleDetailRow(symbol: "bolt", text: rule.triggerText)
                RuleDetailRow(symbol: "clock", text: rule.scheduleText)
                RuleDetailRow(symbol: "square.grid.2x2", text: rule.appsText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.tgCard)
            )
            .foregroundStyle(Color.tgInk)
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Edit rule \(number)")
    }
}

private struct RuleDetailRow: View {
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 15))
                .foregroundStyle(Color.tgForest)
                .frame(width: 18)
                .accessibilityHidden(true)
            Text(text)
                .font(.system(size: 14))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack { RulesView(onFinish: {}) }
        .environmentObject(RulesStore())
}
