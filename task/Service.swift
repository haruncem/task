//
//  Service.swift
//  task
//
//  Created by Harun Cem DERE on 22.10.2021.
//

import Foundation
import RxSwift
import RxCocoa
import CryptoKit

enum ServiceError: Error {
    case cannotParse
}

/// A service that knows how to perform requests for GitHub data.
class Service {

    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    let limit = 30
    var offset = 0
    
    var size: Int = 0
    
    var allCharacters = [Repository]()

    /// - Parameter language: Language to filter by
    /// - Returns: A list of most popular repositories filtered by langugage
    func getMostPopularRepositories() -> Observable<[Repository]> {
        let url = URL(string: "https://api.github.com/search/repositories?q=language:Python&sort=stars")!
        return session.rx
            .json(url: url)
            .flatMap { json throws -> Observable<[Repository]> in
                guard
                    let json = json as? [String: Any],
                    let itemsJSON = json["items"] as? [[String: Any]]
                else { return Observable.error(ServiceError.cannotParse) }

                let repositories = itemsJSON.compactMap(Repository.init)
                return Observable.just(repositories)
            }
    }
    
    func getCharacters(offset: Int) -> Observable<[Repository]> {

        print("*** getCharacters CALL ***")
        
        let publickey = "c9aada89dad0251a43b6ec7e8fe6d37c"
        let privatekey = "afc2794f87b8cf9170c48622c8b54bf249e0a4c9"
        let ts = tsStringValue()
        let stringToHash = String(format: "%@%@%@", ts, privatekey, publickey)
        let hash = MD5(string: stringToHash)
        let baseUrl = "https://gateway.marvel.com:443/v1/public/characters"
//        let limit = 30
        let link = String(format: "%@?limit=%d&offset=%d&ts=%@&apikey=%@&hash=%@", baseUrl, limit, self.offset, ts, publickey, hash)
//        var url = baseUrl +  + limit + '&ts=' + ts + '&apikey=' + publickey + '&hash=' + hash;
        
        let url = URL(string: link)!
        
        return session.rx
            .json(url: url)
            .flatMap { json throws -> Observable<[Repository]> in
                guard
                    let json = json as? [String: Any],
                    let data = json["data"] as? [String: Any],
                    let itemsJSON = data["results"] as? [[String: Any]]
                else { return Observable.error(ServiceError.cannotParse) }

                let characters = itemsJSON.compactMap(Repository.init)
                self.allCharacters.append(contentsOf: characters)
                self.size = self.allCharacters.count
                self.offset += 30
                return Observable.just(self.allCharacters)
            }
    }
    
    func getCharactersComics(characterId: Int) -> Observable<Dictionary<String, Any>> {

        let publickey = "c9aada89dad0251a43b6ec7e8fe6d37c"
        let privatekey = "afc2794f87b8cf9170c48622c8b54bf249e0a4c9"
        let ts = tsStringValue()
        let stringToHash = String(format: "%@%@%@", ts, privatekey, publickey)
        let hash = MD5(string: stringToHash)
        let baseUrl = "https://gateway.marvel.com:443/v1/public/characters/\(characterId)/comics"
        let link = String(format: "%@?ts=%@&apikey=%@&hash=%@", baseUrl, ts, publickey, hash)

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
    
    
    func MD5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }

}

struct Repository {
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
    
//    "comics": {
//              "available": 2,
//              "collectionURI": "http://gateway.marvel.com/v1/public/characters/1011324/comics",
//              "items": [
//                {
//                  "resourceURI": "http://gateway.marvel.com/v1/public/comics/21177",
//                  "name": "Ultimate X-Men (2001) #94"
//                },
//                {
//                  "resourceURI": "http://gateway.marvel.com/v1/public/comics/21326",
//                  "name": "Ultimate X-Men (2001) #95"
//                }
//              ],
//              "returned": 2
//            },
}

struct Comic {
    let name: String
    let year: Int
}

extension Repository {
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

extension Repository: Equatable {
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.fullName == rhs.fullName
            && lhs.description == rhs.description
    }
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
/*
class Thumbnail: Codable {
    let path: String?
    let ext: String?
    
    enum CodingKeys: String, CodingKey {
        case path = "path"
        case ext = "ext"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        path = try values.decodeIfPresent(String.self, forKey: .path)
        ext = try values.decodeIfPresent(String.self, forKey: .ext)
    }
}

class Repository: Codable{
    
    let id: Int?
    let fullName: String?
    let description: String?
    let thumbnail: Thumbnail?
    
    enum CodingKeys: String, CodingKey {

        case id = "id"
        case fullName = "name"
        case description = "description"
        case thumbnail = "thumbnail"
        
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        fullName = try values.decodeIfPresent(String.self, forKey: .fullName)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        thumbnail = try values.decodeIfPresent(Thumbnail.self, forKey: .thumbnail)
        
    }
*/
