import UIKit
// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

print("")
print("--- Level 1 ---")

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

for deck in Deck.allCases {
    print("\(deck.rawValue) priority: \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        var step = mass / 500
        if step > 3 {
            step = 3
        }
        if step < 0 {
            step = 0
        }
        if let level = AlarmLevel(rawValue: step) {
            return level
        }
        return .red
    }
}

print("0 kg -> \(AlarmLevel.level(forTotalMass: 0))")
print("940 kg -> \(AlarmLevel.level(forTotalMass: 940))")
print("4000 kg -> \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

print("")
print("--- Level 2 ---")

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)

    if parts[0] == "crate" && parts.count == 3 {
        if let id = Int(parts[1]), let massKg = Int(parts[2]) {
            return .crate(id: id, massKg: massKg)
        }
    }

    if parts[0] == "container" && parts.count == 3 {
        if let massKg = Int(parts[2]) {
            return .container(code: parts[1], massKg: massKg)
        }
    }

    if parts[0] == "livestock" && parts.count == 4 {
        if let count = Int(parts[2]), let perUnit = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
        }
    }

    // wrong tag, wrong number of fields or bad number
    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    totalMass += mass(of: entry)

    switch entry {
    case .unknown:
        unknownCount += 1
        print("corrupted line: \"\(line)\"")
    default:
        print("\(entry) -> \(mass(of: entry)) kg")
    }
}

print("unknown lines: \(unknownCount)")
print("total mass: \(totalMass)")

let A = totalMass


// MARK: Level 3 · Crew Snapshots

print("")
print("--- Level 3 ---")

// 3.1
// no init here, struct gets memberwise init automatically
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = oxygen - amount
        if oxygen < 0 {
            oxygen = 0
        }
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var rookie = CrewSnapshot.rookie(named: "Alex")
print("rookie: \(rookie.name), \(rookie.deck), oxygen \(rookie.oxygen)")
rookie.breathe(150)
print("after breathe(150): oxygen \(rookie.oxygen)")
rookie.move(to: .cargo)
print("after move: \(rookie.deck)")
rookie.reviveInMedbay()
print("after revive: \(rookie.deck), oxygen \(rookie.oxygen)")

// 3.2
var tempRoster: [CrewSnapshot] = []
for person in crewData {
    if let deck = Deck(rawValue: person.deck) {
        let snapshot = CrewSnapshot(name: person.name, deck: deck, oxygen: person.oxygen)
        tempRoster.append(snapshot)
    } else {
        print("warning: deck \(person.deck) does not exist, skipping \(person.name)")
    }
}
let crewRoster: [CrewSnapshot] = tempRoster

for member in crewRoster {
    print("\(member.name) - \(member.deck) - oxygen \(member.oxygen)")
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)

// 1) copy
let first = CrewSnapshot(name: "Aigerim", deck: .bridge, oxygen: 91)
var second = first
print("1) before: first = \(first.oxygen), second = \(second.oxygen)")
second.oxygen = 10
print("1) after:  first = \(first.oxygen), second = \(second.oxygen)")

// 2) plain parameter
func changeOxygen(_ crew: CrewSnapshot) {
    var crewCopy = crew
    crewCopy.oxygen = 0
    print("2) inside function oxygen = \(crewCopy.oxygen)")
}

let timur = CrewSnapshot(name: "Timur", deck: .engine, oxygen: 62)
print("2) before: timur oxygen = \(timur.oxygen)")
changeOxygen(timur)
print("2) after:  timur oxygen = \(timur.oxygen)")

// 3) inout
func changeOxygenInout(_ crew: inout CrewSnapshot) {
    crew.oxygen = 0
}

var dana = CrewSnapshot(name: "Dana", deck: .lab, oxygen: 48)
print("3) before: dana oxygen = \(dana.oxygen)")
changeOxygenInout(&dana)
print("3) after:  dana oxygen = \(dana.oxygen)")


// MARK: Level 4 · The Teleport Pod

print("")
print("--- Level 4 ---")

// 4.1
// class because the pod is one real object and everyone should see the same pod
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // classes dont get a memberwise init like structs do,
    // and id / chargeLevel have no default values, so I need to write init myself
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    // bonus
    deinit {
        print("deinit pod \(id)")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant == nil && chargeLevel >= 20 {
            occupant = crew
            return true
        }
        return false
    }

    func fire() -> CrewSnapshot? {
        if let person = occupant {
            chargeLevel -= 20
            occupant = nil
            return person
        }
        return nil
    }
}

