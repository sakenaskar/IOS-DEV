// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
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

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("--- 1.1 Decks ---")
for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        var steps = mass / 500          // every full 500 kg = one step
        if steps > 3 { steps = 3 }      // 1500 kg and above = red
        if steps < 0 { steps = 0 }
        return AlarmLevel(rawValue: steps) ?? .red
    }
}

print("--- 1.2 Alarm ---")
print("0 kg    -> \(AlarmLevel.level(forTotalMass: 0))")
print("940 kg  -> \(AlarmLevel.level(forTotalMass: 940))")
print("4000 kg -> \(AlarmLevel.level(forTotalMass: 4000))")


// MARK: Level 2 · The Manifest

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

    if parts.count == 3, parts[0] == "crate",
       let id = Int(parts[1]), let massKg = Int(parts[2]) {
        return .crate(id: id, massKg: massKg)
    }
    if parts.count == 3, parts[0] == "container",
       let massKg = Int(parts[2]) {
        return .container(code: parts[1], massKg: massKg)
    }
    if parts.count == 4, parts[0] == "livestock",
       let count = Int(parts[2]), let perUnit = Int(parts[3]) {
        return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
    }
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

print("--- 2.x Manifest ---")
var totalMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    totalMass += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
}
let A = totalMass
print("Total manifest mass: \(A) kg")
print("Unknown lines: \(unknownCount)")


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(amount: Int) {
        oxygen -= amount
        if oxygen < 0 { oxygen = 0 }
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

// 3.2
var rosterBuilder: [CrewSnapshot] = []
for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        rosterBuilder.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    } else {
        print("WARNING: \(record.name) is on unknown deck '\(record.deck)', skipped")
    }
}
let crewRoster: [CrewSnapshot] = rosterBuilder

print("--- 3.x Roster ---")
for member in crewRoster {
    print("\(member.name) on \(member.deck.rawValue), oxygen \(member.oxygen)")
}
var demoCrew = CrewSnapshot.rookie(named: "Demo")
demoCrew.breathe(amount: 150)
print("Demo after breathe(150): \(demoCrew.oxygen)")   // clamped to 0
demoCrew.move(to: .lab)
print("Demo moved to \(demoCrew.deck)")
demoCrew.reviveInMedbay()
print("Demo revived: \(demoCrew.deck), oxygen \(demoCrew.oxygen)")

// 3.3 · Value-semantics demonstration
print("--- 3.3 Value semantics ---")

// (1) copy
let original = CrewSnapshot.rookie(named: "Aru")
var copy = original
print("1. BEFORE: original=\(original.oxygen), copy=\(copy.oxygen)")
copy.oxygen = 10
print("1. AFTER:  original=\(original.oxygen), copy=\(copy.oxygen)")

// (2) plain function parameter: the function gets its own copy
func drainPlain(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.oxygen = 0
    print("   inside drainPlain: local=\(local.oxygen)")
}
var subject = CrewSnapshot.rookie(named: "Bota")
print("2. BEFORE plain call: \(subject.oxygen)")
drainPlain(subject)
print("2. AFTER plain call:  \(subject.oxygen)")

// (3) inout: the function works on the caller's value
func drainInout(_ snapshot: inout CrewSnapshot) {
    snapshot.oxygen = 0
}
print("3. BEFORE inout call: \(subject.oxygen)")
drainInout(&subject)
print("3. AFTER inout call:  \(subject.oxygen)")


// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // A struct gets a memberwise init for free because the compiler can
    // simply copy values into its fields. A class gets NO free init
    // (except an empty one if every property has a default), because
    // `occupant` and others need explicit setup and a class may have
    // a superclass chain to initialise. So we write it ourselves.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    // Bonus 1
    deinit {
        print("deinit: pod \(id) destroyed")
    }

    // fails if the pod is already occupied
    func load(crew: CrewSnapshot) -> Bool {
        if occupant != nil { return false }
        occupant = crew
        return true
    }

    // fails if no occupant or charge < 20; no charge spent on failure
    func fire() -> CrewSnapshot? {
        guard let passenger = occupant, chargeLevel >= 20 else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }
}

// 4.2 · Charge ledger
print("--- 4.2 Charge ledger ---")
let pod1 = TeleportPod(id: "P-1", chargeLevel: 100)
let timur = crewRoster[0]
let dana = crewRoster[1]
let nurlan = crewRoster[3]

let loaded1 = pod1.load(crew: timur)
let sent1 = pod1.fire()
print("Step 1: loaded=\(loaded1), sent=\(sent1?.name ?? "nobody"), charge=\(pod1.chargeLevel)")

let loaded2 = pod1.load(crew: dana)
let sent2 = pod1.fire()
print("Step 2: loaded=\(loaded2), sent=\(sent2?.name ?? "nobody"), charge=\(pod1.chargeLevel)")

let loaded3 = pod1.load(crew: nurlan)
let sent3 = pod1.fire()
print("Step 3: loaded=\(loaded3), sent=\(sent3?.name ?? "nobody"), charge=\(pod1.chargeLevel)")

