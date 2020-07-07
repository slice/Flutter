//
//  Flutter.swift
//  Flutter
//

import Cocoa
import Network
import SwiftImage

class FlutterClient {
    static let queue = DispatchQueue(label: "Flutter")
    var size: (Int, Int)
    var connection: NWConnection!

    init(host: NWEndpoint.Host, port: NWEndpoint.Port, size: (Int, Int)) {
        self.size = size
        connection = NWConnection(host: host, port: port, using: .tcp)
    }

    func send(imageAtPath path: String) {
        let nsImage = NSImage(byReferencingFile: path)!
        let image = Image<RGB<UInt8>>(nsImage: nsImage)
        send(image: image)
    }

    func send(image: Image<RGB<UInt8>>) {
        let group = DispatchGroup()
        let (width, height) = size
        let resizedImage = image.resizedTo(width: width, height: height)

        for (n, pixel) in resizedImage.enumerated() {
            let x = n % width
            let y = n / width

            var hex = pixel.description
            let index = hex.index(hex.startIndex, offsetBy: 1)..<hex.endIndex
            hex = String(hex[index])

            group.enter()
            send(command: "PX \(x) \(y) \(hex)") { _ in
                group.leave()
            }
        }

        group.wait()
    }

    func send(command: String, onComplete completionHandler: ((NWError?) -> Void)? = nil) {
        let terminatedCommand = command + "\n"
        let completion: NWConnection.SendCompletion = completionHandler == nil ? .idempotent : .contentProcessed(completionHandler!)
        connection.send(
            content: terminatedCommand.data(using: .utf8),
            completion: completion
        )
    }

    func draw(at: (Int, Int), color: String) {
        let (x, y) = at
        send(command: "PX \(x) \(y) \(color)")
    }

    func start() {
        connection.start(queue: FlutterClient.queue)
    }
}
