//
//  CharacterListViewModel.swift
//  task
//
//  Created by Harun Cem DERE on 22.10.2021.
//

import Foundation
import RxSwift
import RxCocoa

class CharacterListViewModel {

    // MARK: - Inputs

    /// Call to update current language. Causes reload of the repositories.
    let setCurrentOffset: AnyObserver<Int>

    /// Call to show language list screen.
    let chooseLanguage: AnyObserver<Void>

    /// Call to open repository page.
    // MARK: TODO: coordinator bunun ile ???
    let selectCharacter: AnyObserver<CharacterViewModel>

    /// Call to reload repositories.
    let reload: AnyObserver<Void>

    // MARK: - Outputs

    /// Emits an array of fetched repositories.
    let characters: Observable<[CharacterViewModel]>
    
    /// Emits a formatted title for a navigation item.
//    let title: Observable<String>

    /// Emits an error messages to be shown.
    let alertMessage: Observable<String>

    /// Emits an url of repository page to be shown.
//    let showRepository: Observable<URL>

    /// Emits when we should show language list.
    let showLanguageList: Observable<Void>
    
    let githubService: Service
    
    init(initialOffset: Int, githubService: Service = Service()) {
        
        self.githubService = githubService

        let _reload = PublishSubject<Void>()
        self.reload = _reload.asObserver()

        let _currentOffset = BehaviorSubject<Int>(value: initialOffset)
        self.setCurrentOffset = _currentOffset.asObserver()

//        self.title = _currentLanguage.asObservable()
//            .map { "\($0)" }

        let _alertMessage = PublishSubject<String>()
        self.alertMessage = _alertMessage.asObservable()
        
        self.characters = Observable.combineLatest( _reload, _currentOffset) { _, offset in offset }
            .flatMapLatest { offset in
                githubService.getCharacters(offset: offset)
                    .catch { error in
                        _alertMessage.onNext(error.localizedDescription)
                        return Observable.empty()
                    }
            }
            .map() {
                chars in chars.map(CharacterViewModel.init)
            }
        
        let _select = PublishSubject<CharacterViewModel>()
        self.selectCharacter = _select.asObserver()
//        self.showRepository = _selectRepository.asObservable()
//            .map { $0.url }

        let _chooseLanguage = PublishSubject<Void>()
        self.chooseLanguage = _chooseLanguage.asObserver()
        self.showLanguageList = _chooseLanguage.asObservable()
    }
}
