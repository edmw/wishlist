import Foundation

extension URLComponents {

    var queryDictionary: [String: String?] {
        var params = [String: String?]()
        queryItems?.forEach { item in
            params[item.name] = item.value
        }
        return params
    }

    mutating func appendQueryItem(_ extraItem: URLQueryItem) {
        var items = queryItems ?? []
        items.append(extraItem)
        queryItems = items
    }

    mutating func appendQueryItem(name: String, value: String) {
        appendQueryItem(URLQueryItem(name: name, value: value))
    }

    mutating func appendQueryItems(_ extraItems: [URLQueryItem]) {
        var items = queryItems ?? []
        items += extraItems
        queryItems = items
    }

    mutating func appendQueryItems(_ extraItems: [String: String]) {
        appendQueryItems(extraItems.map { key, value in URLQueryItem(name: key, value: value) })
    }
}
