//  RuleEditorView.swift — "New rule": obstacles, trigger, days and times, apps.

import SwiftUI
import FamilyControls

struct RuleEditorView: View {
    @EnvironmentObject private var store: RuleStore
    @Environment(\.dismiss) private var dismiss

    @State private var rule: Rule
    @State private var usesDelay: Bool
    @State private var delayMinutes: Int
    @State private var showPicker = false

    init(rule: Rule) {
        _rule = State(initialValue: rule)
        if case .afterMinutes(let m) = rule.trigger {
            _usesDelay = State(initialValue: true)
            _delayMinutes = State(initialValue: m)
        } else {
            _usesDelay = State(initialValue: false)
            _delayMinutes = State(initialValue: 10)
        }
    }

    // Mon → Sun, using Calendar weekday numbers (1 = Sunday).
    private let dayOrder = [2, 3, 4, 5, 6, 7, 1]
    private let dayLetters = ["M", "T", "W", "T", "F", "S", "S"]

    private var canSave: Bool {
        #if targetEnvironment(simulator)
        return !rule.obstacles.isEmpty          // the app picker doesn't work in the simulator
        #else
        return !rule.obstacles.isEmpty && rule.appCount > 0
        #endif
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    card("Name") {
                        TextField("Rule name", text: $rule.name)
                            .textFieldStyle(.roundedBorder)
                    }

                    card("1 · Obstacles", subtitle: "Pick one or more. They run in this order.") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), alignment: .leading)],
                                  alignment: .leading, spacing: 10) {
                            ForEach(ObstacleKind.allCases) { kind in
                                let position = rule.obstacles.firstIndex(of: kind)
                                Chip(title: kind.shortTitle,
                                     selected: position != nil,
                                     badge: position.map { $0 + 1 }) {
                                    toggle(kind)
                                }
                            }
                        }
                    }

                    card("2 · When it kicks in") {
                        HStack(spacing: 10) {
                            Chip(title: "As soon as the app opens", selected: !usesDelay) { usesDelay = false }
                            Chip(title: "After a set time", selected: usesDelay) { usesDelay = true }
                        }
                        if usesDelay {
                            Stepper("After \(delayMinutes) minutes", value: $delayMinutes, in: 1...120)
                        }
                    }

                    card("3 · Days and times") {
                        HStack(spacing: 6) {
                            ForEach(0..<7, id: \.self) { i in
                                dayButton(weekday: dayOrder[i], letter: dayLetters[i])
                            }
                        }
                        HStack(spacing: 8) {
                            preset("Every day", Set(1...7))
                            preset("School nights", [1, 2, 3, 4, 5])
                            preset("Weekends", [7, 1])
                        }
                        Toggle("All day", isOn: $rule.allDay)
                            .font(.headline)
                        if !rule.allDay {
                            HStack {
                                DatePicker("From", selection: time(\.start), displayedComponents: .hourAndMinute)
                                DatePicker("To", selection: time(\.end), displayedComponents: .hourAndMinute)
                            }
                            .labelsHidden()
                        }
                    }

                    card("4 · Apps", subtitle: "Choose the apps, categories or websites this rule covers.") {
                        Button {
                            showPicker = true
                        } label: {
                            Label(rule.appCount == 0 ? "Choose apps" : "\(rule.appCount) selected · Change",
                                  systemImage: "apps.iphone")
                        }
                        .buttonStyle(.bordered)
                    }

                    card("5 · Unlock for", subtitle: "How long an app stays open after you clear the obstacles.") {
                        Stepper("\(rule.unlockMinutes) minutes", value: $rule.unlockMinutes, in: 15...120, step: 5)
                    }
                }
                .padding(20)
            }
            .background(Color.tgMint.ignoresSafeArea())
            .navigationTitle("New rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    if !canSave {
                        Text(rule.obstacles.isEmpty ? "Pick at least one obstacle." : "Choose at least one app to save.")
                            .font(.footnote.bold())
                            .foregroundStyle(Color.tgMuted)
                    }
                    Button("Save rule", action: save)
                        .buttonStyle(TGPrimaryButtonStyle())
                        .disabled(!canSave)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .background(Color.tgMint)
            }
            .familyActivityPicker(isPresented: $showPicker, selection: $rule.selection)
        }
    }

    // MARK: - Pieces

    private func card<Content: View>(_ title: String, subtitle: String? = nil,
                                     @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline).foregroundStyle(Color.tgInk)
            if let subtitle {
                Text(subtitle).font(.subheadline).foregroundStyle(Color.tgMuted)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.tgCard, in: RoundedRectangle(cornerRadius: 22))
    }

    private func dayButton(weekday: Int, letter: String) -> some View {
        let on = rule.weekdays.contains(weekday)
        return Button {
            if on { rule.weekdays.remove(weekday) } else { rule.weekdays.insert(weekday) }
        } label: {
            Text(letter)
                .font(.subheadline.bold())
                .frame(width: 40, height: 40)
                .foregroundStyle(on ? Color.white : Color.tgForest)
                .background(Circle().fill(on ? Color.tgForest : Color.tgChip))
        }
        .buttonStyle(.plain)
    }

    private func preset(_ title: String, _ days: Set<Int>) -> some View {
        Button(title) { rule.weekdays = days }
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.tgChip))
            .foregroundStyle(Color.tgForest)
            .buttonStyle(.plain)
    }

    private func time(_ keyPath: WritableKeyPath<Rule, DateComponents>) -> Binding<Date> {
        Binding(
            get: { Calendar.current.date(from: rule[keyPath: keyPath]) ?? .now },
            set: { rule[keyPath: keyPath] = Calendar.current.dateComponents([.hour, .minute], from: $0) }
        )
    }

    private func toggle(_ kind: ObstacleKind) {
        if let i = rule.obstacles.firstIndex(of: kind) {
            rule.obstacles.remove(at: i)
        } else {
            rule.obstacles.append(kind)
        }
    }

    private func save() {
        rule.trigger = usesDelay ? .afterMinutes(delayMinutes) : .onOpen
        store.save(rule)
        dismiss()
    }
}
