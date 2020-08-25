//
//  StorageManeger.swift
//  Messanger
//
//  Created by Nima on 8/15/20.
//  Copyright © 2020 Nima. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManeger {
    static let shared = StorageManeger()
    
    private let storage = Storage.storage().reference()
    
    
    public typealias UploadPictureComplition = (Result<String, Error>) -> Void
    // upload pics to firebase and retur nURL to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureComplition) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                //faile
                print("failed to upload data to firebase to upload pics")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadurl))
                    return
                }
                let urlSring = url.absoluteString
                print("download url returen \(urlSring)")
                completion(.success(urlSring))
            })
        })
    }
    
    // upload image that will be sent in a convo message
       public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureComplition) {
           storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: {[weak self] metadata, error in
               guard error == nil else {
                   //faile
                   print("failed to upload data to firebase to upload pics")
                   completion(.failure(StorageErrors.failedToUpload))
                   return
               }
               self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                   guard let url = url else{
                       print("failed to get download url")
                       completion(.failure(StorageErrors.failedToGetDownloadurl))
                       return
                   }
                let urlSring = url.absoluteString
                print("download url returen \(urlSring)")
                completion(.success(urlSring))
               })
           })
    }
    
    // upload Video that will be sent in a convo message
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureComplition) {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                //faile
                print("failed to upload Video file to firebase ")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else{
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadurl))
                    return
                }
                let urlSring = url.absoluteString
                print("download url returen \(urlSring)")
                completion(.success(urlSring))
            })
        })
    }
    
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadurl
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadurl))
                return
            }
            
            completion(.success(url))
        })
        
        
    }
    
    
}
