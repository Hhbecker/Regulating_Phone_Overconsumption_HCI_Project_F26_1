import SwiftUI

struct RuleEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ObstacleRule

    let title: String
    let isExisting: Bool
    let onSave: (ObstacleRule) -> Void
    let onDelete: () -> Void

    init(
        rule: ObstacleRule,
        title: String,
        isExisting: Bool,
        onSave: @escaping (ObstacleRule) -> Void,
        onDelete: @escaping () -> Void
    ) {
        _draft = State(initialValue: rule)
        self.title = title
        self.isExisting = isExisting
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(spacing: 16) {
            header

            ScrollView {
                VStack(spacing: 12) {
                    obstaclesCard
                    triggerCard
                    scheduleCard
                    appsCard

                    if isExisting {
                        Button("Delete this rule", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.tgDanger)
                        .frame(minHeight: 48)
                    }
                }
            }

            footer
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .foregroundStyle(Color.tgInk)
        .background(Color.tgMint.ignoresSafeArea())
        .presentationDragIndicator(.visible)
    }

    // MARK: Header / footer

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.tgForest)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.tgForest.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cancel")

            Spacer()
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            Spacer()

            // Balances the close button so the title stays centered.
            Color.clear.frame(width: 44, height: 44)
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Text(draft.isValid ? " " : "Choose \(draft.missingItems.joined(separator: ", ")) to save.")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.tgMuted)
                .frame(minHeight: 18)

            Button("Save rule") {
                onSave(draft)
                dismiss()
            }
            .buttonStyle(PrimaryActionStyle())
            .disabled(!draft.isValid)
        }
    }

    // MARK: 1 · Obstacles

    private var obstaclesCard: some View {
        EditorCard(title: "1 · Obstacles", subtitle: "Pick one or more. They run in this order.") {
            FlowLayout(spacing: 8) {
                ForEach(Obstacle.allCases) { obstacle in
                    ChipButton(
                        title: obstacle.chipName,
                        isOn: draft.obstacles.contains(obstacle)
                    ) {
                        toggle(obstacle, in: &draft.obstacles)
                    }
                }
            }
        }
    }

    // MARK: 2 · Trigger

    private var triggerCard: some View {
        EditorCard(title: "2 · When obstacle kicks in") {
            HStack(spacing: 8) {
                triggerButton("As soon as the app opens", trigger: .onOpen)
                triggerButton("After a set time in the app", trigger: .afterDelay)
            }

            if draft.trigger == .afterDelay {
                HStack {
                    stepperButton(symbol: "minus", label: "5 minutes less") {
                        draft.minutes = max(ObstacleRule.minMinutes, draft.minutes - 5)
                    }
                    Spacer()
                    Text("After \(draft.minutes) min")
                        .font(.system(size: 20, weight: .semibold))
                        .accessibilityElement(children: .combine)
                    Spacer()
                    stepperButton(symbol: "plus", label: "5 minutes more") {
                        draft.minutes = min(ObstacleRule.maxMinutes, draft.minutes + 5)
                    }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.tgTile)
                )
            }
        }
    }

    private func triggerButton(_ title: String, trigger: RuleTrigger) -> some View {
        let isOn = draft.trigger == trigger
        return Button { draft.trigger = trigger } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, minHeight: 56)
                .foregroundStyle(isOn ? Color.white : Color.tgForest)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isOn ? Color.tgForest : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.tgForest, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    private func stepperButton(symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.tgForest)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.tgCard)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: 3 · Schedule

    private var scheduleCard: some View {
        EditorCard(title: "3 · When rule applies") {
            HStack(spacing: 6) {
                ForEach(Weekday.allCases) { day in
                    let isOn = draft.days.contains(day)
                    Button {
                        if isOn { draft.days.remove(day) } else { draft.days.insert(day) }
                    } label: {
                        Text(day.initial)
                            .font(.system(size: 14, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .foregroundStyle(isOn ? Color.white : Color.tgForest)
                            .background(Circle().fill(isOn ? Color.tgForest : Color.clear))
                            .overlay(Circle().stroke(Color.tgForest, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(day.fullName)
                    .accessibilityAddTraits(isOn ? .isSelected : [])
                }
            }

            HStack(spacing: 6) {
                presetButton("Every day", days: Set(Weekday.allCases))
                presetButton("Weekdays", days: ObstacleRule.weekdays)
                presetButton("Weekends", days: ObstacleRule.weekend)
            }

            Toggle("All day", isOn: $draft.allDay)
                .font(.system(size: 15, weight: .semibold))
                .tint(Color.tgForest)
                .frame(minHeight: 44)

            if !draft.allDay {
                HStack(spacing: 8) {
                    timePicker("From", selection: $draft.start)
                    timePicker("To", selection: $draft.end)
                }
                if draft.runsOvernight {
                    Text("Runs overnight, into the next morning.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.tgSubtle)
                }
            }
        }
    }

    private func presetButton(_ title: String, days: Set<Weekday>) -> some View {
        Button(title) { draft.days = days }
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.tgForest)
            .padding(.horizontal, 12)
            .frame(minHeight: 36)
            .background(Capsule().fill(Color.tgTile))
            .buttonStyle(.plain)
    }

    private func timePicker(_ label: String, selection: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.tgMuted)
            DatePicker(label, selection: selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: 4 · Apps

    private var appsCard: some View {
        EditorCard(title: "4 · Apps the rule applies to") {
            FlowLayout(spacing: 8) {
                ForEach(SocialApp.all, id: \.self) { app in
                    ChipButton(title: app, isOn: draft.apps.contains(app)) {
                        toggle(app, in: &draft.apps)
                    }
                }
            }
        }
    }

    // MARK: Helpers

    /// Adds the item if missing, removes it if present (keeps selection order).
    private func toggle<T: Equatable>(_ item: T, in list: inout [T]) {
        if let index = list.firstIndex(of: item) {
            list.remove(at: index)
        } else {
            list.append(item)
        }
    }
}

#Preview {
    RuleEditorView(
        rule: ObstacleRule(),
        title: "New rule",
        isExisting: false,
        onSave: { _ in },
        onDelete: {}
    )
}
