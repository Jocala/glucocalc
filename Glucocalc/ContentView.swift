import SwiftUI

// MARK: - Platform-adaptive colors

#if os(iOS)
private let pageBackground = Color(.systemBackground)
private let cardBackground = Color(.secondarySystemBackground)
private let digitKeyFill = Color(.secondarySystemFill)
private let utilityKeyFill = Color(.tertiarySystemFill)
#else
private let pageBackground = Color(nsColor: .windowBackgroundColor)
private let cardBackground = Color(nsColor: .underPageBackgroundColor)
private let digitKeyFill = Color(nsColor: .controlBackgroundColor)
private let utilityKeyFill = Color(nsColor: .underPageBackgroundColor)
#endif

struct ContentView: View {
    @State private var mode: GlucocalcMode = .a1c
    @State private var mmol = false
    @State private var input = ""
    @State private var result1 = ""
    @State private var result2 = ""
    @State private var showHelp = false
    @State private var invalid = false
    /// True after "=" was pressed; the next digit starts a fresh entry.
    @State private var didCompute = false

    private var prompt: String {
        switch mode {
        case .eAG:
            return mmol ? "Enter HbA1c below (mmol/mol)" : "Enter HbA1c below (%)"
        case .a1c:
            return mmol ? "Enter eAG below (mmol/L)" : "Enter eAG below (mg/dl)"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                display
                modePicker
                optionsRow
                keypad
            }
            .padding()
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Glucocalc")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    helpButton
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    helpButton
                }
                #endif
            }
            .alert("Invalid input!", isPresented: $invalid) {
                Button("OK", role: .cancel) {}
            }
            .sheet(isPresented: $showHelp) { HelpView() }
        }
    }

    // MARK: - Display

    private var helpButton: some View {
        Button {
            showHelp = true
        } label: {
            Label("Help", systemImage: "questionmark.circle")
        }
    }

    private var display: some View {
        VStack(spacing: 10) {
            displayRow(label: prompt, value: input.isEmpty ? "0" : input,
                       valueSize: 34, valueWeight: .bold)
            Spacer()
                .frame(height: 8)
                .background(pageBackground)
            displayRow(label: resultLabel1, value: result1.isEmpty ? "0" : result1)
            displayRow(label: resultLabel2, value: result2.isEmpty ? "0" : result2)
        }
        .padding(16)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 16))
    }

    /// One label/value row: label left, value right-aligned in the shared column.
    private func displayRow(label: String, value: String,
                            valueSize: CGFloat = 20, valueWeight: Font.Weight = .medium) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            Text(value)
                .font(.system(size: valueSize, weight: valueWeight))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                #if os(iOS)
                .contentTransition(.numericText())
                #endif
        }
    }

    /// Output label for the first result slot (units in the label).
    private var resultLabel1: String {
        switch mode {
        case .eAG: return "Calculated eAG (mg/dl)"
        case .a1c: return "NGSP HbA1c (%)"
        }
    }

    /// Output label for the second result slot (units in the label).
    private var resultLabel2: String {
        switch mode {
        case .eAG: return "Calculated eAG (mmol/L)"
        case .a1c: return "IFCC HbA1c (mmol/mol)"
        }
    }

    // MARK: - Controls

    private var modePicker: some View {
        Picker("Calculation", selection: $mode) {
            ForEach(GlucocalcMode.allCases) { m in
                Text(m.rawValue).tag(m)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: mode) { _, _ in
            clearResults()
        }
    }

    private var optionsRow: some View {
        HStack {
            Toggle("UK (IFCC)", isOn: $mmol)
                .tint(.accentColor)
                .onChange(of: mmol) { oldValue, newValue in
                    toggleUnits(from: oldValue, to: newValue)
                }
            Spacer()
        }
    }

    // MARK: - Keypad

    private var keypad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            key("7") { pressDigit("7") }
            key("8") { pressDigit("8") }
            key("9") { pressDigit("9") }
            key("C", utility: true) { clear() }

            key("4") { pressDigit("4") }
            key("5") { pressDigit("5") }
            key("6") { pressDigit("6") }
            key("⌫", systemImage: "delete.backward", utility: true) { backspace() }

            key("1") { pressDigit("1") }
            key("2") { pressDigit("2") }
            key("3") { pressDigit("3") }
            key("=", accent: true) { calculate() }

            // Two intentionally empty cells (bottom-right) — no buttons.
            key("0") { pressDigit("0") }
            key(".") { pressDot() }
            Color.clear
                .frame(maxWidth: .infinity)
            Color.clear
                .frame(maxWidth: .infinity)
        }
    }

    private func key(_ label: String,
                     systemImage: String? = nil,
                     utility: Bool = false,
                     accent: Bool = false,
                     action: @escaping () -> Void) -> some View {
        KeypadKey(label: label, systemImage: systemImage,
                  utility: utility, accent: accent, action: action)
    }

    // MARK: - Input handling

    private func pressDigit(_ d: String) {
        if didCompute {
            clear()
            didCompute = false
        }
        if input == "0" {
            input = d
            return
        }
        if input.contains(".") {
            // Qt validator: max 2 decimal places
            let fraction = input.split(separator: ".").last?.count ?? 0
            guard fraction < 2 else { return }
        } else {
            // Qt validator: max 999.99
            guard input.count < 3 else { return }
        }
        input += d
    }

    private func pressDot() {
        if didCompute {
            clear()
            didCompute = false
        }
        if input.isEmpty {
            input = "0."
            return
        }
        if input.contains(".") { return }
        input += "."
    }

    private func backspace() {
        if !input.isEmpty { input.removeLast() }
    }

    private func clear() {
        input = ""
        clearResults()
    }

    private func clearResults() {
        result1 = ""
        result2 = ""
        didCompute = false
    }

    private func calculate() {
        guard let value = Double(input), value > 0 else {
            invalid = true
            return
        }
        didCompute = true
        computeResults(from: value)
    }

    /// US <-> UK toggle: convert the current input to the other unit system and
    /// recompute the results so input and output stay consistent. Results always
    /// show both units, so only the input value needs converting.
    private func toggleUnits(from old: Bool, to new: Bool) {
        guard old != new else { return }
        guard let value = Double(input), value > 0 else {
            clearResults()
            return
        }
        let converted: Double
        switch mode {
        case .a1c:   // input is eAG: mg/dl <-> mmol/L
            converted = new ? value / 18 : value * 18
        case .eAG:   // input is HbA1c: % <-> mmol/mol
            converted = new ? (value * 10.93) - 23.5 : (value * 0.09148) + 2.152
        }
        input = String(format: "%.2f", converted)
        if didCompute {
            computeResults(from: converted)
        }
    }

    private func computeResults(from value: Double) {
        switch mode {
        case .eAG:
            let r = GlucocalcMath.eAG(fromA1c: value, mmol: mmol)
            result1 = String(format: "%.2f", r.mgdl)
            result2 = String(format: "%.2f", r.mmolL)
        case .a1c:
            let r = GlucocalcMath.a1c(fromEAG: value, mmol: mmol)
            result1 = String(format: "%.2f", r.ngsp)
            result2 = String(format: "%.2f", r.ifcc)
        }
    }
}

/// A single calculator-style key: rounded rect, system fill colors, SF Symbol or text label.
private struct KeypadKey: View {
    let label: String
    var systemImage: String?
    var utility = false
    var accent = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Image(systemName: systemImage)
                } else {
                    Text(label)
                }
            }
            .font(.title2.weight(.medium))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(background)
            }
            .foregroundStyle(foreground)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var background: Color {
        if accent { return Color.accentColor }
        if utility { return utilityKeyFill }
        return digitKeyFill
    }

    private var foreground: Color {
        accent ? .white : .primary
    }

    private var accessibilityLabel: String {
        if systemImage == "delete.backward" { return "Delete" }
        switch label {
        case ".": return "Decimal point"
        case "C": return "Clear"
        case "=": return "Equals"
        default: return label
        }
    }
}

#Preview {
    ContentView()
}
