import Foundation

enum GlucocalcMode: String, CaseIterable, Identifiable {
    case eAG = "Calculate eAG"
    case a1c = "Calculate HbA1c"

    var id: String { rawValue }
}

enum GlucocalcMath {

    // eAG from input HbA1c. mmol: input is IFCC mmol/mol, else NGSP %.
    static func eAG(fromA1c a1cInput: Double, mmol: Bool) -> (mgdl: Double, mmolL: Double) {
        var a1c = a1cInput
        if mmol {
            a1c = (0.09148 * a1c) + 2.152
        }
        let eagMgdl = (28.7 * a1c) - 46.7
        return (eagMgdl, eagMgdl / 18)
    }

    // HbA1c from input eAG. mmol: input is mmol/L, else mg/dl.
    static func a1c(fromEAG eagInput: Double, mmol: Bool) -> (ngsp: Double, ifcc: Double) {
        var eag = eagInput
        if mmol {
            eag = eag * 18
        }
        let ngsp = (eag + 46.7) / 28.7
        return (ngsp, (10.93 * ngsp) - 23.50)
    }
}
