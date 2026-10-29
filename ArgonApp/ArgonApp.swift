[29.10.2026 17:01] Canary Test: import SwiftUI
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
    @State private var configLink = ""
    @State private var statusText = "Отключено"
    @State private var bypassRu = true
    @State private var antiDPI = true
    @State private var securityWarning = ""

    var body: some View {
        ZStack {
            // Чистый черный цвет AMOLED (#000000)
            Color.black.ignoresSafeArea()

            VStack(spacing: 22) {
                // Шапка и переключатель режимов
                HStack {
                    Text("ARGON")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.cyan)
                    Spacer()
                    Button(action: { isAdvancedMode.toggle() }) {
                        Text(isAdvancedMode ? "🛠️ PRO" : "⚡ АВТО")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.cyan)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Главная кнопка включения
                Button(action: toggleVPN) {
                    ZStack {
                        Circle()
                            .stroke(isConnected ? Color.green : Color.cyan.opacity(0.4), lineWidth: 5)
                            .frame(width: 170, height: 170)
                        
                        Circle()
                            .fill(isConnected ? Color.green.opacity(0.15) : Color.cyan.opacity(0.05))
                            .frame(width: 150, height: 150)

                        VStack(spacing: 8) {
                            Image(systemName: isConnected ? "shield.fill" : "bolt.shield")
                                .font(.system(size: 48))
                                .foregroundColor(isConnected ? .green : .cyan)
                            Text(statusText)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Предупреждение аудита безопасности
                if !securityWarning.isEmpty {
                    Text(securityWarning)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Панель расширенных настроек
                if isAdvancedMode {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Импорт (vless://, hy2://, ss://, awg://):")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("Вставьте ссылку или подписку...", text: $configLink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: configLink) { newValue in
                                checkSecurity(link: newValue)
                            }

                        Toggle("Обход .RU и Госуслуг напрямую", isOn: $bypassRu)
                            .font(.footnote)
[29.10.2026 17:01] Canary Test: .tint(.cyan)
                        
                        Toggle("Фрагментация пакетов (Anti-DPI)", isOn: $antiDPI)
                            .font(.footnote)
                            .tint(.cyan)
                    }
                    .padding()
                    .background(Color(white: 0.08))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    func checkSecurity(link: String) {
        if link.contains("security=none") || link.hasPrefix("http://") {
            securityWarning = "⚠️ Внимание: Конфиг не использует TLS/Reality! Возможна утечка трафика."
        } else {
            securityWarning = ""
        }
    }

    func toggleVPN() {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            let manager = managers?.first ?? NETunnelProviderManager()
            let proto = NETunnelProviderProtocol()
            proto.providerBundleIdentifier = "com.argon.vpn.tunnel"
            proto.serverAddress = "Argon Core (Sing-Box)"
            
            manager.protocolConfiguration = proto
            manager.localizedDescription = "Argon VPN"
            manager.isEnabled = true

            manager.saveToPreferences { error in
                if error == nil {
                    do {
                        if isConnected {
                            manager.connection.stopVPNTunnel()
                            isConnected = false
                            statusText = "Отключено"
                        } else {
                            try manager.connection.startVPNTunnel()
                            isConnected = true
                            statusText = "Защищено"
                        }
                    } catch {
                        statusText = "Ошибка старта"
                    }
                } else {
                    statusText = "Нет прав VPN"
                }
            }
        }
    }
}
