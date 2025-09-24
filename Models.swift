import Foundation
import SwiftUI

// MARK: - Theme (pastel)
enum Pastel {
    static let bg = Color(red: 0.96, green: 0.97, blue: 1.00)        // soft blue-ish
    static let tile = Color(red: 0.95, green: 0.92, blue: 1.00)      // lilac
    static let tileStroke = Color.black.opacity(0.08)
    static let accent = Color(red: 0.78, green: 0.88, blue: 0.98)    // sky
    static let success = Color(red: 0.78, green: 0.94, blue: 0.82)   // mint
    static let text = Color.black.opacity(0.85)
}

// MARK: - Core types
struct GameProgress: Codable {
    var currentIndex: Int = 0            // 0 = A ... 25 = Z
    var bestTimes: [Int: TimeInterval] = [:] // letterIndex -> seconds (lower is better)
}

struct RowSpec: Codable, Identifiable, Equatable {
    let id = UUID()
    let lockedLetter: Character          // e.g. "A"
    let lockedPosition: Int              // nominal 1...5 (may be overridden per letter)
    let answer: String                   // uppercase 5 letters
    let hint: String
    
    private enum CodingKeys: String, CodingKey {
        case lockedLetter, lockedPosition, answer, hint
    }
}

struct LetterLevel: Codable {
    let letterName: String               // "A"..."Z"
    let rows: [RowSpec]                  // 5 rows
}

enum Alpha {
    static let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map(String.init)
}

// MARK: - Per-letter column override for hard letters on row 5
// Keys are letter -> rowIndex (0-based) -> actual locked column
// All other rows/letters follow column = rowIndex+1
let LockedColumnOverride: [String: [Int: Int]] = [
    // J: row5 uses column4
    "J": [4: 4],
    // Q: row5 uses column4 (still tough but fair)
    "Q": [4: 4],
    // X: row5 uses column4
    "X": [4: 4],
    // Z: row5 uses column4
    "Z": [4: 4],
]

// Helper to resolve locked column (1...5)
func lockedColumn(for letter: String, rowIndex: Int) -> Int {
    if let m = LockedColumnOverride[letter], let v = m[rowIndex] { return v }
    return rowIndex + 1
}

// MARK: - Word Bank (A→Z)
// NOTE: Each row places the letter at column = row (1..5) unless overridden above.
// Hints kept short & friendly.

enum WordBank {
    static func rows(for index: Int) -> [RowSpec]? {
        guard index >= 0 && index < 26 else { return nil }
        let letter = Alpha.letters[index]
        switch letter {
        case "A": return A
        case "B": return B
        case "C": return C
        case "D": return D
        case "E": return E
        case "F": return F
        case "G": return G
        case "H": return H
        case "I": return I
        case "J": return J
        case "K": return K
        case "L": return L
        case "M": return M
        case "N": return N
        case "O": return O
        case "P": return P
        case "Q": return Q
        case "R": return R
        case "S": return S
        case "T": return T
        case "U": return U
        case "V": return V
        case "W": return W
        case "X": return X
        case "Y": return Y
        case "Z": return Z
        default: return nil
        }
    }

    // A
    static let A: [RowSpec] = [
        .init(lockedLetter: "A", lockedPosition: 1, answer: "APPLE", hint: "Keeps the doc away."),
        .init(lockedLetter: "A", lockedPosition: 2, answer: "CANDY", hint: "Sweet treat."),
        .init(lockedLetter: "A", lockedPosition: 3, answer: "PEARL", hint: "Oyster treasure."),
        .init(lockedLetter: "A", lockedPosition: 4, answer: "IDEAL", hint: "Perfect standard."),
        .init(lockedLetter: "A", lockedPosition: 5, answer: "PIZZA", hint: "Cheesy slice.")
    ]

