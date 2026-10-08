//
//  Extensions+HKUnit.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

extension HKUnit {
    /// Unit string grammar documented in **HKUnit.h**: prefixed SI units, non-SI units,
    /// integral powers (^), multiplication (. * ·), a single division (/) and grouping parentheses
    private static let grammar: NSRegularExpression? = {
        let prefix = "(?:da|mc|[dhckmMGTnpf])"
        let siUnit = "(?:g|m|L|l|Pa|s|J|K|S|Hz|V|W|rad|lx|mol<[0-9]+(?:\\.[0-9]+)?>)"
        let nonSIUnit = [
            "oz", "lb", "st", "in", "ft", "yd", "mi",
            "mmHg", "cmAq", "atm", "dBASPL", "inHg",
            "fl_oz_us", "fl_oz_imp", "pt_us", "pt_imp", "cup_us", "cup_imp",
            "min", "hr", "d", "cal", "kcal", "Cal", "degC", "degF",
            "IU", "count", "%", "dBHL", "D", "pD", "deg", "appleEffortScore"
        ].joined(separator: "|")
        let factor = "(?:\(prefix)?\(siUnit)|\(nonSIUnit))(?:\\^-?[0-9]+)?"
        let factors = "\(factor)(?:[.*·]\(factor))*"
        let product = "(?:\\(\(factors)\\)|\(factors))"
        return try? NSRegularExpression(pattern: "^\(product)(?:/\(product))?$")
    }()

    /// Parses the unit string. HealthKit raises an uncatchable **NSException** on a malformed string,
    /// so the string is checked against the documented grammar first.
    static func parsed(from unitString: String) throws -> HKUnit {
        let range = NSRange(unitString.startIndex..., in: unitString)
        guard
            let grammar = grammar,
            grammar.firstMatch(in: unitString, range: range) != nil
        else {
            throw HealthKitError.invalidValue("Invalid unit: \(unitString)")
        }
        return HKUnit(from: unitString)
    }
}
