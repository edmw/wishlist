import Vapor

protocol SortingController {

    associatedtype Sorting: AnyEntitySorting

    func getSorting(on request: Request) -> Sorting?

}

extension SortingController where Self: Controller {

    func getSorting(on request: Request) -> Sorting? {
        guard let orderBy = request.query[.orderBy] else {
            return nil
        }
        if orderBy.hasPrefix("+") {
            return .ascending(propertyName: String(orderBy.dropFirst(1)))
        }
        else if orderBy.hasPrefix("-") {
            return .descending(propertyName: String(orderBy.dropFirst(1)))
        }
        else {
            return .ascending(propertyName: orderBy)
        }
    }

}

extension ControllerParameterKeys {
    static let orderBy = ControllerParameterKey<String>("orderBy")
}
