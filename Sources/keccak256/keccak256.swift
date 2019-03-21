import Foundation

public final class keccak256 {

    fileprivate static let pi = [
        10, 7, 11, 17,
        18, 3, 5, 16,
        8, 21, 24, 4,
        15, 23, 19, 13,
        12, 2, 20, 14,
        22, 9, 6, 1
    ]

    fileprivate static let rho = [
        UInt64(1), 3, 6, 10,
        15, 21, 28, 36,
        45, 55,  2, 14,
        27, 41, 56,  8,
        25, 43, 62, 18,
        39, 61, 20, 44
    ]

    fileprivate static let RC = [
        UInt64(1), 0x8082, 0x800000000000808a, 0x8000000080008000,
        0x808b, 0x80000001, 0x8000000080008081, 0x8000000000008009,
        0x8a, 0x88, 0x80008009, 0x8000000a,
        0x8000808b, 0x800000000000008b, 0x8000000000008089, 0x8000000000008003,
        0x8000000000008002, 0x8000000000000080, 0x800a, 0x800000008000000a,
        0x8000000080008081, 0x8000000000008080, 0x80000001, 0x8000000080008008
    ]

    static func hash(_ data: Data) -> Data {
        var output = Data(repeating: 0, count: 32)

        var a = Data(repeating: 0, count: 200)
        let rate = 200 - (256 / 4)

        fold(a: &a, i: data, rate: rate, operation: xorin)

        a[data.count] ^= 0x1f
        a[rate - 1] ^= 0x80;

        xorin(&a, data);
        keccak(a)

        // @todo squeeze output


        // @todo https://github.com/coruus/keccak-tiny/blob/singlefile/keccak-tiny.c#L117

        return output
    }

}

extension keccak256 {

    private static func keccak(_ input: Data) -> Data {
        var b = [UInt64](repeating: 0, count: 5)

        let count = input.count / 8
        var data: [UInt64] = (0..<count).map {
            let offset = $0 * 8
            return UInt64(bigEndian: input.subdata(in: (offset..<offset+8)).withUnsafeBytes { $0.pointee })
        }

        stride(from: 0, through: 24, by: 1).forEach {
            i in

            // Theta
            for x in 0..<5 {
                for y in stride(from: 0, through: (5 * 5), by: 5) {
                    b[x] = b[x] ^ data[x + y]
                }
            }

            for x in 0..<5 {
                for y in stride(from: 0, through: (5 * 5), by: 5) {
                    data[x + y] = data[x + y] ^ (b[(x + 4) % 5] ^ rol(b[(x + 1) % 5], 1))
                }
            }

            // Rho & Phi
            var t = data[1]
            for x in 0..<24 {
                b[0] = data[pi[x]]
                data[pi[x]] = rol(t, rho[x])
                t = b[0]
            }

            // Chi
            for y in stride(from: 0, through: (5 * 5), by: 5) {
                for x in 0..<5 {
                    b[x] = data[x + y]
                }

                for x in 0..<5 {
                    data[x + y] = b[x] ^ ((~b[(x + 1) % 5]) & b[(x + 2) % 5])
                }
            }

            // @todo this is bad and will overflow in any scenario. We need to change data to a uint64 array and then convert on finalization
            data[0] = data[0] ^ RC[i];
        }

        return data.withUnsafeBufferPointer { Data(buffer: $0) }
    }

    private static func rol(_ x: UInt64, _ s: UInt64) -> UInt64 {
        return (((x) << s) | ((x) >> (64 - s)))
    }

}

extension keccak256 {

    // need better name
    private typealias Operation = (inout Data, Data) -> Void

    private static func fold(a: inout Data, i: Data, rate: Int, operation: Operation) {
        var length = i.count
        var offset = 0
        while (length >= rate) {
            operation(&a, Data(bytes: i[offset...(offset+rate)]))
            a = keccak(a)
            offset += rate
            length -= rate
        }
    }

    private static func setout(_ dst: inout Data, _ src: Data) {
        dst.replaceSubrange(0..<src.count, with: src)
    }

    private static func xorin(_ dst: inout Data, _ src: Data) {
        dst = dst ^ src
    }
}