// 4.2 · Charge ledger
let pod1 = TeleportPod(id: "P-1", chargeLevel: 100)
print("start charge: \(pod1.chargeLevel)")

let names = ["Timur", "Dana", "Nurlan"]
for name in names {
    for member in crewRoster {
        if member.name == name {
            let ok = pod1.load(member)
            let result = pod1.fire()
            if let arrived = result {
                print("load \(name): \(ok), fired \(arrived.name), charge = \(pod1.chargeLevel)")
            }
        }
    }
}

let emptyResult = pod1.fire()
if emptyResult == nil {
    print("fire empty pod: nil, charge = \(pod1.chargeLevel)")
}

let C = pod1.chargeLevel

// 4.3 · Reference-semantics demonstration
let podX = TeleportPod(id: "X", chargeLevel: 100)
let podY = podX
podY.chargeLevel = 50
print("class: podX = \(podX.chargeLevel), podY = \(podY.chargeLevel)")

let crewX = CrewSnapshot(name: "Nurlan", deck: .cargo, oxygen: 17)
var crewY = crewX
crewY.oxygen = 99
print("struct: crewX = \(crewX.oxygen), crewY = \(crewY.oxygen)")

// class copies the reference (same object), struct copies the whole value (separate object)


// MARK: Level 5 · Station Systems

print("")
print("--- Level 5 ---")

// 5.1
// class because there is only one station and its state is shared
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int] = [:]

    var hullIntegrity: Int {
        willSet {
            print("hull changing from \(hullIntegrity) to \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            }
            if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "\(self.callSign): hull \(self.hullIntegrity), total oxygen \(self.totalOxygen)"
    }()

    var totalOxygen: Int {
        var sum = 0
        for (_, value) in oxygenByDeck {
            sum += value
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.count == 0 {
                return 0
            }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Deck.allCases {
                if let _ = oxygenByDeck[deck] {
                    oxygenByDeck[deck] = newValue
                }
            }
        }
    }

    init(callSign: String, hullIntegrity: Int) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            } else {
                print("skipping unknown deck: \(reading.deck)")
            }
        }
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 100)
print("call sign: \(station.callSign)")
print("total oxygen: \(station.totalOxygen)")
print("average oxygen: \(station.averageOxygen)")

let B = station.averageOxygen

station.averageOxygen = 60
print("after set average to 60: lab = \(station.oxygenByDeck[.lab] ?? 0), total = \(station.totalOxygen)")

// lazy test
let otherStation = Station(callSign: "ALMA-8", hullIntegrity: 90)
print("otherStation created, I never use fullDiagnostics on it, so no scan message")

print("first access:")
print(station.fullDiagnostics)
print("second access:")
print(station.fullDiagnostics)

// 5.2 · The clamp trap
station.hullIntegrity = 130
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = -40
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = 55
print("hull = \(station.hullIntegrity)")

// it doesnt loop forever because when you change a property inside its own didSet,
// swift does not call willSet/didSet again


// MARK: Level 6 · Incident Reports

print("")
print("--- Level 6 ---")

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

// Report 1
// expected: everyone loses 10 oxygen
// actual: compiles but nothing changes, prints 62
// rule: struct is a value type, `member` in the loop is just a copy
// fix: change the array by index
var roster = crewRoster
for i in 0..<roster.count {
    roster[i].oxygen -= 10
}
print("report 1: \(roster[0].oxygen)")

// Report 2
// expected: podA stays 100
// actual: compiles but prints 0
// rule: class is a reference type, podA and podB are the same object
// fix: make a new pod for podB
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = TeleportPod(id: "A2", chargeLevel: podA.chargeLevel)
podB.chargeLevel = 0
print("report 2: \(podA.chargeLevel)")

// Report 3
// expected: add() adds an entry
// actual: does not compile -> error: cannot use mutating member on immutable value: 'self' is immutable
// rule: struct method cant change properties without `mutating`
// fix: add mutating
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = Logbook()
logbook.add("pod incident")
print("report 3: \(logbook.entries)")
logbook.add("crew on two decks")
print("report 3: \(logbook.entries.count) entries")

