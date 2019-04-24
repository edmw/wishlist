extension Character {

    var isASCII: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }

}
