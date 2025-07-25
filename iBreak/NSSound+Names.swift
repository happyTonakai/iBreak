import AppKit

// An extension to find system sounds from multiple common locations.
extension NSSound {
    static var soundNames: [String] {
        var soundNames = Set<String>()
        let fileManager = FileManager.default
        let audioFileExtensions = ["aiff", "aif", "wav", "mp3", "m4a"]

        // Define all the paths to search for sounds.
        let searchPaths = [
            NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first?.appending("/Sounds"),
            "/Library/Sounds",
            "/System/Library/Sounds",
            "/System/Library/Audio/UISounds"
        ].compactMap { $0 } // Remove any nil paths

        for path in searchPaths {
            guard let enumerator = fileManager.enumerator(atPath: path) else { continue }
            for case let file as String in enumerator {
                let fileExtension = (file as NSString).pathExtension.lowercased()
                if audioFileExtensions.contains(fileExtension) {
                    let soundName = (file as NSString).deletingPathExtension
                    soundNames.insert(soundName)
                }
            }
        }

        // Return a sorted list of unique sound names.
        return Array(soundNames).sorted()
    }
}