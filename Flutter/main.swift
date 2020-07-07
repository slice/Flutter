//
//  main.swift
//  Flutter
//

import ArgumentParser
import Network

struct Options: ParsableArguments {
    @Option(name: .shortAndLong, help: "The server hostname to connect to.")
    var endpoint: String

    @Option(name: .shortAndLong, help: "The server port to connect to.")
    var port: UInt16

    @Option(name: .shortAndLong, help: "The width of the canvas.")
    var width: Int = 150

    @Option(name: .shortAndLong, help: "The height of the canvas.")
    var height: Int = 100
}

struct Flutter: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A client for Pixelflut.",
        subcommands: [DrawImage.self]
    )

    struct DrawImage: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Draws an image."
        )

        @Argument(help: "The image to send.")
        var imagePath: String = ""

        @OptionGroup()
        var options: Options

        mutating func run() {
            let host: NWEndpoint.Host = .init(options.endpoint)
            let port: NWEndpoint.Port = .init(integerLiteral: options.port)

            let client = FlutterClient(host: host, port: port, size: (options.width, options.height))
            client.start()
            client.send(imageAtPath: imagePath)
        }
    }
}

Flutter.main()
