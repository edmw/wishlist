import Html

extension Html.Node {

    static func spanMessage(message: String, label: String) -> Node {
        return Node
            .span(
                attributes: [.class("tag-message text-info")],
                    .text("\(label): \(message)")
            )
    }

    static func spanError(message: String, label: String) -> Node {
        return Node
            .span(
                attributes: [.class("tag-error text-danger")],
                    .text("\(label): \(message)")
            )
    }

    static func aButton(action: String, title: String, icon name: String) -> Node {
        return Node
            .a(
                attributes: [
                    .href(action),
                    .title(title),
                    .class("btn btn-action")
                ],
                .feather(icon: name)
            )
    }

    static func feather(icon name: String) -> Node {
        return Node
            .svg(
                attributes: [
                    .class("feather")
                ],
                unsafe: #"<use xlink:href="/icons/feather.svg#\#(name)"/>"#
            )
    }

}
