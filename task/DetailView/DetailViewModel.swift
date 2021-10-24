//
//  DetailViewModel.swift
//  task
//
//  Created by Harun Cem DERE on 24.10.2021.
//

import Foundation
import RxSwift

class DetailViewModel {

    let selectedCharacter: Observable<CharacterViewModel>
    
    let comics: Observable<[Comic]>
    
    let getComics: AnyObserver<Void>
    let setCurrentOffset: AnyObserver<Int>
    
    let charactersComics: Observable<Dictionary<String, Any>>

    init(character: CharacterViewModel, githubService: Service = Service()) {
        let _character = BehaviorSubject<CharacterViewModel>(value: character)
        self.selectedCharacter = _character.asObservable()
        
        let _getComics = PublishSubject<Void>()
        self.getComics = _getComics.asObserver()
        
        let _currentOffset = BehaviorSubject<Int>(value: 0)
        self.setCurrentOffset = _currentOffset.asObserver()
        
        self.charactersComics = Observable.combineLatest( _getComics, _currentOffset) { _, comics in comics }
            .flatMapLatest { comics in
                githubService.getCharactersComics(characterId: character.id)
                    .catch { error in
//                        _alertMessage.onNext(error.localizedDescription)
                        return Observable.empty()
                    }
            }
//            .map {
//                repositories in repositories.map(Dictionary<String, Any>.init)
//            }

        // comics::
        var arrComic = [Comic]()
        let arrItems = character.comics["items"] as? [Dictionary<String, Any>]

        arrItems?.forEach({ (dict) in
            if let name = dict["name"] as? String{
                let yearString = name.matches(for: "([0-9]{4})").first
                let year = Int(yearString ?? "") ?? 0
                let comic = Comic(name: name, year: year)
                arrComic.append(comic)
            }
        })
        
        arrComic = arrComic.filter { $0.year > 2005 }
        arrComic = arrComic.sorted {
            $0.year > $1.year
        }
        let first10 = arrComic.prefix(10)
        
        let _comics = BehaviorSubject<[Comic]>(value: Array(first10))
        self.comics = _comics.asObservable()
        
        print("aa")
        
    }

}
