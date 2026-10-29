import SwiftUI
import NetworkExtension

@main
struct ArgonApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @State private var isConnected = false
    @State private var isAdvancedMode = false
    @State private var configInput = ""
    @State private var statusText = "Отключено"
    @State private var securityWarning = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                // Шапка
                HStack {
                    Text("ARGON LITE")
                        .font(.system(size: 26, weight: .black, design: .monospaced))
                        .foregroundColor(.cyan)
                    Spacer()
                    Button(action: { isAdvancedMode.toggle() }) {
                        Text(isAdvancedMode ? "🛠️ PRO" : "⚡ АВТО")
                            .font(.system(size: 13, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.cyan)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Кнопка включения
                Button(action: togglePersonalVPN) {
                    ZStack {
                        Circle()
                            .stroke(isConnected ? Color.green : Color.cyan.opacity(0.4), lineWidth: 4)
                            .frame(width: 160, height: 160)
                        
                        Circle()
                            .fill(isConnected ? Color.green.opacity(0.15) : Color.cyan.opacity(0.05))
                            .frame(width: 140, height: 140)

                        VStack(spacing: 8) {
                            Image(systemName: isConnected ? "lock.shield.fill" : "lock.shield")
                                .font(.system(size: 42))
                                .foregroundColor(isConnected ? .green : .cyan)
                            Text(statusText)
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                }

                if !securityWarning.isEmpty {
                    Text(securityWarning)
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Расширенный режим (Импорт)
                if isAdvancedMode {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Импорт конфигурации (vless://, hy2://, ss://):")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("Вставьте ссылку...", text: $configInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: configInput) { newValue in
                                if newValue.contains("security=none") {
                                    securityWarning = "⚠️ Внимание: незащищенное соединение без TLS."
                                } else {
                                    securityWarning = ""
                                }
                            }
                    }
                    .padding()
                    .background(Color(white: 0.07))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