let sent4 = pod1.fire()
print("Step 4: sent=\(sent4?.name ?? "nobody"), charge=\(pod1.chargeLevel)")

let C = pod1.chargeLevel

// 4.3 · Reference-semantics demonstration
print("--- 4.3 Reference semantics ---")
let podAlias = pod1
podAlias.chargeLevel = 5
print("pod1 charge=\(pod1.chargeLevel), podAlias charge=\(podAlias.chargeLevel)")   // both 5
pod1.chargeLevel = C   // restore

var snapA = CrewSnapshot.rookie(named: "Eli")
var snapB = snapA
snapB.oxygen = 1
print("snapA oxygen=\(snapA.oxygen), snapB oxygen=\(snapB.oxygen)")   // 100 and 1
// Rule: assigning a class instance copies the REFERENCE (both names point to one object),
// assigning a struct copies the VALUE (each name owns its own data).
snapA.oxygen = 100   // silence "never mutated" warning


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    // Stored (let)
    let callSign: String

    // Stored (var) with observers
    var hullIntegrity: Int = 100 {
        willSet {
            print("hullIntegrity: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    var oxygenByDeck: [Deck: Int]

    // Lazy stored: the closure runs once, on first access
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        var report = "Diagnostics for \(self.callSign):"
        for deck in Deck.allCases {
            if let level = self.oxygenByDeck[deck] {
                report += " \(deck.rawValue)=\(level)"
            }
        }
        return report
    }()

    // Computed, read-only (no `get` keyword)
    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values {
            sum += value
        }
        return sum
    }

    // Computed, get + set
    var averageOxygen: Int {
        get {
            if oxygenByDeck.count == 0 { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Deck.allCases {
                if oxygenByDeck[deck] != nil {
                    oxygenByDeck[deck] = newValue
                }
            }
        }
    }

    init(callSign: String) {
        self.callSign = callSign
        var readings: [Deck: Int] = [:]
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                readings[deck] = reading.oxygen
            } else {
                print("WARNING: reading for unknown deck '\(reading.deck)' skipped")
            }
        }
        self.oxygenByDeck = readings
    }
}

print("--- 5.1 Station ---")
let station = Station(callSign: "ALMA-7")
let B = station.averageOxygen          // before changing anything
print("Start-up average oxygen: \(B)")
print("Total oxygen: \(station.totalOxygen)")

let quietStation = Station(callSign: "ALMA-8")
print("quietStation created, diagnostics never touched -> no scan above")

print("Before first access")
print(station.fullDiagnostics)
print("Second access (no scan expected)")
print(station.fullDiagnostics)

station.averageOxygen = 70
print("After setting average to 70: avg=\(station.averageOxygen), total=\(station.totalOxygen)")
station.averageOxygen = B   // restore

// 5.2 · The clamp trap
print("--- 5.2 Clamp ---")
station.hullIntegrity = 130
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = -40
print("hull = \(station.hullIntegrity)")
station.hullIntegrity = 55
print("hull = \(station.hullIntegrity)")
// Assigning to a property from inside its OWN didSet does not call the
// observers again (Swift suppresses it), so the clamp cannot recurse forever.


// MARK: Level 6 · Incident Reports
/*
 REPORT 1
 Expected: every crew member loses 10 oxygen.
 Actual: roster is unchanged. `for var member in roster` gives each
 iteration its own COPY of the struct; we change the copy and throw it away.
 Rule: structs are value types, assignment/iteration copies.
 Fix:
     for i in 0..<roster.count {
         roster[i].oxygen -= 10
     }

 REPORT 2
 Expected: podA stays 100 (author thought `let podB = podA` made a copy).
 Actual: prints 0. TeleportPod is a class, podA and podB are two names for the
 SAME object. `let` only freezes the reference, not the object's var properties.
 Rule: classes are reference types.
 Fix (if you want independence): create a second pod,
     let podB = TeleportPod(id: "A", chargeLevel: podA.chargeLevel)
 or make the type a struct if it does not need identity.

 REPORT 3  (does NOT compile)
 Error: "cannot use mutating member on immutable value: 'self' is immutable".
 Methods of a struct cannot change its properties unless marked `mutating`,
 because self is a constant inside a normal method.
 Fix:
     mutating func add(_ entry: String) { entries.append(entry) }
 (and the Logbook instance must then be `var`.)

 REPORT 4
 Line `snapshot.oxygen = 40` -> ERROR (cannot assign to property: 'snapshot' is a 'let' constant).
 For a struct, `let` freezes the whole value, including every property inside it.
 Line `pod.chargeLevel = 10` -> compiles and works.
 For a class, `let` freezes only the reference (pod can't point to another object),
 the object it points to can still be changed.
 Fix: `var snapshot = CrewSnapshot.rookie(named: "Dana")`.
 (Note: the task says only one report fails to build, but reports 3 and 4
 both have a compile error. Worth mentioning to the teacher.)
*/