    // B
    static let B: [RowSpec] = [
        .init(lockedLetter: "B", lockedPosition: 1, answer: "BREAD", hint: "Bakery staple."),
        .init(lockedLetter: "B", lockedPosition: 2, answer: "ABIDE", hint: "Tolerate."),
        .init(lockedLetter: "B", lockedPosition: 3, answer: "ROBIN", hint: "Red-breasted bird."),
        .init(lockedLetter: "B", lockedPosition: 4, answer: "GLOBE", hint: "Model of Earth."),
        .init(lockedLetter: "B", lockedPosition: 5, answer: "KEBAB", hint: "Skewered meal.")
    ]

    // C
    static let C: [RowSpec] = [
        .init(lockedLetter: "C", lockedPosition: 1, answer: "CLOUD", hint: "Sky fluff."),
        .init(lockedLetter: "C", lockedPosition: 2, answer: "ACORN", hint: "Oak seed."),
        .init(lockedLetter: "C", lockedPosition: 3, answer: "FOCAL", hint: "Central point."),
        .init(lockedLetter: "C", lockedPosition: 4, answer: "TEACH", hint: "Tutor does this."),
        .init(lockedLetter: "C", lockedPosition: 5, answer: "MIMIC", hint: "Copycat.")
    ]

    // D
    static let D: [RowSpec] = [
        .init(lockedLetter: "D", lockedPosition: 1, answer: "DRIVE", hint: "Operate a car."),
        .init(lockedLetter: "D", lockedPosition: 2, answer: "ADORE", hint: "Love deeply."),
        .init(lockedLetter: "D", lockedPosition: 3, answer: "IDLER", hint: "One who loafs."),
        .init(lockedLetter: "D", lockedPosition: 4, answer: "BLADE", hint: "On a knife."),
        .init(lockedLetter: "D", lockedPosition: 5, answer: "FLUID", hint: "Liquid or gas.")
    ]

    // E
    static let E: [RowSpec] = [
        .init(lockedLetter: "E", lockedPosition: 1, answer: "EAGLE", hint: "Majestic bird."),
        .init(lockedLetter: "E", lockedPosition: 2, answer: "REBEL", hint: "One who resists."),
        .init(lockedLetter: "E", lockedPosition: 3, answer: "SHEEN", hint: "Glossy shine."),
        .init(lockedLetter: "E", lockedPosition: 4, answer: "THEME", hint: "Central idea."),
        .init(lockedLetter: "E", lockedPosition: 5, answer: "SMILE", hint: "Happy face.")
    ]

    // F
    static let F: [RowSpec] = [
        .init(lockedLetter: "F", lockedPosition: 1, answer: "FLAME", hint: "Fire tongue."),
        .init(lockedLetter: "F", lockedPosition: 2, answer: "AFTER", hint: "Opposite of before."),
        .init(lockedLetter: "F", lockedPosition: 3, answer: "SAFER", hint: "Less risky."),
        .init(lockedLetter: "F", lockedPosition: 4, answer: "ROOFS", hint: "Top of houses."),
        .init(lockedLetter: "F", lockedPosition: 5, answer: "SCARF", hint: "Neck warmer.")
    ]

    // G
    static let G: [RowSpec] = [
        .init(lockedLetter: "G", lockedPosition: 1, answer: "GRAPE", hint: "Vine fruit."),
        .init(lockedLetter: "G", lockedPosition: 2, answer: "AGREE", hint: "Say yes."),
        .init(lockedLetter: "G", lockedPosition: 3, answer: "TIGER", hint: "Striped cat."),
        .init(lockedLetter: "G", lockedPosition: 4, answer: "SINGE", hint: "Lightly burn."),
        .init(lockedLetter: "G", lockedPosition: 5, answer: "ALONG", hint: "Together with.")
    ]

    // H
    static let H: [RowSpec] = [
        .init(lockedLetter: "H", lockedPosition: 1, answer: "HOUSE", hint: "Where you live."),
        .init(lockedLetter: "H", lockedPosition: 2, answer: "AHEAD", hint: "In front."),
        .init(lockedLetter: "H", lockedPosition: 3, answer: "OTHER", hint: "Different one."),
        .init(lockedLetter: "H", lockedPosition: 4, answer: "NORTH", hint: "Compass point."),
        .init(lockedLetter: "H", lockedPosition: 5, answer: "SMASH", hint: "Break hard.")
    ]

