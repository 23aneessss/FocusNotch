import SwiftUI

/// Preferences window content. Tabbed: Timer, Behaviour, Focus, About.
struct SettingsView: View {
    @Bindable var settings: PomodoroSettings
    let focus: FocusController

    var body: some View {
        TabView {
            timerTab
                .tabItem { Label("Timer", systemImage: "timer") }
            behaviourTab
                .tabItem { Label("Behavior", systemImage: "slider.horizontal.3") }
            focusTab
                .tabItem { Label("Focus", systemImage: "moon") }
            aboutTab
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 460, height: 560)
    }

    // MARK: Timer

    private var timerTab: some View {
        Form {
            Section("Durations") {
                stepperRow("Focus", value: $settings.workMinutes, range: 1...120, unit: "min")
                stepperRow("Short break", value: $settings.shortBreakMinutes, range: 1...60, unit: "min")
                stepperRow("Long break", value: $settings.longBreakMinutes, range: 1...60, unit: "min")
            }
            Section("Cycle") {
                stepperRow("Sessions before long break", value: $settings.sessionsBeforeLongBreak, range: 1...12, unit: "")
            }
            Section {
                Button("Reset to defaults") { settings.resetToDefaults() }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: Behaviour

    private var behaviourTab: some View {
        Form {
            Section("Automation") {
                Toggle("Auto-start breaks", isOn: $settings.autoStartBreaks)
                Toggle("Auto-start next focus session", isOn: $settings.autoStartWork)
            }
            Section("Alerts") {
                Toggle("Play sound on phase change", isOn: $settings.playSound)
                Toggle("Show notifications", isOn: $settings.showNotifications)
            }
            Section("Display") {
                Toggle("Show on Macs without a notch", isOn: $settings.showOnNonNotchDisplays)
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: Focus

    private var focusTab: some View {
        Form {
            Section {
                Toggle("Enable Focus during sessions", isOn: $settings.focusEnabled)
            } footer: {
                Text("FocusNotch triggers macOS Focus through Shortcuts. Create two shortcuts (one that turns a Focus on, one that turns it off) in the Shortcuts app, then enter their exact names below.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Shortcut names") {
                TextField("Turn Focus on", text: $settings.focusOnShortcut)
                TextField("Turn Focus off", text: $settings.focusOffShortcut)
            }
            .disabled(!settings.focusEnabled)

            Section {
                Button("Open Shortcuts app") {
                    if let url = URL(string: "shortcuts://") {
                        NSWorkspace.shared.open(url)
                    }
                }
                Button("Test \"on\" shortcut") {
                    FocusController.run(shortcut: settings.focusOnShortcut)
                }
                .disabled(!settings.focusEnabled || settings.focusOnShortcut.isEmpty)
                Button("Test \"off\" shortcut") {
                    FocusController.run(shortcut: settings.focusOffShortcut)
                }
                .disabled(!settings.focusEnabled || settings.focusOffShortcut.isEmpty)
            }
        }
        .formStyle(.grouped)
    }

    // MARK: About

    private var aboutTab: some View {
        VStack(spacing: 14) {
            Image(systemName: "timer")
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(.tint)
            Text("FocusNotch")
                .font(.title2.bold())
            Text("Make your notch useful.")
                .foregroundStyle(.secondary)
            Text("Version \(appVersion)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    // MARK: Helpers

    private func stepperRow(_ title: String, value: Binding<Int>, range: ClosedRange<Int>, unit: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(unit.isEmpty ? "\(value.wrappedValue)" : "\(value.wrappedValue) \(unit)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
            Stepper("", value: value, in: range)
                .labelsHidden()
        }
    }
}
