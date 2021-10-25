//
//  Service.swift
//  task
//
//  Created by Harun Cem DERE on 22.10.2021.
//

import Foundation
import RxSwift
import RxCocoa

enum ServiceError: Error {
    case cannotParse
}

class Service {

    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    let listLimit = 30
    var listOffset = 0
    
    var allCharacters = [Character]()

    func getCharacters(offset: Int) -> Observable<[Character]> {

        let ts = tsStringValue()
        let stringToHash = String(format: "%@%@%@", ts, Strings.marvelPrivatekey, Strings.marvelPublickey)
        let hash = stringToHash.md5()
        let link = String(format: "%@/characters?limit=%d&offset=%d&ts=%@&apikey=%@&hash=%@", Strings.marvelBaseUrl, listLimit, self.listOffset, ts, Strings.marvelPublickey, hash)
//        var url = baseUrl +  + limit + '&ts=' + ts + '&apikey=' + publickey + '&hash=' + hash;
        
        let url = URL(string: link)!
        
        return session.rx
            .json(url: url)
            .flatMap { json throws -> Observable<[Character]> in
                guard
                    let json = json as? [String: Any],
                    let data = json["data"] as? [String: Any],
                    let itemsJSON = data["results"] as? [[String: Any]]
                else { return Observable.error(ServiceError.cannotParse) }

                let characters = itemsJSON.compactMap(Character.init)
                self.allCharacters.append(contentsOf: characters)
                self.listOffset += 30
                return Observable.just(self.allCharacters)
            }
    }
    
    func getCharactersComics(characterId: Int) -> Observable<Dictionary<String, Any>> {

        let ts = tsStringValue()
        let stringToHash = String(format: "%@%@%@", ts, Strings.marvelBaseUrl, Strings.marvelPrivatekey)
        let hash = stringToHash.md5()
        let link = String(format: "%@/characters/%d/comics?ts=%@&apikey=%@&hash=%@", Strings.marvelBaseUrl, characterId, ts, Strings.marvelPublickey, hash)

        let url = URL(string: link)!
        
        return session.rx
            .json(url: url)
            .flatMap { json throws -> Observable<Dictionary<String, Any>> in
                guard
                    let json = json as? [String: Any],
                    let data = json["data"] as? [String: Any],
                    let itemsJSON = data["results"] as? [String: Any]
                else { return Observable.error(ServiceError.cannotParse) }
                return Observable.just(itemsJSON)
            }
    }
    
    func tsStringValue() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSSSS'Z'"
        return dateFormatter.string(from: Date())
    }

}

struct Character {
    let id: Int
    let fullName: String
    let description: String
    let thumbnail: Dictionary<String, Any>
    let comics: Dictionary<String, Any>
    
    init(id: Int, fullName: String, description: String, thumbnail: Dictionary<String, Any>, comics: Dictionary<String, Any>) {
        self.id = id
        self.fullName = fullName
        self.description = description
        self.thumbnail = thumbnail
        self.comics = comics
    }
}

extension Character {
    init?(from json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let fullName = json["name"] as? String,
            let description = json["description"] as? String,
            let thumbnail = json["thumbnail"] as? Dictionary<String, Any>,
            let comics = json["comics"] as? Dictionary<String, Any>
        
        else { return nil }
        
        self.init(id: id, fullName: fullName, description: description, thumbnail: thumbnail, comics: comics)
    }
}

extension Character: Equatable {
    static func == (lhs: Character, rhs: Character) -> Bool {
        return lhs.fullName == rhs.fullName
            && lhs.description == rhs.description
    }
}

struct Comic {
    let name: String
    let year: Int
}

struct Thumbnail {
    let path: String
    let ext: String
}

extension Thumbnail {
    init?(from json: [String: Any]) {
        guard
            let path = json["path"] as? String,
            let ext = json["extension"] as? String
        else { return nil }
        self.init(path: path, ext: ext)
    }
}
