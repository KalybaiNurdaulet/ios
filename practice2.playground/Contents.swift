import Foundation




let fruits = ["Apple", "Banana", "Cherry", "Mango", "Orange"]
print("Third fruit: \(fruits[2])")


var favoriteNumbers: Set<Int> = [7, 13, 21, 42]
favoriteNumbers.insert(99)
print("Updated set of numbers: \(favoriteNumbers)")


let languageReleaseYears = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print("Swift was released in: \(languageReleaseYears["Swift"]!)")


var colors = ["Red", "Green", "Blue", "Yellow"]
colors[1] = "Purple"
print("Updated colors: \(colors)")





let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
let intersection = setA.intersection(setB)
print("Intersection: \(intersection)")


var studentScores = [
    "Aigerim": 85,
    "Nurdaulet": 92,
    "Dias": 78
]
studentScores.updateValue(97, forKey: "Nurdaulet")
print("Updated scores: \(studentScores)")


let fruitsA = ["apple", "banana"]
let fruitsB = ["cherry", "date"]
let mergedFruits = fruitsA + fruitsB
print("Merged array: \(mergedFruits)")





var countryPopulations = [
    "Kazakhstan": 19_800_000,
    "Germany": 83_200_000,
    "Japan": 125_700_000
]
countryPopulations.updateValue(331_900_000, forKey: "USA")
print("Updated populations: \(countryPopulations)")


let setC: Set<String> = ["cat", "dog"]
let setD: Set<String> = ["dog", "mouse"]
let unionResult = setC.union(setD)
let finalSet = unionResult.subtracting(setD)
print("Final set after union and subtract: \(finalSet)")


let studentGrades = [
    "Nurdaulet": [88, 91, 76],
    "Aigerim": [95, 82, 89]
]
print("Second grade for Nurdaulet: \(studentGrades["Nurdaulet"]![1])")
