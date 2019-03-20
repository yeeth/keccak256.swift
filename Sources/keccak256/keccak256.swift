import Foundation

public final class keccak256 {

    fileprivate let rounds = 24;

    static func hash(_ data: Data) -> Data {
        var d = data
        keccak(&d)
    }

}

extension keccak256 {

    private static func keccak(_ data: inout Data) {

        var b = [(UInt8, UInt8)](repeating: (0, 0), count: 5)

        stride(from: 0, through: 24, by: 1).forEach {
            _ in

            for i in (0..<5) {

            }

        }
    }

}