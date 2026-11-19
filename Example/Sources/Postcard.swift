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
             note: """
             The ridge was quiet before the sun cleared the saddle. We stopped for coffee where the junipers gave way to loose stone. The wind kept lifting the corner of my map, so I held it down with a pebble.

             Farther up, the trail crossed a bank of old snow. The footprints from yesterday had frozen into little cups. We followed them one at a time, then emptied the gravel out of our boots on the other side.

             By midmorning the clouds had dropped below us. A single peak stuck out across the valley, and for a while we could hear a creek we couldn't see. We split the last orange and watched the clouds pull apart.

             On the way down, we found the pebble still sitting where we'd stopped for coffee. I left it there for the next person with a map.
             """,
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
        Self(title: "Copper Dunes", subtitle: "06 · Sand in our shoes",
             note: "Wind had swept the ridge clean overnight. We left footprints on one side and watched the sand fill them in behind us.",
             sky: Color(red: 0.91, green: 0.66, blue: 0.41), horizon: Color(red: 0.99, green: 0.84, blue: 0.56),
             sun: Color(red: 1, green: 0.94, blue: 0.71), land: Color(red: 0.62, green: 0.30, blue: 0.16),
             ridge: Color(red: 0.78, green: 0.48, blue: 0.26), sunX: 0.36, peaks: [0.66, 0.45, 0.50, 0.37, 0.56]),
        Self(title: "Moss Hollow", subtitle: "07 · Rain under the cedars",
             note: "We could hear the rain overhead, but the trail stayed dry under the cedars. At the creek, the moss was bright enough to look lit from inside.",
             sky: Color(red: 0.40, green: 0.59, blue: 0.46), horizon: Color(red: 0.78, green: 0.84, blue: 0.62),
             sun: Color(red: 0.94, green: 0.94, blue: 0.68), land: Color(red: 0.19, green: 0.34, blue: 0.22),
             ridge: Color(red: 0.38, green: 0.52, blue: 0.29), sunX: 0.68, peaks: [0.45, 0.40, 0.62, 0.46, 0.43]),
        Self(title: "Glass Lake", subtitle: "08 · Before the first ripple",
             note: "We put the canoe in before breakfast. It left two clean lines across the reflection of the mountain.",
             sky: Color(red: 0.42, green: 0.68, blue: 0.83), horizon: Color(red: 0.82, green: 0.94, blue: 0.96),
             sun: Color(red: 1, green: 0.90, blue: 0.73), land: Color(red: 0.20, green: 0.45, blue: 0.65),
             ridge: Color(red: 0.39, green: 0.60, blue: 0.70), sunX: 0.32, peaks: [0.60, 0.54, 0.36, 0.51, 0.57]),
        Self(title: "Heather Pass", subtitle: "09 · A purple hillside",
             note: "Bees worked the whole slope. We sat on a flat stone and shared an apple without taking off our packs.",
             sky: Color(red: 0.57, green: 0.48, blue: 0.67), horizon: Color(red: 0.87, green: 0.76, blue: 0.86),
             sun: Color(red: 1, green: 0.89, blue: 0.74), land: Color(red: 0.37, green: 0.25, blue: 0.46),
             ridge: Color(red: 0.61, green: 0.40, blue: 0.60), sunX: 0.78, peaks: [0.53, 0.38, 0.55, 0.47, 0.61]),
        Self(title: "Salt Point", subtitle: "10 · Where the cliffs end",
             note: "At the end of the path, the spray reached higher than the fence. Everything in our pockets smelled like the sea on the way home.",
             sky: Color(red: 0.45, green: 0.57, blue: 0.69), horizon: Color(red: 0.78, green: 0.93, blue: 0.90),
             sun: Color(red: 0.96, green: 0.94, blue: 0.80), land: Color(red: 0.17, green: 0.39, blue: 0.46),
             ridge: Color(red: 0.29, green: 0.52, blue: 0.53), sunX: 0.64, peaks: [0.39, 0.39, 0.57, 0.56, 0.64]),
        Self(title: "Ember Valley", subtitle: "11 · The last warm evening",
             note: "The aspens were almost bare. One tree above the road still held its leaves, and from a distance it looked like a lantern.",
             sky: Color(red: 0.79, green: 0.49, blue: 0.39), horizon: Color(red: 0.98, green: 0.77, blue: 0.59),
             sun: Color(red: 1, green: 0.92, blue: 0.63), land: Color(red: 0.45, green: 0.26, blue: 0.25),
             ridge: Color(red: 0.67, green: 0.39, blue: 0.29), sunX: 0.29, peaks: [0.48, 0.51, 0.64, 0.39, 0.53]),
        Self(title: "Moon Basin", subtitle: "12 · After everyone left",
             note: "The gravel lot was empty when we got back. We switched off our headlamps and waited until we could see the moon in the puddles.",
             sky: Color(red: 0.19, green: 0.24, blue: 0.39), horizon: Color(red: 0.47, green: 0.55, blue: 0.71),
             sun: Color(red: 0.90, green: 0.95, blue: 0.98), land: Color(red: 0.15, green: 0.20, blue: 0.31),
             ridge: Color(red: 0.31, green: 0.37, blue: 0.54), sunX: 0.59, peaks: [0.42, 0.46, 0.65, 0.55, 0.44]),
        Self(title: "Gold Meadow", subtitle: "13 · The long way back",
             note: "We took the longer trail because it stayed in the sun. Grass seeds collected in our socks all the way to the gate.",
             sky: Color(red: 0.52, green: 0.71, blue: 0.79), horizon: Color(red: 0.92, green: 0.91, blue: 0.67),
             sun: Color(red: 1, green: 0.91, blue: 0.58), land: Color(red: 0.53, green: 0.44, blue: 0.20),
             ridge: Color(red: 0.70, green: 0.60, blue: 0.30), sunX: 0.72, peaks: [0.56, 0.48, 0.53, 0.44, 0.58]),
        Self(title: "Cloud Shelf", subtitle: "14 · Above the weather",
             note: "We spent most of the climb in fog. Then the trail turned, the sun came out, and we could see our shadows on the clouds below.",
             sky: Color(red: 0.49, green: 0.61, blue: 0.77), horizon: Color(red: 0.93, green: 0.92, blue: 0.96),
             sun: Color(red: 1, green: 0.97, blue: 0.86), land: Color(red: 0.32, green: 0.40, blue: 0.58),
             ridge: Color(red: 0.58, green: 0.65, blue: 0.76), sunX: 0.34, peaks: [0.63, 0.40, 0.46, 0.38, 0.55]),
        Self(title: "Willow Bend", subtitle: "15 · A slow river mile",
             note: "The river did most of the paddling for us. We drifted past a willow with its lowest branches trailing in the water.",
             sky: Color(red: 0.51, green: 0.75, blue: 0.71), horizon: Color(red: 0.87, green: 0.93, blue: 0.76),
             sun: Color(red: 1, green: 0.91, blue: 0.65), land: Color(red: 0.24, green: 0.44, blue: 0.33),
             ridge: Color(red: 0.44, green: 0.63, blue: 0.45), sunX: 0.65, peaks: [0.49, 0.55, 0.61, 0.44, 0.51]),
    ]
}
