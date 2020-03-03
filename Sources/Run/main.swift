import App
import Service
import Vapor

import Foundation

import Backtrace

do {
    Backtrace.install()

    // update shell environment from dotenv file
    Environment.dotenv()

    // detect vapor environment from command line
    var environment = try Environment.detect()

    var config = Config.default()
    var services = Services.default()

    try App.configure(&config, &environment, &services)

    let app = try Application(
        config: config,
        environment: environment,
        services: services
    )

    try App.boot(app)

    try app.run()

}
catch {
    print(error)
    exit(1)
}
