// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
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

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueText) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(valueText),
          value >= 0 || sensor == "TEMP"
    else { return nil }
    return (sensor: sensor, value: value)
}

print(parseReading("O2:87") as Any)     // (sensor: "O2", value: 87)
print(parseReading("TEMP:-12") as Any)  // (sensor: "TEMP", value: -12)
print(parseReading("RAD:-1") as Any)    // nil
print(parseReading(":55") as Any)       // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid, invalidCount)
}

let parsed = parseLog(rawLog)
print("valid: \(parsed.valid.count), invalid: \(parsed.invalidCount)")
print(parseLog(["O2:1", "bad"]))
let A = parsed.invalidCount


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

let o2Readings = select(parsed.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)
print("O2 values: \(o2Values)")
print("RAD values: \(values(of: select(parsed.valid) { $0.sensor == "RAD" }))")

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for v in values {
        if v < minValue { minValue = v }
        if v > maxValue { maxValue = v }
        sum += v
    }
    return (minValue, maxValue, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)  // (min: 1, max: 8, average: 4.0)
print(stats() as Any)         // nil

let B = Int(stats(of: o2Values)?.average ?? 0)

// 2.3 · The Closure Ladder
let valid = parsed.valid

// 1. Полный синтаксис
let sort1 = valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
// 2. Типы выводятся из контекста
let sort2 = valid.sorted(by: { a, b in
    return a.value > b.value
})
// 3. Неявный return
let sort3 = valid.sorted(by: { a, b in a.value > b.value })
// 4. $0, $1
let sort4 = valid.sorted(by: { $0.value > $1.value })
// 5. Trailing closure
let sort5 = valid.sorted { $0.value > $1.value }

// кортежи не Equatable, поэтому сравниваем руками
func sameReadings(_ x: [Reading], _ y: [Reading]) -> Bool {
    guard x.count == y.count else { return false }
    for i in 0..<x.count {
        if x[i].sensor != y[i].sensor || x[i].value != y[i].value { return false }
    }
    return true
}

let allSame = sameReadings(sort1, sort2) && sameReadings(sort1, sort3)
    && sameReadings(sort1, sort4) && sameReadings(sort1, sort5)
print("All 5 sorts match: \(allSame)")
print(values(of: sort5))


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

print(chooseProtocol(for: 10)(10))  // 15
print(chooseProtocol(for: 30)(30))  // 27
print(chooseProtocol(for: 20)(20))  // 20

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    let safeRange = 18...24
    var temp = start
    var steps = 0
    while !safeRange.contains(temp) && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (temp, steps, safeRange.contains(temp))
}

print(runUntilStable(from: 31))                  // (22, 3, true)
print(runUntilStable(from: -100, maxSteps: 5))   // (-75, 5, false)

let tempValues = values(of: select(parsed.valid) { $0.sensor == "TEMP" })
let lowestTemp = stats(of: tempValues)?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

for member in crew {
    print("\(member.name): \(oxygenLevel(of: member) as Any)")
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    return level < 20
        ? "\(member.name): \(level)% CRITICAL"
        : "\(member.name): \(level)% OK"
}

for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let room = max(0, 100 - target)
    let moved = min(amount, source, room)
    guard moved > 0 else { return 0 }
    source -= moved
    target += moved
    return moved
}

// тесты на обычных переменных
var x1 = 50, y1 = 90
print(transferOxygen(from: &x1, to: &y1, amount: 30))  // 10 (влезло только 10)
var x2 = 5, y2 = 0
print(transferOxygen(from: &x2, to: &y2, amount: 30))  // 5 (в источнике всего 5)
var x3 = 5, y3 = 0
print(transferOxygen(from: &x3, to: &y3, amount: -4))  // 0

// Lab -> Hab, без "!"
var D = 0
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    D = habTank.level
}
print("Lab: \(oxygenLevel(of: crew[0]) as Any), Hab: \(D)")

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
    let sorted = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in sorted {
        result.append(member.name)
    }
    return result
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
// Unknown crew member: Ghost
// ["Aigerim", "Timur", "Dana"]
print(evacuationOrder("Nurlan", "Dana", roster: roster))  // ["Nurlan", "Dana"]




func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no oxygen data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

// Тест: двое критических — должен вернуться первый
let testModule1 = Module(name: "T1", oxygenTank: Tank(level: 5))
let testModule2 = Module(name: "T2", oxygenTank: Tank(level: 10))
let first = CrewMember(name: "First", role: "Test", priority: 1, module: testModule1)
let second = CrewMember(name: "Second", role: "Test", priority: 2, module: testModule2)
print(firstCritical(in: [first, second]) as Any)   // Optional("First"), у саботажника было бы "Second"
print(firstCritical(in: crew) as Any)   // Optional("Timur"), Lab после переливания = 10%
print(firstCritical(in: []) as Any)                // nil, без крэша
print(reportOxygen(for: crew[1]))                  // Dana: no oxygen data
print(reportOxygen(for: crew[3]))                  // Nurlan: no oxygen data


// MARK: Finale · Launch Code
let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")   // 6-78-6-42


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

let alarm = makeAlarm(threshold: 20)
print(alarm(12))  // Alarm #1 → true
print(alarm(40))  // false
print(alarm(5))   // Alarm #2 → true



