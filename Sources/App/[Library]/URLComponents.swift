import Foundation

extension URLComponents {

    var queryDictionary: [String: String?] {
        var params = [String: String?]()
        queryItems?.forEach { item in
            params[item.name] = item.value
        }
        return params
    }

    mutating func appendQueryItem(_ item: URLQueryItem) {
        var items = queryItems ?? []
        items.append(item)
        queryItems = items
    }

}
