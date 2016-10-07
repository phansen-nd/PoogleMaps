//
//  DataDownloader.swift
//  PoogleMaps
//
//  Created by Patrick Hansen on 10/7/16.
//  Copyright © 2016 Patrick Hansen. All rights reserved.
//

import Foundation

class DataDownloader {

    private var fileSaver = FileSaver()
    
    func downloadAndSaveImage(withURL url: URL, name: String, completion: @escaping () -> Void) {
        print("Image download began.")
        
        // Should already be in the background, so save it here.
        getDataFromURL(url: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error downloading data: \(error)")
                return
            }
            print("Image download complete.")
            
            // Now that it's downloaded, save it.
            guard let image = UIImage(data: data)  else {
                print("Data from URL could not be constructed into an image: \(url)")
                return
            }
            let result = self.fileSaver.saveImage(image: image, named: name)
            if result {
                print("Successfully saved image.")
            } else {
                print("FileSaver couldn't save image.")
            }
            
            // Do things with the knowledge that image has been saved or not, but isn't mid-save.
            completion()
        }
    }
    
    func getDataFromURL(url: URL, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
     
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            completion(data, response, error)
        }.resume()
    }
}
