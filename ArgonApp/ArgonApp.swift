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
    @State private var activeProtocol = "Не выбран"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                // Шапка
                HStack {
                    Text("ARGON PRO")
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

                // Главная кнопка включения туннеля
                Button(action: toggleTunnel) {
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
                            Text(activeProtocol)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.gray)
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

                // Расширенный режим с парсером конфигов
                if isAdvancedMode {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Конфигурация (vless://, hy2://, ss://):")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("Вставьте ссылку вашего сервера...", text: $configInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: configInput) { oldVal, newValue in
                                parseConfig(newValue)
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
               // Функция разбора ссылки и определения протокола
    func parseConfig(_ link: String) {
        let trimmed = link.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("vless://") {
            activeProtocol = "VLESS (Reality/TLS)"
            securityWarning = ""
        } else if trimmed.hasPrefix("hy2://") || trimmed.hasPrefix("hysteria2://") {
            activeProtocol = "Hysteria 2"
            securityWarning = ""
        } else if trimmed.hasPrefix("ss://") {
            activeProtocol = "Shadowsocks"
            securityWarning = "⚠️ Проверьте шифрование Shadowsocks."
        } else {
            activeProtocol = "Неизвестный формат"
            if !trimmed.isEmpty {
                securityWarning = "⚠️ Неверный формат ссылки."
            }
        }
    }

    // Запуск системного туннеля
    func toggleTunnel() {
        NEVPNManager.shared().loadFromPreferences { error in
            guard error == nil else { return }
            
            let p = NEVPNProtocolIKEv2()
            p.serverAddress = configInput.isEmpty ? "1.1.1.1" : "Argon-Custom-Node"
            NEVPNManager.shared().protocolConfiguration = p
            NEVPNManager.shared().localizedDescription = "Argon VPN Client"
            NEVPNManager.shared().isEnabled = true

            NEVPNManager.shared().saveToPreferences { error in
                guard error == nil else { return }
                do {
                    if isConnected {
                        NEVPNManager.shared().connection.stopVPNTunnel()
                        isConnected = false
                        statusText = "Отключено"
                    } else {
                        try NEVPNManager.shared().connection.startVPNTunnel()
                        isConnected = true
                        statusText = "Защищено"
                    }
                } catch {
                    statusText = "Ошибка"
                }
            }
        }
    }
}
