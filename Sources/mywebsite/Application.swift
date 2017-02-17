import Foundation
import Kitura
import KituraNet
import SwiftyJSON
import LoggerAPI
import Configuration

import CloudFoundryConfig

import SwiftMetrics
import SwiftMetricsDash
import SwiftMetricsBluemix

import CouchDB

public let router = Router()
public let manager = ConfigurationManager()
public var port: Int = 8080


// Setting up cloudant
internal var database: Database?


public func initialize() throws {

    do {
    try manager.load(file: "../../config.json")
                .load(.environmentVariables)
    } catch {
        print("load error")
    }
    // Set up monitoring
    let sm = try SwiftMetrics()
    let _ = try SwiftMetricsDash(swiftMetricsInstance : sm, endpoint: router)
    let _ = AutoScalar(swiftMetricsInstance: sm)


    // Configuring cloudant
    let cloudantService = try manager.getCloudantService(name: "applicationDB")
    let dbClient = CouchDBClient(service: cloudantService)

    router.all("/", middleware: StaticFileServer())

    port = manager["port"] as? Int ?? port

    router.all("/*", middleware: BodyParser())

    initializeIndex()
}

public func run() throws {
    Kitura.addHTTPServer(onPort: port, with: router)
    Kitura.run()
}