// Report 4
// expected: both lines work
// actual: snapshot.oxygen = 40 gives error: cannot assign to property: 'snapshot' is a 'let' constant
//         pod.chargeLevel = 10 works fine
// rule: let on a struct freezes the whole value (all properties).
//       let on a class only freezes the reference, so you cant point pod to another
//       object, but you can still change its var properties
// fix: use var for the struct
var snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40
let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
print("report 4: snapshot = \(snapshot.oxygen), pod = \(pod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

print("")
print("--- Level 7 ---")

// class because there should be only one black box that everybody writes into
final class FlightRecorder {
    // private: nobody outside can replace or clear the entries
    private var entries: [String] = []

    // private(set): outside code can read isSealed but cant set it back to false
    private(set) var isSealed = false

    // internal: just reading the count, nothing to block here
    internal var count: Int {
        return entries.count
    }

    // internal: read only transcript, nothing to block here
    internal var transcript: String {
        var text = ""
        for i in 0..<entries.count {
            text += "\(i + 1). \(entries[i])\n"
        }
        return text
    }

    // internal: anyone can add, but the method blocks adding after seal
    internal func add(_ entry: String) {
        if isSealed {
            print("recorder is sealed, cant add: \(entry)")
            return
        }
        entries.append(entry)
    }

    // internal: anyone can seal, there is no unseal function
    internal func seal() {
        isSealed = true
    }

    // fileprivate: blocks code from other files, only this file can use it
    fileprivate func allEntries() -> [String] {
        return entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    let list = recorder.allEntries()
    return "audit: \(list.count) entries, first = \(list.first ?? "none")"
}

let recorder = FlightRecorder()
recorder.add("teleporter moved all crew")
recorder.add("Nurlan on two decks")
print("count: \(recorder.count)")
recorder.seal()
recorder.add("fake entry")
print("count after seal: \(recorder.count), sealed: \(recorder.isSealed)")
print(recorder.transcript)
print(auditTranscript(of: recorder))

// trying to break it:
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
//
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

print("")
let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

print("")
print("--- Bonus ---")

var keeper: TeleportPod? = nil
print("before do block")
do {
    let tempPod = TeleportPod(id: "TEMP", chargeLevel: 30)
    keeper = tempPod
    print("inside do block")
}
print("after do block, pod is still alive")
keeper = nil   // deinit prints here
print("after keeper = nil")

// deinit is not called at the end of the do block because keeper still
// holds a reference. it is called on keeper = nil because then the
// reference count becomes 0

func checkPods(_ a: TeleportPod, _ b: TeleportPod) -> String {
    if a === b {
        return "same pod"
    }
    if a.id == b.id && a.chargeLevel == b.chargeLevel {
        return "different pods but equal contents"
    }
    return "different pods"
}

let p1 = TeleportPod(id: "Q", chargeLevel: 70)
let p2 = p1
let p3 = TeleportPod(id: "Q", chargeLevel: 70)
print("p1 and p2: \(checkPods(p1, p2))")
print("p1 and p3: \(checkPods(p1, p3))")

// === only works for classes (reference types). CrewSnapshot is a struct,
// every copy is a separate value so it has no identity to compare


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    Structs get a memberwise init automatically. Classes dont get it,
    they only get init() if all properties have default values. TeleportPod
    has id and chargeLevel without defaults so I had to write init.

 2. What does `mutating` do to self, and why do classes never need it?
    mutating lets the method change self (the struct value), even replace it
    like in reviveInMedbay. Without it self is constant inside the method.
    Classes are references, changing a property doesnt change the reference
    itself, so they dont need mutating.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
    For a struct let freezes everything, all the properties.
    For a class let freezes only the reference - you cant do pod = otherPod,
    but you can still change pod.chargeLevel.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
    Because lazy gets its value later (on first use), not in init, and let
    must have its value in init. Behaviour changes when the lazy code has a
    side effect, like my "Running full scan..." print - it only happens if
    someone uses fullDiagnostics. Also it uses the values at the moment of
    first access, not at creation.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
    auditTranscript is a function outside the class but in the same file.
    It calls allEntries(). If allEntries was private it would not compile,
    with fileprivate it works but other files still cant use it.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
    On keeper = nil, because thats when the last reference is gone.
    === checks if two references are the same object, struct is not an
    object with reference so === doesnt work on it.
*/
