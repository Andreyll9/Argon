import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "1.1.1.1")
        
        // Настройка локального виртуального интерфейса
        let ipv4 = NEIPv4Settings(addresses: ["172.19.0.1"], subnetMasks: ["255.255.255.252"])
        ipv4.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4

        // Защита от DNS-утечек
        let dns = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
        settings.dnsSettings = dns
        settings.mtu = 1400

        setTunnelNetworkSettings(settings) { error in
            completionHandler(error)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
