import Vapor

struct DispatchingProvider: Provider {

    let service: DispatchingService

    init() {
        service = DispatchingService()
    }

    func register(_ services: inout Services) throws {
        services.register(service, as: DispatchingService.self)
    }

    func didBoot(_ container: Container) throws -> Future<Void> {
        try service.attach(to: container, logger: container.make())

        try service.scheduleDNA()

        return .done(on: container)
    }

}
