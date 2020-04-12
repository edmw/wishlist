import Html

extension Html.Node {

    enum IconType: String {
        case alert = "alert-triangle"
        case thumbsUp = "thumbs-up"
        case thumbsDown = "thumbs-down"
    }

    enum IconStyle: String {
        case warning = "warning"
        case success = "success"
        case failure = "danger"
        case info = "primary"
    }

    // Bootstrap Icon
    static func icon(title: String, type: IconType, style: IconStyle = .info) -> Node {
        return Node
            .span(
                attributes: [
                    .title(title),
                    .class("badge badge-pill badge-\(style.rawValue)")
                ],
                .feather(icon: type.rawValue)
            )
    }

}