    // I
    static let I: [RowSpec] = [
        .init(lockedLetter: "I", lockedPosition: 1, answer: "IVORY", hint: "Elephant tusk material."),
        .init(lockedLetter: "I", lockedPosition: 2, answer: "AIDER", hint: "Helper."),
        .init(lockedLetter: "I", lockedPosition: 3, answer: "RAILS", hint: "Tracks."),
        .init(lockedLetter: "I", lockedPosition: 4, answer: "TONIC", hint: "Fizzy drink."),
        .init(lockedLetter: "I", lockedPosition: 5, answer: "SUSHI", hint: "Rice & fish.")
    ]

    // J (row5 uses col4 override)
    static let J: [RowSpec] = [
        .init(lockedLetter: "J", lockedPosition: 1, answer: "JELLY", hint: "Wobbly sweet."),
        .init(lockedLetter: "J", lockedPosition: 2, answer: "ENJOY", hint: "Take pleasure in."),
        .init(lockedLetter: "J", lockedPosition: 3, answer: "MAJOR", hint: "Above minor."),
        .init(lockedLetter: "J", lockedPosition: 4, answer: "NINJA", hint: "Stealthy warrior."),
        .init(lockedLetter: "J", lockedPosition: 4, answer: "BANJO", hint: "String instrument.")
    ]

    // K
    static let K: [RowSpec] = [
        .init(lockedLetter: "K", lockedPosition: 1, answer: "KNIFE", hint: "Cutting tool."),
        .init(lockedLetter: "K", lockedPosition: 2, answer: "KAYAK", hint: "Paddle boat."),
        .init(lockedLetter: "K", lockedPosition: 3, answer: "SKEIN", hint: "Coil of yarn."),
        .init(lockedLetter: "K", lockedPosition: 4, answer: "BLOKE", hint: "Man (UK)."),
        .init(lockedLetter: "K", lockedPosition: 5, answer: "SMOCK", hint: "Loose garment.")
    ]

    // L
    static let L: [RowSpec] = [
        .init(lockedLetter: "L", lockedPosition: 1, answer: "LEMON", hint: "Sour fruit."),
        .init(lockedLetter: "L", lockedPosition: 2, answer: "ALARM", hint: "Wake-up sound."),
        .init(lockedLetter: "L", lockedPosition: 3, answer: "COALS", hint: "Fuel in a grate."),
        .init(lockedLetter: "L", lockedPosition: 4, answer: "WOULD", hint: "Modal verb."),
        .init(lockedLetter: "L", lockedPosition: 5, answer: "PETAL", hint: "Part of a flower.")
    ]

    // M
    static let M: [RowSpec] = [
        .init(lockedLetter: "M", lockedPosition: 1, answer: "MANGO", hint: "Tropical fruit."),
        .init(lockedLetter: "M", lockedPosition: 2, answer: "AMONG", hint: "Surrounded by."),
        .init(lockedLetter: "M", lockedPosition: 3, answer: "TIMER", hint: "Counts seconds."),
        .init(lockedLetter: "M", lockedPosition: 4, answer: "GAMMA", hint: "Greek letter."),
        .init(lockedLetter: "M", lockedPosition: 5, answer: "TOTEM", hint: "Tribal emblem.")
    ]

    // N
    static let N: [RowSpec] = [
        .init(lockedLetter: "N", lockedPosition: 1, answer: "NURSE", hint: "Hospital helper."),
        .init(lockedLetter: "N", lockedPosition: 2, answer: "ANNOY", hint: "Irritate."),
        .init(lockedLetter: "N", lockedPosition: 3, answer: "DINER", hint: "Casual eatery."),
        .init(lockedLetter: "N", lockedPosition: 4, answer: "RANCH", hint: "Cattle farm."),
        .init(lockedLetter: "N", lockedPosition: 5, answer: "SCORN", hint: "Open dislike.")
    ]

