import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Glucocalc — Glucose/HbA1c Calculator").font(.headline)
                    Text("Version 1.0")
                    Text("(c) 2018-2026 jocala")
                    Link("jocala@jocala.com", destination: URL(string: "mailto:jocala@jocala.com")!)
                    Link("https://www.jocala.com",
                         destination: URL(string: "https://www.jocala.com")!)

                    helpSection("Usage") {
                        Text("Glucocalc calculates estimated HbA1c and estimated average blood glucose. It accepts numeric entries via a single input field. The calculations performed vary based on the state of the checkbox/radiobuttons described below.")
                        Text("UK (IFCC) checkbox: Causes Glucocalc to input/output values in mmol/L and mmol/mol.")
                        Text("Calculate eAG radiobutton: Calculate eAG from input HbA1c value. The result will be mg/dl or mmol/L depending on the state of the UK (IFCC) checkbox.")
                        Text("Calculate HbA1c radiobutton: Calculate HbA1c from input eAG value. The result will be in percent or mmol/mol depending on the position of the UK (IFCC) checkbox.")
                    }

                    helpSection("Terminology") {
                        Text("NGSP: National Glycohemoglobin Standardization Program")
                        Text("IFCC: The International Federation of Clinical Chemistry and Laboratory Medicine")
                        Text("mg/dl: milligrams per deciliter (weight)")
                        Text("mmol/L: millimoles per litre (volume)")
                        Text("eAG: estimated average glucose")
                        Text("ADAG: A1c-derived average glucose")
                        Text("HbA1c: % Glycated hemoglobin (NGSP)")
                        Text("HbA1c: mmol/mol Glycated hemoglobin (IFCC)")
                    }

                    helpSection("Formulas") {
                        Text("This software uses the 2008 ADAG Study Group formulas")
                        Text("Compute eAG: (28.7 × A1c) – 46.7")
                        Text("Compute A1c: (eAG + 46.7) / 28.7")
                        Text("mg/dl to mmol/L: mg/dl / 18")
                        Text("mmol/L to mg/dl: mmol/L × 18")
                        Text("NGSP = (0.09148 × IFCC) + 2.152")
                        Text("IFCC = (10.93 × NGSP) - 23.50 (mmol/mol)")
                    }

                    helpSection("About HbA1c") {
                        Text("Glycated hemoglobin (hemoglobin A1c) is a form of hemoglobin that is measured primarily to identify the average plasma glucose concentration over prolonged periods of time.")
                        Text("A high A1c represents poor glucose control.")
                        Text("However, a good HbA1c still hides a history of recent hypoglycemia, or even spikes of hyperglycemia.")
                        Text("Regular blood glucose monitoring is still the best method for the analysis of overall vascular health with respect to blood sugar control.")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Help")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func helpSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .underline()
            content()
        }
    }
}

#Preview {
    HelpView()
}
