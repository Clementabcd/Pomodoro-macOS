import SwiftUI

struct TimeStepper: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let color: Color
    let format: TimeFormat

    @State private var editing = false
    @State private var editText = ""
    @FocusState private var isFocused: Bool

    enum TimeFormat {
        case minutes, seconds

        var multiplier: Double {
            switch self {
            case .minutes: 60
            case .seconds: 1
            }
        }

        func displayValue(_ total: Double) -> Int {
            switch self {
            case .minutes: Int(total / 60)
            case .seconds: Int(total)
            }
        }

        var suffix: String {
            switch self {
            case .minutes: loc("min")
            case .seconds: loc("sec")
            }
        }

        func fromDisplay(_ val: Int) -> Double {
            switch self {
            case .minutes: Double(val) * 60
            case .seconds: Double(val)
            }
        }
    }

    private var rangeSec: ClosedRange<Double> {
        (range.lowerBound * format.multiplier)...(range.upperBound * format.multiplier)
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Color.warmGray)

            Spacer()

            HStack(spacing: 0) {
                Button(action: decrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.warmGray)
                        .frame(width: 24, height: 24)
                        .background {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(color.opacity(0.08))
                        }
                }
                .buttonStyle(.plain)
                .help(loc("Decrease"))

                if editing {
                    TextField("", text: $editText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.warmWhite)
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .focused($isFocused)
                        .onSubmit(commitEdit)
                        .onAppear {
                            editText = "\(format.displayValue(value))"
                            isFocused = true
                        }
                } else {
                    Text("\(format.displayValue(value))")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(Color.warmWhite)
                        .frame(width: 50)
                        .contentTransition(.numericText())
                        .onTapGesture {
                            editText = "\(format.displayValue(value))"
                            withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 100, damping: 12)) {
                                editing = true
                            }
                        }
                }

                Text(format.suffix)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(Color.warmGray.opacity(0.5))
                    .frame(width: 24, alignment: .leading)

                Button(action: increment) {
                    Image(systemName: "plus")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color.warmGray)
                        .frame(width: 24, height: 24)
                        .background {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(color.opacity(0.08))
                        }
                }
                .buttonStyle(.plain)
                .help(loc("Increase"))
            }
        }
        .padding(.vertical, 2)
    }

    private func increment() {
        withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 120, damping: 14)) {
            value = min(rangeSec.upperBound, value + step)
        }
    }

    private func decrement() {
        withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 120, damping: 14)) {
            value = max(rangeSec.lowerBound, value - step)
        }
    }

    private func commitEdit() {
        if let val = Int(editText) {
            let minVal = Int(range.lowerBound)
            let maxVal = Int(range.upperBound)
            let clamped = max(minVal, min(val, maxVal))
            withAnimation {
                value = format.fromDisplay(clamped)
            }
        }
        withAnimation(.interpolatingSpring(mass: 0.6, stiffness: 100, damping: 12)) {
            editing = false
        }
    }
}