    // O
    static let O: [RowSpec] = [
        .init(lockedLetter: "O", lockedPosition: 1, answer: "OCEAN", hint: "Big blue."),
        .init(lockedLetter: "O", lockedPosition: 2, answer: "BOARD", hint: "Flat plank."),
        .init(lockedLetter: "O", lockedPosition: 3, answer: "FOYER", hint: "Entrance hall."),
        .init(lockedLetter: "O", lockedPosition: 4, answer: "PRONE", hint: "Face-down."),
        .init(lockedLetter: "O", lockedPosition: 5, answer: "TANGO", hint: "A dance.")
    ]

    // P
    static let P: [RowSpec] = [
        .init(lockedLetter: "P", lockedPosition: 1, answer: "PANDA", hint: "Black & white bear."),
        .init(lockedLetter: "P", lockedPosition: 2, answer: "OPERA", hint: "Grand singing."),
        .init(lockedLetter: "P", lockedPosition: 3, answer: "RIPEN", hint: "Become ready to eat."),
        .init(lockedLetter: "P", lockedPosition: 4, answer: "ALPHA", hint: "First letter."),
        .init(lockedLetter: "P", lockedPosition: 5, answer: "SCALP", hint: "Top of the head.")
    ]

    // Q (row5 uses col4 override)
    static let Q: [RowSpec] = [
        .init(lockedLetter: "Q", lockedPosition: 1, answer: "QUILT", hint: "Bed cover."),
        .init(lockedLetter: "Q", lockedPosition: 2, answer: "EQUAL", hint: "Same as."),
        .init(lockedLetter: "Q", lockedPosition: 3, answer: "SQUID", hint: "Ocean creature."),
        .init(lockedLetter: "Q", lockedPosition: 4, answer: "QUART", hint: "Liquid measure."),
        .init(lockedLetter: "Q", lockedPosition: 4, answer: "SQUAD", hint: "Small team.")
    ]

    // R
    static let R: [RowSpec] = [
        .init(lockedLetter: "R", lockedPosition: 1, answer: "ROAST", hint: "Cook in oven."),
        .init(lockedLetter: "R", lockedPosition: 2, answer: "ARISE", hint: "Get up."),
        .init(lockedLetter: "R", lockedPosition: 3, answer: "CROWN", hint: "On a king."),
        .init(lockedLetter: "R", lockedPosition: 4, answer: "FERRY", hint: "Boat shuttle."),
        .init(lockedLetter: "R", lockedPosition: 5, answer: "SOLAR", hint: "Sun-related.")
    ]

    // S
    static let S: [RowSpec] = [
        .init(lockedLetter: "S", lockedPosition: 1, answer: "SUGAR", hint: "Sweet crystals."),
        .init(lockedLetter: "S", lockedPosition: 2, answer: "ASIDE", hint: "To the side."),
        .init(lockedLetter: "S", lockedPosition: 3, answer: "BASIC", hint: "Not complex."),
        .init(lockedLetter: "S", lockedPosition: 4, answer: "MOOSE", hint: "Large deer."),
        .init(lockedLetter: "S", lockedPosition: 5, answer: "CLASS", hint: "School period.")
    ]

    // T
    static let T: [RowSpec] = [
        .init(lockedLetter: "T", lockedPosition: 1, answer: "TANGO", hint: "Dance."),
        .init(lockedLetter: "T", lockedPosition: 2, answer: "OTTER", hint: "River swimmer."),
        .init(lockedLetter: "T", lockedPosition: 3, answer: "LATTE", hint: "Coffee with milk."),
        .init(lockedLetter: "T", lockedPosition: 4, answer: "PHOTO", hint: "A picture."),
        .init(lockedLetter: "T", lockedPosition: 5, answer: "SHOUT", hint: "Yell loudly.")
    ]

