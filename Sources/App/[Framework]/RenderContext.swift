import Vapor

class RenderContext<PageContext>: Encodable where PageContext: Encodable {

    var request: RenderParameter

    var page: PageContext?

    var site: Site

    var features: Features

    init(_ pageContext: PageContext?, site: Site, features: Features) {
        self.request = RenderParameter()

        self.page = pageContext

        self.site = site
        self.features = features
    }

}
