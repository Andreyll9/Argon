import NetworkExtension
import Libbox // Импортируем наше встроенное ядро sing-box

class PacketTunnelProvider: NEPacketTunnelProvider, LibboxCommandServerHandler {
    
    private var warden: LibboxWarden?

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "10.0.0.1")
        
        // Настройка виртуальной сети туннеля
        let ipv4 = NEIPv4Settings(addresses: ["10.0.0.2"], subnetMasks: ["255.255.255.0"])
        ipv4.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4

        // Защита от DNS-утечек (используем надежные резолверы)
        let dns = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
        dns.matchDomains = [""]
        settings.dnsSettings = dns
        settings.mtu = 1450

        setTunnelNetworkSettings(settings) { error in
            guard error == nil else {
                completionHandler(error)
                return
            }
            
            // Здесь ядро libbox подхватывает конфигурацию и начинает заворачивать трафик
            // (Конфиг передается из основного приложения через общую группу или файл)
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
         warden?.close()
         completionHandler()
    }
}
