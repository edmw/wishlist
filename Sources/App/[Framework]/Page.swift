// MARK: Page

struct Page {

    let template: PageTemplate
    let context: PageContext

    init(templateName: String, context: PageContext) {
        self.template = PageTemplate(name: templateName, isLocalized: false)
        self.context = context
    }

    init(localizedTemplateName: String, context: PageContext) {
        self.template = PageTemplate(name: localizedTemplateName, isLocalized: true)
        self.context = context
    }

}
