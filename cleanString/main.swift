//
//  main.swift
//  cleanString
//
//  Created by Jonathan Duss on 25.10.20.
//

import Foundation

print("\n\n\n========================================================================================")
print("CLEANING STRINGS")
print("========================================================================================")

try cleanAndSaveFiles()


func getFiles() -> [String] {
    var c = [String]()
    
    if CommandLine.arguments.count < 2 {
        print("First arg: file containing the keys to remove")
        print("Next args: files containing the translation and which should be cleaned")
        exit(EXIT_FAILURE)
    }
    
    for arg in CommandLine.arguments {
        c.append(arg)
    }
    
    c.remove(at: 0)
    c.remove(at: 0)
    
    return c
}

func getKeysToRemove() -> [String] {
    var c = [String]()
    
    if CommandLine.arguments.count < 2 {
        print("First arg: file containing the keys to remove")
        print("Next args: files containing the translation and which should be cleaned")
        exit(EXIT_FAILURE)
    }
    
    for arg in CommandLine.arguments {
        c.append(arg)
    }
    
    // Arg 0 if the current path.
    return keysInFile(CommandLine.arguments[1])
}


// MARK: - Cleaning

func cleanAndSaveFiles() throws {
    let files = getFiles()
    
    for file in files {
        print("\n\n\n---------------\nPROCESSING file \(file)\n---------------\n")
        
        let cleanedFileContent = cleanContentOfFile(file: file)
        
        try FileManager.default.removeItem(atPath: file)
        try cleanedFileContent.write(toFile: file, atomically: true, encoding: .utf8)
    }
}

func cleanContentOfFile(file: String) -> String {
    
    if (file as NSString).pathExtension != "strings" {
        print("Extension must be strings but was \((file as NSString).pathExtension) for file \(file)")
        exit(EXIT_FAILURE)
    }
    
    let fileLines = contentsOfFile(file).components(separatedBy: CharacterSet.newlines)
    
    var cleanedfileLines = [String]()
    
    var block = [String]()
    var keyBlock = [String]()
    var keyBlockStarted = false

    for line in fileLines {
        
        let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if trimmedLine == "" {
            block.append(String(line))
            continue
        }
        
        if trimmedLine.starts(with: "//") || trimmedLine.starts(with: "/*") {
            block.append(String(line))
            continue
        }
        
        if (trimmedLine.starts(with: "\"")) {
            keyBlockStarted = true
        }
        
        block.append(String(line))

        guard keyBlockStarted else { continue }
        
        
        keyBlock.append(String(line))
        
        if trimmedLine.last == ";" {
            
            let keyBlockString = keyBlock.joined()
            
            if shouldAddBlock(keyBlockString) {
                cleanedfileLines += block
                print("All good for block \(block.joined())")
            }
            else {
                print("Removing \(block.joined())")
            }
            
            block = []
            keyBlock = []
            keyBlockStarted = false
        }
    }

    return cleanedfileLines.joined(separator: "\n")
}

func shouldAddBlock(_ stringLine: String) -> Bool {
    
    for key in getKeysToRemove() {
        if stringLine.contains("\"\(key)\"") {
            print("The key \(key) has been found!")
            return false
        }
    }
    
    return true
    
}



// MARK: - Utilities

func keysInFile(_ filePath: String) -> [String] {
    do {
        var keys = try String(contentsOfFile: filePath).components(separatedBy: CharacterSet.newlines)
       
        keys.removeAll(where: {$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty})
        return keys.map({$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)})
    }
    catch {
        print("cannot read file \(filePath)!!!")
        exit(1)
    }
}

func contentsOfFile(_ filePath: String) -> String {
    do {
        return try String(contentsOfFile: filePath)
    }
    catch {
        print("cannot read file \(filePath)!!!")
        exit(1)
    }
}
