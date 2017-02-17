import Foundation
import Kitura
import KituraNet
import SwiftyJSON
import LoggerAPI
import Configuration

import CloudFoundryConfig

import SwiftMetrics
import SwiftMetricsDash

import CouchDB

public let router = Router()
public let manager = ConfigurationManager()
public var port: Int = 8080


// Setting up cloudant
internal var database: Database?


public func initialize() throws {

    try manager.load(file: "../../config.json")
                .load(.environmentVariables)
    // Set up monitoring
    let sm = try SwiftMetrics()
    let _ = try SwiftMetricsDash(swiftMetricsInstance : sm, endpoint: router)


    // Configuring cloudant
    do {
    let cloudantService = try manager.getCloudantService(name: "applicationDB")
    let dbClient = CouchDBClient(service: cloudantService)
    } catch {
        print(error)
    }

    router.all("/", middleware: StaticFileServer())

    port = manager["port"] as? Int ?? port

    router.all("/*", middleware: BodyParser())

    initializeIndex()
}

public func run() throws {
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()
}
