// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> The cell is shared mutable state: a drone
// keeps it in a `let` and still has to change its charge, and everyone who holds
// the cell must see the same charge, so it needs reference semantics.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        if charge < 0 {
            self.charge = 0
        } else if charge > 100 {
            self.charge = 100
        } else {
            self.charge = charge
        }
    }

    func level() -> Int {
        return charge
    }

    func spend(_ amount: Int) -> Bool {
        if amount <= 0 || amount > charge {
            return false
        }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        if amount <= 0 { return }
        charge += amount
        if charge > 100 { charge = 100 }
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// let cell = PowerCell(charge: 50)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> No subclass can rewrite the
// ritual, so every drone always pays its power cost before it produces any work.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        return "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        return "\(id) welds a hull seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }

    override var statusLine: String {
        return super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("WARNING: skipped record \(record.id), unknown kind \"\(record.kind)\"")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    var round = 0
    while round < rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
        round += 1
    }
    return total
}

let A = runShift(fleet, rounds: 3)

var chargeSum = 0
var readyCount = 0
print("--- AFTER SHIFT ---")
for drone in fleet {
    print(drone.statusLine)
    chargeSum += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        readyCount += 1
    }
}

let B = chargeSum
let C = readyCount
print("Work units: \(A), drones ready for one more task: \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  -> `mutating` is only
// for value types, where changing a property changes the value itself. A class is
// a reference type: the method changes the object behind the reference, never
// `self`, so the keyword is not needed (and not allowed).
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int

    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        if amount <= 0 { return }
        chargeLevel += amount
        if chargeLevel > 100 { chargeLevel = 100 }
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
}

// 4.3
// Why could [Drone] never have held the sensors?  -> SensorModule is a struct, and a
// struct cannot inherit from a class, so a sensor can never be a Drone; only a
// protocol can be the common type of a class and a struct.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "--- DIAGNOSTICS (\(components.count) components) ---"
    for component in components {
        report += "\n" + component.diagnose()
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }

    // The Health Rule. The only place in the file with these thresholds.
    func healthCode(for level: Int) -> Int {
        if level < 20 { return 2 }   // critical
        if level < 50 { return 1 }   // warning
        return 0                     // nominal
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(for: signalStrength) }

    func diagnose() -> String {
        return "[LEGACY HARDWARE] \(name): signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print(diagnosticsReport(components))

var codeSum = 0
for component in components {
    codeSum += component.statusCode
}
let D = codeSum

// 5.3
extension Int {
    var powerBar: String {
        var filled = self / 10
        if filled < 0 { filled = 0 }
        if filled > 10 { filled = 10 }
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }
}


// MARK: Level 6 · Incident Reports
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

 Expected: a new drone type that produces 30 work units per task.
 Actual:   does not build. error: overriding declaration requires an 'override' keyword
 Rule:     a method with the same signature as a superclass method is an override,
           and Swift makes you say so explicitly, so you can never replace (or
           fail to replace) inherited behaviour by accident.
 Fix:      override func performTask() -> Int { return 30 }


// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

 Expected: a stronger welder that skips the ritual and always returns 999.
 Actual:   does not build, two errors:
             inheritance from a final class 'WelderDrone'
             instance method overrides a 'final' instance method
 Rule:     a final class cannot be subclassed and a final method cannot be overridden.
 Fix:      inherit from Drone and change only what is allowed to change:
             final class HeavyWelder: Drone {
                 override var powerCost: Int { 40 }
                 override func performTask() -> Int { 80 }
             }


// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

 Expected: the object really is a WelderDrone, so weldSeam() should be callable.
 Actual:   does not build. error: value of type 'Drone' has no member 'weldSeam'
 Rule:     the compiler checks members against the static type of the variable
           (Drone), not against the object that happens to be inside at runtime.
 Fix:      a conditional cast (it runs for real right below this comment).
           `as?` returns an optional because the cast is checked at runtime and
           can fail: the Drone might be a scanner or a cargo drone, and then
           the result is nil.


// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())

 Expected: "thruster T-1".
 Actual:   compiles and prints "generic component".
 Rule:     label() is not a requirement of the protocol, it exists only in the
           extension. Such methods are dispatched statically, by the type the
           compiler sees. parts[0] has the type Labelled, so the extension's
           version is called and the struct's own method is never looked at.
           Only protocol requirements are dispatched dynamically.
 Fix:      one line, make it a requirement:
             protocol Labelled {
                 var componentID: String { get }
                 func label() -> String
             }
*/

// Report 3, fixed version
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Not attempted.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?

    `mutating` in a protocol only says "this method is allowed to change self".
    A struct is a value type and its methods cannot change its properties by
    default, so SensorModule has to mark the method. A class is a reference
    type: Drone's method changes the object the reference points to (here the
    shared PowerCell), the reference itself stays the same, so there is nothing
    to mark.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:

    Inheritance gives subclasses stored properties and a real implementation
    that can be locked with `final` and reused with `super` (id, cell, runOnce).
    A protocol can unite types that have no common ancestor and cannot have
    one: a class, a struct, and LegacyBeacon, a type we are not allowed to edit.

 3. What does `final` prevent, and what did it protect in runOnce()?

    It prevents overriding a member (or subclassing, when it is on a class).
    For runOnce() it guarantees that no drone type can skip the "spend power
    first, work only if that succeeded" order, so nobody gets free work or a
    negative charge.

 4. In Report 4, why did the protocol extension's method win?

    Because label() was not declared in the protocol itself. Extension-only
    methods use static dispatch, and the element type of the array is Labelled,
    so the compiler picked the extension's version at compile time. After
    label() is added to the protocol as a requirement, the call goes through
    the type's own implementation and prints "thruster T-1".
*/
