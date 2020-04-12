import Html

extension Html.Node {

    enum AlertStyle: String {
        case warning = "warning"
        case success = "success"
        case failure = "danger"
        case info = "primary"
    }

    // Boostrap Alert
    static func alert(text: String, style: AlertStyle = .info, dismissible: Bool) -> Node {
        let divClass: String
        let button: Node
        if dismissible {
            divClass = "alert alert-\(style.rawValue) alert-dismissible fade show"
            button = Node
                .button(
                    attributes: [
                        .type(.button),
                        .class("close"),
                        .ariaLabel("Close"),
                        .data("dismiss", "alert")
                    ],
                    .span(
                        attributes: [
                            .ariaHidden(.true)
                        ],
                        .raw("&times;")
                    )
                )
        }
        else {
            divClass = "alert alert-\(style.rawValue)"
            button = Node()
        }
        return Node
            .div(
                attributes: [
                    .role(.alert),
                    .class(divClass)
                ],
                .raw(text),
                button
            )
    }

}
