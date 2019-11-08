import Vapor

final class ImageProxyService: ServiceType {

    static var serviceSupports: [Any.Type] {
        return [ImageProxyService.self]
    }

    static func makeService(for container: Container) throws
        -> ImageProxyService
    {
        let token = try Environment.require(.cloudImageToken)
        return .init(token: token)
    }

    private let token: String

    init(token: String) {
        self.token = token
    }

    func get(url: URL, width: Int, height: Int, on request: Request) throws
        -> EventLoopFuture<Response>
    {
        let url = "https://\(token).cloudimg.io/" +
            "crop/\(width)x\(height)/" +
        "x/\(url.absoluteString)"

        return try request.client()
            .get(url) { request in
                request.http.headers.add(name: .userAgent, value: "Swift/Vapor")
                request.http.headers.add(name: .accept, value: "image/jpeg")
            }
    }

}

extension Container {

    func imageProxy() throws -> ImageProxyService {
        return try make()
    }

}

extension EnvironmentKeys {
    static let cloudImageToken = EnvironmentKey<String>("CLOUDIMG_TOKEN")
}
