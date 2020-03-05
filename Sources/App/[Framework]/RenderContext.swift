import Vapor

class RenderContext: Encodable {

    var request: RenderParameter

    var page: AnyPageContext?

    var site: Site

    var features: Features

    init(_ pageContext: AnyPageContext?, site: Site, features: Features) {
        self.request = RenderParameter()

        self.page = pageContext

        self.site = site
        self.features = features
    }

}
