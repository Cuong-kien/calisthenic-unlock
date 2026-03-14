import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @AppStorage("notif_enabled") private var enabled: Bool = false
    @AppStorage("notif_days")    private var daysData: Data = Data()

    @State private var showPermissionDeniedAlert = false

    private var selectedDays: Set<Int> {
        get { (try? JSONDecoder().decode(Set<Int>.self, from: daysData)) ?? [] }
    }

    private func setSelectedDays(_ days: Set<Int>) {
        daysData = (try? JSONEncoder().encode(days)) ?? Data()
    }

    private let dayLabels = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Notification")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)

                // Toggle row
                HStack {
                    Text("Training Reminders")
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { enabled },
                        set: { newValue in
                            if newValue {
                                enabled = true
                                requestAuthorizationAndEnable()
                            } else {
                                enabled = false
                                rescheduleNotifications()
                            }
                        }
                    ))
                    .labelsHidden()
                    .tint(Color(hex: "0061EB"))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 24)

                // Day picker (shown when enabled)
                if enabled {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Days")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 24)

                        HStack(spacing: 8) {
                            ForEach(0..<7, id: \.self) { day in
                                let isSelected = selectedDays.contains(day)
                                Button {
                                    var days = selectedDays
                                    if isSelected { days.remove(day) } else { days.insert(day) }
                                    setSelectedDays(days)
                                    rescheduleNotifications()
                                } label: {
                                    Text(dayLabels[day])
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(isSelected ? .white : Color.secondary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 36)
                                        .background(isSelected ? Color(hex: "0061EB") : Color(.tertiarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.2), value: enabled)
        .alert("Permission Required", isPresented: $showPermissionDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: "app-settings:") {
                    openURL(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications for Planche in your device Settings to receive training reminders.")
        }
    }

    // MARK: - Permission

    private func requestAuthorizationAndEnable() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    rescheduleNotifications()
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            if granted {
                                rescheduleNotifications()
                            } else {
                                enabled = false
                            }
                        }
                    }
                default:
                    enabled = false
                    showPermissionDeniedAlert = true
                }
            }
        }
    }

    // MARK: - Scheduling

    private func rescheduleNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard enabled else { return }
        for day in selectedDays {
            var comps = DateComponents()
            comps.weekday = day + 1  // UNCalendarTrigger: 1=Sun … 7=Sat
            comps.hour = 9
            comps.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let content = UNMutableNotificationContent()
            content.title = "Time to train"
            content.body  = "Stay consistent — open Planche and complete today's session."
            content.sound = .default
            let request = UNNotificationRequest(
                identifier: "planche_day_\(day)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }
}
