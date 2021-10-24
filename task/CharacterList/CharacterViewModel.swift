//
//  CharacterViewModel.swift
//  task
//
//  Created by Harun Cem DERE on 24.10.2021.
//

import Foundation

class CharacterViewModel {
    let id: Int
    let name: String
    let description: String
    let thumbnail: Dictionary<String, Any>
    let comics: Dictionary<String, Any>

    init(repository: Repository) {
        self.id = repository.id
        self.name = repository.fullName
        self.description = repository.description
        self.thumbnail = repository.thumbnail
        self.comics = repository.comics
    }
    
    func getImageUrl() -> String?{
        let path = thumbnail["path"] as? String
        let ext = thumbnail["extension"] as? String
        if let path = path, let ext = ext{
            return "\(path).\(ext)"
        }
        return nil
    }
}
