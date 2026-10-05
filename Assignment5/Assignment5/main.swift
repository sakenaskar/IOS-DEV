// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Solution.swift
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

// Why a class and not a struct here?  ->
// Because the cell must be ONE shared object: every holder of the reference sees the same charge, while a struct would be copied and the copies would drift apart.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        // clamp the starting value into 0...100
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
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level
// (copy the exact text from your own compiler, wording differs a bit between Swift versions)


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  ->
// It guarantees no subclass can replace the "spend energy, then work" ritual, so nobody can skip the battery check or produce work for free.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        let level = cell.level()
        return "\(id): \(level)% \(level.powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        if !cell.spend(powerCost) {
            return 0
        }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id) welded a seam" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: skipped unknown drone kind '\(record.kind)' (\(record.id))")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)

var B = 0
var C = 0
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        C += 1
    }
}
print("Drones that can still run one more task: \(C)")


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

// Why does Drone implement recharge(by:) without `mutating`?  ->
// Drone is a class (reference type): changing its state never replaces the value of the variable that holds it, so `mutating` is meaningless; only value types (structs) need it.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { Self.healthCode(forLevel: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { Self.healthCode(forLevel: chargeLevel) }

    mutating func recharge(by amount: Int) {
        if amount <= 0 { return }
        chargeLevel += amount
        if chargeLevel > 100 { chargeLevel = 100 }
    }
}

var sensors: [SensorModule] = []
for entry in sensorData {
    sensors.append(SensorModule(id: entry.id, chargeLevel: entry.charge))
}

// 4.3
// Why could [Drone] never have held the sensors?  ->
// Because SensorModule is a struct with no Drone ancestor, and an [Drone] array only accepts Drone and its subclasses; the protocol is the one thing they share.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}

print("--- Diagnostics (drones + sensors) ---")
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    // THE Health Rule. This is the only place the thresholds exist.
    static func healthCode(forLevel level: Int) -> Int {
        if level < 20 { return 2 }   // critical
        if level < 50 { return 1 }   // warning
        return 0                     // nominal
    }

    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { Self.healthCode(forLevel: signalStrength) }

    func diagnose() -> String {
        return "[LEGACY] \(name): signal \(signalStrength), code \(statusCode) - old station hardware"
    }
}

components.append(beacon)

print("--- Diagnostics (with legacy beacon) ---")
print(diagnosticsReport(components))

var D = 0
for component in components {
    D += component.statusCode
}

// 5.3
extension Int {
    var powerBar: String {   // 42 -> "####......"
        var filled = self / 10
        if filled < 0 { filled = 0 }
        if filled > 10 { filled = 10 }
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }
}


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// (In reality Reports 1, 2 and 3 fail to compile, only Report 4 compiles and lies.)

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}
// Expected: a PatchDrone that produces 30 work units.
// Actual: does NOT compile: "overriding declaration requires an 'override' keyword".
// Rule: a method that redefines a superclass method must be marked `override`, so the compiler can catch accidental/mismatched overrides.
// Fix: `override func performTask() -> Int { return 30 }`

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}
// Expected: a welder that cheats and always returns 999.
// Actual: does NOT compile: "inheritance from a final class 'WelderDrone'" and "instance method overrides a 'final' instance method".
// Rule: `final` on a class forbids subclassing, `final` on a method forbids overriding it.
// Fix: don't override runOnce(). Change behaviour through the allowed hooks (powerCost / performTask) and subclass a non-final class
// (or remove `final` from WelderDrone).

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())
// Expected: prints "W-9 welded a seam".
// Actual: does NOT compile: "value of type 'Drone' has no member 'weldSeam'".
// Rule: the compiler checks against the STATIC type (Drone), not the runtime type (WelderDrone).
// Fix: conditional cast:
//   if let welder = first as? WelderDrone { print(welder.weldSeam()) }
// as? returns an optional because the cast can fail at runtime (the object might not be a WelderDrone), and nil expresses that failure safely.

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
// Expected: "thruster T-1".
// Actual: compiles and prints "generic component".
// Rule: label() is NOT a protocol requirement, it only exists in the extension, so the call through the protocol type is dispatched statically to the extension's version.
// Requirements are dispatched dynamically through the protocol witness table, extension-only methods are not.
// Fix: add `func label() -> String` to the declaration of protocol Labelled.
*/

// Report 3, fixed (this one is safe to run):
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Two ways to forbid using Drone directly:
//  1) Runtime: in the base class make performTask() / init call
//         fatalError("Drone is abstract, subclass it")
//     It builds fine and crashes only when someone actually uses a bare Drone.
//  2) Compile time: make the base type a protocol (below). A protocol cannot be instantiated,
//     so `Worker(...)` is rejected by the compiler.

protocol Worker {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension Worker {
    func runOnce() -> Int {
        if !cell.spend(powerCost) { return 0 }
        return performTask()
    }
}

struct WelderWorker: Worker {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

// Comparison: the protocol design makes "must implement performTask" a compile-time error, drops inheritance, and lets
// WelderWorker be a cheap struct. The class design is better when objects share identity and mutable state
// (a class hierarchy plus `final` guards the ritual). I would pick the protocol for this station, but if drones had to share
// mutable state I would keep them as classes (or keep a shared reference like PowerCell inside the structs),
// because struct copies would drift apart.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    `mutating` means "this method may replace self with a new value". A class instance is a reference:
    changing its properties never changes the reference itself, so the keyword is unnecessary.
    A struct is a value type, changing a property changes the whole value, so the method has to be marked `mutating`
    (and can't be called on a `let`).

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance: stores state and shares an implementation (stored properties, init, `super`) in a base class.
    Protocols: unite unrelated types, including structs and types you can't edit (LegacyBeacon), under one interface,
    since a type can only have one superclass but can conform to many protocols.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` prevents overriding (for a method) or subclassing (for a class). On runOnce() it protects the ritual
    "spend powerCost, otherwise return 0, otherwise performTask()", so no subclass can skip the battery check.

 4. In Report 4, why did the protocol extension's method win?
    label() was not a protocol requirement, so through the `Labelled` type the call is resolved statically to the extension's
    implementation. Only requirements get dynamic dispatch via the witness table. Declaring label() in the protocol fixes it.
*/