print("--- Level 6 demo ---")
var fixedRoster = crewRoster
for i in 0..<fixedRoster.count {
    fixedRoster[i].oxygen -= 10
}
print("Report 1 fixed: \(fixedRoster[0].oxygen) (original was \(crewRoster[0].oxygen))")
print("Report 1 original untouched: \(crewRoster[0].oxygen)")


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    // private: nobody outside the type can read, replace or clear the list.
    private var entries: [String] = []

    // private(set): anyone can READ isSealed, only this type can WRITE it,
    // so nobody outside can set it back to false.
    private(set) var isSealed = false

    // internal (default) read-only computed property: lets outsiders read the count.
    var entryCount: Int {
        return entries.count
    }

    // internal: outsiders may add, but the guard blocks adding after sealing.
    @discardableResult
    func add(_ entry: String) -> Bool {
        if isSealed { return false }
        entries.append(entry)
        return true
    }

    // internal: the only way to change isSealed, and it only goes one way.
    func seal() {
        isSealed = true
    }

    // fileprivate: usable from other code in THIS FILE (the free function below),
    // hidden from other files.
    fileprivate func numberedLines() -> [String] {
        var lines: [String] = []
        var number = 1
        for entry in entries {
            lines.append("\(number). \(entry)")
            number += 1
        }
        return lines
    }

    // internal: formatted transcript for outsiders.
    var transcript: String {
        var text = ""
        for line in numberedLines() {
            text += line + "\n"
        }
        return text
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    var text = "AUDIT (sealed: \(recorder.isSealed)):"
    for line in recorder.numberedLines() {
        text += " [\(line)]"
    }
    return text
}

print("--- 7 Black box ---")
let recorder = FlightRecorder()
recorder.add("Teleporter online")
recorder.add("Crew transferred")
print("Entries: \(recorder.entryCount), sealed: \(recorder.isSealed)")
recorder.seal()
let lateAdd = recorder.add("This must be rejected")
print("Add after seal accepted? \(lateAdd), entries: \(recorder.entryCount)")
print(recorder.transcript)
print(auditTranscript(of: recorder))

// Failed attempts to break it (left as comments because they don't compile):
// recorder.entries = []
//   error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
//   error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// 2. Lifetime experiment
print("--- Bonus ---")
var keeper: TeleportPod? = nil
do {
    let lone = TeleportPod(id: "LONE", chargeLevel: 50)
    let shared = TeleportPod(id: "SHARED", chargeLevel: 50)
    keeper = shared
    print("inside block: \(lone.id) and \(shared.id) alive")
}   // "LONE" deinit fires here: its only reference (`lone`) went out of scope
print("after block: SHARED still alive via keeper: \(keeper?.id ?? "none")")
keeper = nil   // "SHARED" deinit fires on THIS line: last reference removed
print("after keeper = nil")

// 3. Identity
func describe(_ a: TeleportPod, _ b: TeleportPod) -> String {
    if a === b {
        return "same pod (one object, two references)"
    } else if a.id == b.id && a.chargeLevel == b.chargeLevel {
        return "two different pods with equal contents"
    } else {
        return "two different pods"
    }
}
let x = TeleportPod(id: "X", chargeLevel: 80)
let xAlias = x
let xTwin = TeleportPod(id: "X", chargeLevel: 80)
print("x vs xAlias: \(describe(x, xAlias))")
print("x vs xTwin:  \(describe(x, xTwin))")
// === compares object identity (memory address). Structs have no identity:
// they are just values, every variable holds its own copy, so there is
// no "same object" to compare. === only works on class instances (AnyObject).


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. CrewSnapshot is a struct: the compiler generates a memberwise initializer
    automatically. TeleportPod is a class: classes get no memberwise init, and
    we also want custom setup (occupant = nil), so we write init ourselves.

 2. `mutating` makes self inside the method a variable (inout-like), so the method
    can change properties or even assign a new value to self. In a struct the
    value is copied around, so changing it must be explicit. Classes never need it
    because self is a reference: changing the object doesn't change the reference.

 3. Struct with `let`: the entire value is frozen, no property can change.
    Class with `let`: only the reference is frozen (can't point to another object),
    but its `var` properties can still be changed.

 4. A lazy property is computed on first access, so it changes after init, which
    needs a `var` (a `let` must have its value before init finishes). Behaviour change:
    a lazy property with side effects (like our "Running full scan..." print) runs
    only on first use, or never; and it can read other properties of self
    (callSign, oxygenByDeck), which a normal default value can't.

 5. `numberedLines()` is used by the free function auditTranscript, which is
    outside the class but in the same file. With `private` it would not compile
    there. `fileprivate` allows exactly that, without opening it to other files.

 Bonus. deinit for "SHARED" fires on `keeper = nil`, because that's when its
 reference count hits zero. "LONE" fires at the end of the do-block.
 === can't be used on CrewSnapshot because structs are values with no identity.
*/
