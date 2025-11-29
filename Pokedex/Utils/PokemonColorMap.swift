//
//  PokemonColorMap.swift
//  Pokedex
//
//  Extracted color mapping for all 151 Generation 1 Pokémon
//

import SwiftUI

struct PokemonColorMap {
    static func getColor(for id: Int) -> Color {
        let colorHex = colorMap[id] ?? "#A8A878" // Default color
        return Color(hex: colorHex)
    }
    
    private static let colorMap: [Int: String] = [
        // Bulbasaur line
        1: "#009A9A",
        2: "#009986",
        3: "#00B79D",
        
        // Charmander line
        4: "#FF9231",
        5: "#DF313A",
        6: "#FC7F04",
        
        // Squirtle line
        7: "#80C7CF",
        8: "#88AFFB",
        9: "#5190D1",
        
        // Caterpie line
        10: "#9BC24C",
        11: "#8FBC48",
        12: "#FFF17C",
        
        // Weedle line
        13: "#E2C548",
        14: "#F8D030",
        15: "#E8B708",
        
        // Pidgey line
        16: "#A8A878",
        17: "#A19067",
        18: "#B5916C",
        
        // Rattata line
        19: "#9B7A94",
        20: "#C29D42",
        
        // Spearow line
        21: "#A65C42",
        22: "#B87740",
        
        // Ekans line
        23: "#A552CC",
        24: "#7C3E98",
        
        // Pikachu line
        25: "#F8D030",
        26: "#E89508",
        
        // Sandshrew line
        27: "#E8D48C",
        28: "#D8BC5C",
        
        // Nidoran♀ line
        29: "#7BA5D8",
        30: "#7A9FD0",
        31: "#78A3D0",
        
        // Nidoran♂ line
        32: "#D0789D",
        33: "#C273B0",
        34: "#BB6AA8",
        
        // Clefairy line
        35: "#F8A5E0",
        36: "#F89CE0",
        
        // Vulpix line
        37: "#F08C30",
        38: "#F8B030",
        
        // Jigglypuff line
        39: "#F8B8D8",
        40: "#F5A8C8",
        
        // Zubat line
        41: "#A890F0",
        42: "#A882F0",
        
        // Oddish line
        43: "#78C850",
        44: "#70B848",
        45: "#C83848",
        
        // Paras line
        46: "#F08030",
        47: "#E86830",
        
        // Venonat line
        48: "#A8A878",
        49: "#A040A0",
        
        // Diglett line
        50: "#E0C068",
        51: "#D8B860",
        
        // Meowth line
        52: "#F8D87C",
        53: "#E8C860",
        
        // Psyduck line
        54: "#F8D030",
        55: "#6890F0",
        
        // Mankey line
        56: "#C89868",
        57: "#C08848",
        
        // Growlithe line
        58: "#F08030",
        59: "#EE8130",
        
        // Poliwag line
        60: "#6890F0",
        61: "#5888E0",
        62: "#4879D8",
        
        // Abra line
        63: "#F8D030",
        64: "#F08030",
        65: "#F07030",
        
        // Machop line
        66: "#888898",
        67: "#808088",
        68: "#707078",
        
        // Bellsprout line
        69: "#78C850",
        70: "#70B840",
        71: "#A8B820",
        
        // Tentacool line
        72: "#6890F0",
        73: "#5880E0",
        
        // Geodude line
        74: "#B8A038",
        75: "#A89028",
        76: "#988018",
        
        // Ponyta line
        77: "#F08030",
        78: "#F08030",
        
        // Slowpoke line
        79: "#F85888",
        80: "#F84878",
        
        // Magnemite line
        81: "#B8B8D0",
        82: "#A8A8C0",
        
        // Farfetch'd
        83: "#A8B820",
        
        // Doduo line
        84: "#A8A878",
        85: "#A89868",
        
        // Seel line
        86: "#98D8D8",
        87: "#88C8C8",
        
        // Grimer line
        88: "#A040A0",
        89: "#9030A0",
        
        // Shellder line
        90: "#6890F0",
        91: "#5880D8",
        
        // Gastly line
        92: "#705898",
        93: "#604888",
        94: "#503878",
        
        // Onix
        95: "#B8A038",
        
        // Drowzee line
        96: "#F8D030",
        97: "#E8C030",
        
        // Krabby line
        98: "#EE8130",
        99: "#DD7020",
        
        // Voltorb line
        100: "#F85888",
        101: "#E84878",
        
        // Exeggcute line
        102: "#F8A5C0",
        103: "#F8D030",
        
        // Cubone line
        104: "#C89868",
        105: "#B88858",
        
        // Hitmonlee
        106: "#C03028",
        
        // Hitmonchan
        107: "#B82818",
        
        // Lickitung
        108: "#F8A8B8",
        
        // Koffing line
        109: "#A890F0",
        110: "#9880E0",
        
        // Rhyhorn line
        111: "#B8A038",
        112: "#A89028",
        
        // Chansey
        113: "#F8A8B8",
        
        // Tangela
        114: "#78C850",
        
        // Kangaskhan
        115: "#C89868",
        
        // Horsea line
        116: "#6890F0",
        117: "#5880D8",
        
        // Goldeen line
        118: "#F8A030",
        119: "#E89020",
        
        // Staryu line
        120: "#B8A8D8",
        121: "#A898C8",
        
        // Mr. Mime
        122: "#F8A8B8",
        
        // Scyther
        123: "#A8B820",
        
        // Jynx
        124: "#F8A8E8",
        
        // Electabuzz
        125: "#F8D030",
        
        // Magmar
        126: "#F08030",
        
        // Pinsir
        127: "#A8B820",
        
        // Tauros
        128: "#C89868",
        
        // Magikarp line
        129: "#F08030",
        130: "#6890F0",
        
        // Lapras
        131: "#6890F0",
        
        // Ditto
        132: "#A8A8F8",
        
        // Eevee line
        133: "#C89868",
        134: "#6890F0",
        135: "#F8D030",
        136: "#F08030",
        
        // Porygon
        137: "#F8A8F8",
        
        // Omanyte line
        138: "#6890F0",
        139: "#5880D8",
        
        // Kabuto line
        140: "#B8A038",
        141: "#A89028",
        
        // Aerodactyl
        142: "#A890F0",
        
        // Snorlax
        143: "#7888A0",
        
        // Articuno
        144: "#98D8D8",
        
        // Zapdos
        145: "#F8D030",
        
        // Moltres
        146: "#F08030",
        
        // Dratini line
        147: "#7038F8",
        148: "#6028E8",
        149: "#5018D8",
        
        // Mewtwo
        150: "#A890F0",
        
        // Mew
        151: "#F8A8B8"
    ]
}
