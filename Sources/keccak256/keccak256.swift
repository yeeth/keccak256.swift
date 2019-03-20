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
        UInt8(1), 3, 6, 10,
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
        var d = data

        // @todo https://github.com/uport-project/SwiftKeccak/blob/develop/SwiftKeccak/sha3tiny/keccak-tiny.c#L117

        keccak(&d)
        return d
    }

}

extension keccak256 {

    private static func fold(a: inout Data, i: inout Data, l: Int, rate: Int) {
        var L = l
        var I = i
        while (L >= rate) {
            setout(src: a, dst: &I, len: rate)
            keccak(&a)
            I += rate
            L -= rate
        }
    }

    private static func setout(src: Data, dst: inout Data, len: Int) {
        for i in (0..<len) {
            dst[i] = src[i]
        }
    }

    private static func keccak(_ data: inout Data) {
        var b = Data(repeating: 0, count: 5)

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

            data[0] = UInt8(UInt64(data[0]) ^ RC[i]);
        }
    }

    private static func rol(_ x: UInt8, _ s: UInt8) -> UInt8 {
        return (((x) << s) | ((x) >> (64 - s)))
    }

}
