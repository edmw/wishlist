import Domain

import Vapor

extension EventLoopFuture {

    public func handleAuthorizationError(on request: Request)
        throws -> EventLoopFuture<Expectation>
    {
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