    // U
    static let U: [RowSpec] = [
        .init(lockedLetter: "U", lockedPosition: 1, answer: "ULTRA", hint: "Beyond normal."),
        .init(lockedLetter: "U", lockedPosition: 2, answer: "AUDIO", hint: "Sound."),
        .init(lockedLetter: "U", lockedPosition: 3, answer: "SAUCE", hint: "Gravy."),
        .init(lockedLetter: "U", lockedPosition: 4, answer: "THUMB", hint: "Short, thick digit."),
        .init(lockedLetter: "U", lockedPosition: 5, answer: "DATUM", hint: "Data point.")
    ]

    // V
    static let V: [RowSpec] = [
        .init(lockedLetter: "V", lockedPosition: 1, answer: "VIVID", hint: "Bright, intense."),
        .init(lockedLetter: "V", lockedPosition: 2, answer: "OVERT", hint: "Not hidden."),
        .init(lockedLetter: "V", lockedPosition: 3, answer: "RIVER", hint: "Flows to sea."),
        .init(lockedLetter: "V", lockedPosition: 4, answer: "SOLVE", hint: "Find answer."),
        .init(lockedLetter: "V", lockedPosition: 5, answer: "NERVE", hint: "Courage.")
    ]

    // W
    static let W: [RowSpec] = [
        .init(lockedLetter: "W", lockedPosition: 1, answer: "WATER", hint: "H2O."),
        .init(lockedLetter: "W", lockedPosition: 2, answer: "AWAKE", hint: "Not asleep."),
        .init(lockedLetter: "W", lockedPosition: 3, answer: "BOWER", hint: "Garden shelter."),
        .init(lockedLetter: "W", lockedPosition: 4, answer: "STRAW", hint: "Sipper."),
        .init(lockedLetter: "W", lockedPosition: 5, answer: "SCREW", hint: "Threaded fastener.")
    ]

    // X (row5 uses col4 override)
    static let X: [RowSpec] = [
        .init(lockedLetter: "X", lockedPosition: 1, answer: "XENON", hint: "Noble gas."),
        .init(lockedLetter: "X", lockedPosition: 2, answer: "AXIOM", hint: "Self-evident truth."),
        .init(lockedLetter: "X", lockedPosition: 3, answer: "PIXEL", hint: "Screen dot."),
        .init(lockedLetter: "X", lockedPosition: 4, answer: "INDEX", hint: "Back-of-book list."),
        .init(lockedLetter: "X", lockedPosition: 4, answer: "SIXTY", hint: "Number 60.")
    ]

    // Y
    static let Y: [RowSpec] = [
        .init(lockedLetter: "Y", lockedPosition: 1, answer: "YOUNG", hint: "Not old."),
        .init(lockedLetter: "Y", lockedPosition: 2, answer: "LOYAL", hint: "Faithful."),
        .init(lockedLetter: "Y", lockedPosition: 3, answer: "RHYME", hint: "Poetic echo."),
        .init(lockedLetter: "Y", lockedPosition: 4, answer: "PARTY", hint: "Social gathering."),
        .init(lockedLetter: "Y", lockedPosition: 5, answer: "HONEY", hint: "Bee product.")
    ]

    // Z (row5 uses col4 override)
    static let Z: [RowSpec] = [
        .init(lockedLetter: "Z", lockedPosition: 1, answer: "ZEBRA", hint: "Striped animal."),
        .init(lockedLetter: "Z", lockedPosition: 2, answer: "OZONE", hint: "O3 layer."),
        .init(lockedLetter: "Z", lockedPosition: 3, answer: "AZURE", hint: "Sky blue."),
        .init(lockedLetter: "Z", lockedPosition: 4, answer: "FIZZY", hint: "Bubbly."),
        .init(lockedLetter: "Z", lockedPosition: 4, answer: "PIZZA", hint: "Cheesy slice.")
    ]
}
