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

    let setCurrentOffset: AnyObserver<Int>
    let selectCharacter: AnyObserver<CharacterViewModel>
    let reload: AnyObserver<Void>

    let characters: Observable<[CharacterViewModel]>
    let alertMessage: Observable<String>

    let githubService: Service
    
    init(initialOffset: Int, githubService: Service = Service()) {
        
        self.githubService = githubService

        let _reload = PublishSubject<Void>()
        self.reload = _reload.asObserver()

        let _currentOffset = BehaviorSubject<Int>(value: initialOffset)
        self.setCurrentOffset = _currentOffset.asObserver()

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

    }
}
