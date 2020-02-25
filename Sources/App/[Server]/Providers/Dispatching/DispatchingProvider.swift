import Vapor

struct DispatchingProvider: Provider {

    let service: DispatchingService

    init() {
        service = DispatchingService()
    }

    func register(_ services: inout Services) throws {
        services.register(service, as: DispatchingService.self)
    }

    func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }

}
