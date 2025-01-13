import Alamofire

/// Протокол для проверки доступности сети
protocol ReachabilityProtocol {
    var isReachable: Bool { get }
}

extension NetworkReachabilityManager: ReachabilityProtocol {}
