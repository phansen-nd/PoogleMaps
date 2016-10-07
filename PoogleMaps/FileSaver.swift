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
        let path = filepathInDocumentsDirectory(with: name)
        let png = UIImagePNGRepresentation(image)
        
        do {
            try png?.write(to: path)
        } catch {
            print("Error saving image: \(error)")
            return false
        }
        return true
    }
    
    func loadImage(named name: String) -> UIImage? {
        let fileURL = filepathInDocumentsDirectory(with: name)
        let image = UIImage(contentsOfFile: fileURL.absoluteString)
        
        if image == nil {
            print("Error loading image named \(name)")
        }
        return image
    }
}
