//
//  FileSaver.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/7/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation

class FileSaver {
    
    func getDocumentsURL() -> URL {
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print("Docs url I retrieved: \(docsURL)")
        return docsURL
    }
    
    func filepathInDocumentsDirectory(with filename: String) -> URL {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL
    }
    
    func saveImage(image: UIImage, named name: String) -> Bool {
        let nameWithExtension = name + ".png"
        let path = filepathInDocumentsDirectory(with: nameWithExtension)
        let png = UIImagePNGRepresentation(image)
        
        do {
            try png?.write(to: path)
        } catch {
            print("Error saving image: \(error)")
            return false
        }
        print("Saved file \(nameWithExtension) to location: \(path)")
        return true
    }
    
    func loadImage(named name: String) -> UIImage? {
        
        let nameWithExtension = name + ".png"
        let fileURL = filepathInDocumentsDirectory(with: nameWithExtension)
        let image = UIImage(contentsOfFile: fileURL.path)
        
        print("Loading file at url: \(fileURL.path)")
        
        if image == nil {
            print("Error loading image named \(nameWithExtension)")
        }
        return image
    }
}
