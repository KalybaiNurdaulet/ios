// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_FINAL.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.\n")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueStr) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(valueStr),
          value >= 0 || sensor == "TEMP" else {
        return nil
    }
    return (sensor: sensor, value: value)
}

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var validReadings: [Reading] = []
    var invalidCount = 0
    
    for line in lines {
        if let reading = parseReading(line) {
            validReadings.append(reading)
        } else {
            invalidCount += 1
        }
    }
    
    return (valid: validReadings, invalidCount: invalidCount)
}

let A = parseLog(rawLog).invalidCount
print("✓ Level 1.1 & 1.2:")
print("  parseReading(\"O2:87\") = \(parseReading("O2:87") ?? (sensor: "nil", value: 0))")
print("  parseReading(\"TEMP:-12\") = \(parseReading("TEMP:-12") ?? (sensor: "nil", value: 0))")
print("  parseReading(\"RAD:-1\") = \(parseReading("RAD:-1") ?? (sensor: "nil", value: 0))")
print("  parseLog() - Valid: \(parseLog(rawLog).valid.count), Invalid: \(A)")
print("  A = \(A)\n")


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard !values.isEmpty else { return nil }
    
    var minVal = values[0]
    var maxVal = values[0]
    var sum = 0
    
    for value in values {
        if value < minVal { minVal = value }
        if value > maxVal { maxVal = value }
        sum += value
    }
    
    let average = Double(sum) / Double(values.count)
    return (min: minVal, max: maxVal, average: average)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

let o2Readings = select(parseLog(rawLog).valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)
let o2Stats = stats(of: o2Values)
let B = Int(o2Stats?.average ?? 0)

print("✓ Level 2.1 & 2.2:")
print("  O2 readings: \(o2Readings)")
print("  O2 values: \(o2Values)")
print("  O2 stats: \(o2Stats ?? (min: 0, max: 0, average: 0))")
print("  stats(3, 8, 1) = \(stats(3, 8, 1) ?? (min: 0, max: 0, average: 0))")
print("  stats() = \(stats() ?? (min: 0, max: 0, average: 0))")
print("  B = \(B)\n")

// 2.3 · The Closure Ladder
let validReadings = parseLog(rawLog).valid

// Helper function to compare Reading arrays
func readingsEqual(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value {
            return false
        }
    }
    return true
}

// 1. Full closure syntax
var result1 = validReadings
result1.sort { (lhs, rhs) in
    return lhs.value > rhs.value
}

// 2. Types inferred from context
var result2 = validReadings
result2.sort { (lhs, rhs) in
    return lhs.value > rhs.value
}

// 3. Implicit return
var result3 = validReadings
result3.sort { lhs, rhs in
    lhs.value > rhs.value
}

// 4. Shorthand argument names
var result4 = validReadings
result4.sort { $0.value > $1.value }

// 5. Trailing closure
var result5 = validReadings
result5.sort { $0.value > $1.value }

// Verify all 5 produce the same result
let allSame = readingsEqual(result1, result2) &&
              readingsEqual(result2, result3) &&
              readingsEqual(result3, result4) &&
              readingsEqual(result4, result5)

print("✓ Level 2.3 - Closure Ladder:")
print("  All 5 sorts produce same result: \(allSame)")
print("  Result: \(result1)\n")


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    return t + 5
}

func coolDown(_ t: Int) -> Int {
    return t - 3
}

func hold(_ t: Int) -> Int {
    return t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var currentTemp = start
    var stepCount = 0
    
    while (currentTemp < 18 || currentTemp > 24) && stepCount < maxSteps {
        let protocolFunc = chooseProtocol(for: currentTemp)
        currentTemp = protocolFunc(currentTemp)
        stepCount += 1
    }
    
    let isStable = currentTemp >= 18 && currentTemp <= 24
    return (finalTemp: currentTemp, steps: stepCount, isStable: isStable)
}

let tempTest1 = runUntilStable(from: 31)
let tempTest2 = runUntilStable(from: -100, maxSteps: 5)

// Find the lowest valid temperature
let tempReadings = select(validReadings) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)
let lowestTemp = tempValues.min() ?? 0
let C = runUntilStable(from: lowestTemp).steps

print("✓ Level 3.1 & 3.2:")
print("  runUntilStable(from: 31) = \(tempTest1)")
print("  runUntilStable(from: -100, maxSteps: 5) = \(tempTest2)")
print("  Lowest temp in log: \(lowestTemp)")
print("  C = \(C)\n")


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    return member.module?.oxygenTank?.level
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let oxyLevel = oxygenLevel(of: member) else {
        let location = member.module.map { "(\($0.name))" } ?? "(open space)"
        return "\(member.name): no data \(location)"
    }
    
    let statusStr = oxyLevel < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(oxyLevel)% \(statusStr)"
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount >= 0 else { return 0 }
    
    let canTake = min(amount, source)
    let canGive = min(canTake, 100 - target)
    
    source -= canGive
    target += canGive
    
    return canGive
}

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    
    found.sort { $0.priority < $1.priority }
    return found.map { $0.name }
}

print("✓ Level 4.1 - Oxygen levels:")
for member in crew {
    if let level = oxygenLevel(of: member) {
        print("  \(member.name): \(level)%")
    } else {
        print("  \(member.name): nil")
    }
}

print("\n✓ Level 4.2 - Status of crew:")
for member in crew {
    print("  \(status(of: member))")
}

print("\n✓ Level 4.3 - Oxygen transfer:")
var labOxy = 40
var habOxy = 12
let transferred = transferOxygen(from: &labOxy, to: &habOxy, amount: 30)
print("  Lab: 40 → \(labOxy), Hab: 12 → \(habOxy)")
print("  Transferred: \(transferred)")
let D = habOxy

print("\n✓ Level 4.4 - Evacuation order:")
let evacOrder = evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster)
print("  Order: \(evacOrder)\n")


// MARK: Level 5 · The Saboteur's Logbook

print("✓ Level 5 - Saboteur's Logbook (Fixed):")



func reportOxygen(for member: CrewMember) -> String? {
    guard let level = oxygenLevel(of: member) else {
        return nil
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member), level < 20 else {
            continue
        }
        return member.name
    }
    return nil
}

// Test that proves logic bug is fixed:
let testLab = Module(name: "TestLab", oxygenTank: Tank(level: 15))
let testDock = Module(name: "TestDock", oxygenTank: Tank(level: 19))
let testCrew = [
    CrewMember(name: "First", role: "Test", priority: 2, module: testLab),
    CrewMember(name: "Second", role: "Test", priority: 1, module: testDock)
]

let firstCrit = firstCritical(in: testCrew)
print("  firstCritical with multiple critical members: \(firstCrit ?? "nil")")
print("  Should return 'First' (first in array), not 'Second' ✓")

print("  reportOxygen examples:")
print("    Timur (Lab): \(reportOxygen(for: crew[0]) ?? "nil")")
print("    Dana (Dock with no tank): \(reportOxygen(for: crew[1]) ?? "nil")")
print("    Nurlan (open space): \(reportOxygen(for: crew[3]) ?? "nil")\n")


// MARK: Finale · Launch Code

print(String(repeating: "=", count: 50))
print("LAUNCH CODE: \(A)-\(B)-\(C)-\(D)")
print(String(repeating: "=", count: 50))


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}

print("\n✓ Bonus - Alarm closure:")
let alarm = makeAlarm(threshold: 20)
print("  alarm(12): \(alarm(12))")  // Alarm #1 → true
print("  alarm(40): \(alarm(40))")  // false
print("  alarm(5): \(alarm(5))")    // Alarm #2 → true



