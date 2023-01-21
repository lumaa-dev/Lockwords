//Made by Lumaa

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct Password: Codable, Identifiable, Hashable {
    var id = UUID()
    var source: String
    var username: String
    var password: String
    
    init(source: String, username: String, password: String) {
        self.id = UUID()
        self.source = source
        self.username = username
        self.password = password
    }
    
    static func save(_ psds: [Password]) {
        do {
            let object = try JSONEncoder().encode(psds)
            UserDefaults.standard.set(object, forKey: "passwords")
        } catch {
            print(error)
        }
    }
    
    static func load(_ array: [Password] = []) -> [Password] {
        var newArray = [Password]()
        let decoder = JSONDecoder()
        if  let object = UserDefaults.standard.value(forKey: "passwords") as? Data {
            do {
                let ideas = try decoder.decode([Password].self, from: object)

                newArray = array
                for idea in ideas {
                    newArray.append(idea)
                }
                
                return newArray
            } catch {
                print(error)
            }
        } else {
            print("unable to fetch the data from passwords key in user defaults")
        }
        return []
    }
}

struct InputDoument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var input: String

    init(input: String) {
        self.input = input
    }

    init(configuration: FileDocumentReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        input = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: input.data(using: .utf8)!)
    }
}

struct JSONFile: FileDocument {
    static var readableContentTypes = [UTType.json]

    var object: Data? = nil

    init(initialText: Data) {
        object = initialText
    }

    init(configuration: ReadConfiguration) throws {
        if configuration.file.regularFileContents != nil {
            object = UserDefaults.standard.data(forKey: "passwords") as Data?
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        if object != nil {
            return FileWrapper(regularFileWithContents: object!)
        } else {
            return FileWrapper(regularFileWithContents: UserDefaults.standard.data(forKey: "passwords")!)
        }
    }
}

func saveLocks() {
    let filename = getDocumentsDirectory().appendingPathComponent("lockwords_\(Date.now.description.trimmingCharacters(in: .whitespacesAndNewlines)).json")

    do {
        try UserDefaults.standard.string(forKey: "passwords")?.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        print("Missing permissions.")
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
    print(paths[0])
    return paths[0]
}
