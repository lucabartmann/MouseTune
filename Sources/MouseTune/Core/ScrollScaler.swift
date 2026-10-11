/// Scales integer wheel deltas by a fractional factor without losing sub-step remainders,
/// so slow factors (< 1×) still deliver every notch eventually.
struct ScrollScaler {
    private var residual = [[Double]](repeating: [0, 0], count: 2)

    /// - Parameters:
    ///   - axis: 0 = vertical, 1 = horizontal
    ///   - channel: 0 = lines, 1 = points
    mutating func scale(_ value: Double, axis: Int, channel: Int, factor: Double) -> Double {
        let sum = value * factor + residual[axis][channel]
        let out = sum.rounded(.towardZero)
        residual[axis][channel] = sum - out
        return out
    }
}
