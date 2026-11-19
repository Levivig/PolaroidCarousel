import SwiftUI

struct Postcard: Equatable {
    let title: String
    let subtitle: String
    let note: String
    let sky: Color
    let horizon: Color
    let sun: Color
    let land: Color
    let ridge: Color
    let sunX: CGFloat
    let peaks: [CGFloat]

    static let deck = [
        Self(title: "Juniper Ridge", subtitle: "01 · An alpine morning",
             note: "The ridge was quiet before the sun cleared the saddle. We stopped for coffee where the junipers gave way to loose stone.",
             sky: Color(red: 0.32, green: 0.57, blue: 0.62), horizon: Color(red: 0.77, green: 0.86, blue: 0.79),
             sun: Color(red: 1, green: 0.88, blue: 0.62), land: Color(red: 0.15, green: 0.36, blue: 0.33),
             ridge: Color(red: 0.29, green: 0.51, blue: 0.45), sunX: 0.72, peaks: [0.59, 0.32, 0.56, 0.42, 0.59]),
        Self(title: "Red Mesa", subtitle: "02 · Sandstone at noon",
             note: "From the trail, the mesa looked like one solid wall. Up close, it was thin layers of rust and ochre with little pockets of shade.",
             sky: Color(red: 0.84, green: 0.40, blue: 0.32), horizon: Color(red: 0.99, green: 0.70, blue: 0.49),
             sun: Color(red: 1, green: 0.89, blue: 0.66), land: Color(red: 0.49, green: 0.20, blue: 0.22),
             ridge: Color(red: 0.71, green: 0.31, blue: 0.24), sunX: 0.28, peaks: [0.60, 0.62, 0.41, 0.41, 0.58]),
        Self(title: "Blue Hour", subtitle: "03 · The last of the light",
             note: "We waited until the far peaks disappeared into the sky. For a few minutes the whole valley was blue, even the road home.",
             sky: Color(red: 0.17, green: 0.22, blue: 0.43), horizon: Color(red: 0.53, green: 0.53, blue: 0.74),
             sun: Color(red: 0.89, green: 0.89, blue: 1), land: Color(red: 0.16, green: 0.20, blue: 0.34),
             ridge: Color(red: 0.32, green: 0.35, blue: 0.57), sunX: 0.52, peaks: [0.57, 0.45, 0.51, 0.38, 0.56]),
        Self(title: "Tidal Flats", subtitle: "04 · Where the water goes",
             note: "The tide left a map of shallow channels in the sand. A heron walked straight across it, one careful step at a time.",
             sky: Color(red: 0.34, green: 0.65, blue: 0.67), horizon: Color(red: 0.83, green: 0.93, blue: 0.82),
             sun: Color(red: 1, green: 0.97, blue: 0.73), land: Color(red: 0.11, green: 0.46, blue: 0.44),
             ridge: Color(red: 0.33, green: 0.61, blue: 0.53), sunX: 0.42, peaks: [0.53, 0.61, 0.56, 0.58, 0.51]),
        Self(title: "Frost Line", subtitle: "05 · Tracks in fresh snow",
             note: "The first snow stopped at the tree line. Just above it, we found a single set of tracks that curved out of sight.",
             sky: Color(red: 0.45, green: 0.52, blue: 0.67), horizon: Color(red: 0.86, green: 0.90, blue: 0.96),
             sun: Color(red: 1, green: 0.90, blue: 0.86), land: Color(red: 0.37, green: 0.47, blue: 0.60),
             ridge: Color(red: 0.77, green: 0.83, blue: 0.92), sunX: 0.78, peaks: [0.63, 0.44, 0.56, 0.30, 0.64]),
    ]
}
