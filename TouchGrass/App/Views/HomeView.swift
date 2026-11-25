//  HomeView.swift — list of rules.

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: RuleStore
    @EnvironmentObject private var screenTime: ScreenTimeManager
    @State private var editing: Rule?

    var body: some View {
        NavigationStack {
            List {
                if !screenTime.isAuthorized {
                    Section {
                        Text("TouchGrass needs Screen Time access before rules can block anything.")
                        Button("Allow Screen Time access") {
                            Task { await screenTime.requestAuthorization() }
                        }
                    }
                }

                Section("Your rules") {
                    if store.rules.isEmpty {
                        Text("No rules yet. Tap + to put an obstacle in front of an app.")
                            .foregroundStyle(Color.tgMuted)
                    }
                    ForEach(store.rules) { rule in
                        Button { editing = rule } label: { RuleRow(rule: rule) }
                            .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        offsets.map { store.rules[$0] }.forEach { store.delete($0) }
                    }
                }

                Section {
                    NavigationLink("Try the obstacles") { ObstacleMenuView() }
                }
                
                Section {
                    NavigationLink("Go home") { OnboardingFlow() }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.tgMint.ignoresSafeArea())
            .navigationTitle("TouchGrass")
            .toolbar {
                Button { editing = Rule() } label: { Image(systemName: "plus") }
            }
            .sheet(item: $editing) { rule in
                RuleEditorView(rule: rule)
            }
        }
    }
}

struct RuleRow: View {
    let rule: Rule

    private var triggerText: String {
        switch rule.trigger {
        case .onOpen: "As soon as the app opens"
        case .afterMinutes(let m): "After \(m) min in the app"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rule.name).font(.headline).foregroundStyle(Color.tgInk)
            Text(rule.obstacles.map(\.shortTitle).joined(separator: " → "))
                .font(.subheadline)
            Text("\(triggerText) · \(rule.appCount) app\(rule.appCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(Color.tgMuted)
        }
        .padding(.vertical, 4)
    }
}
