import Vapor

extension Future {

    public func handleAuthorizationError(on request: Request) throws -> Future<Expectation> {
        return catchFlatMap(AuthorizationError.self) { error in
            request.logger?.application.debug("\(error)")
            switch error {
            case .authenticationRequired:
                throw Abort(.unauthorized)
            default:
                throw Abort(.forbidden)
            }
        }
    }

}
