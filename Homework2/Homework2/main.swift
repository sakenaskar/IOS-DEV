
import Foundation

//easy tasks

print("Easy Tasks")

//1
var fruits = ["apple", "banana", "orange", "mango", "mandarin"]
print("Third fruit:", fruits[2])

//2
var favoriteNumbers: Set<Int> = [7,007,777,70]
favoriteNumbers.insert(606)
print("Updated set of numbers:", favoriteNumbers)

//3
let lrs = ["swift": 2014, "python": 1991, "java": 1995]
print("Swift release year:", lrs["Swift"]!)

//4
var colors = ["black", "white", "grey", "brown"]
colors[1] = "Purple"
print("Updated colors array:", colors)


//med
let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
let setIntersection = setA.intersection(setB)
print("Set intersection:", setIntersection)

//2
var studentScores = ["Saken": 85, "Sam": 90, "Miras": 78]
studentScores["Sam"] = 95
print("Updated student scores:", studentScores)

//3
let array1 = ["apple", "banana"]
let array2 = ["cherry", "date"]
let mergedArray = array1 + array2
print("Merged array:", mergedArray)


//hard

var countryPopulations = ["Kazakhstan": 20_000_000, "Japan": 125_000_000]
countryPopulations["France"] = 68_000_000
print("Updated country populations:", countryPopulations)


//2
let animals1: Set<String> = ["cat", "dog"]
let animals2: Set<String> = ["dog", "mouse"]
let unionSet = animals1.union(animals2)
let finalSet = unionSet.subtracting(animals2)
print("Final set after union and subtract:", finalSet)

//3
let studentGrades: [String: [Int]] = [
    "Saken": [90, 85, 95],
    "Miras": [75, 80, 88]
]
print("Second grade for Saken:", studentGrades["Saken"]![1])
