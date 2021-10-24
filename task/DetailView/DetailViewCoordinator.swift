//
//  DetailViewCoordinator.swift
//  task
//
//  Created by Harun Cem DERE on 23.10.2021.
//

import Foundation
import RxSwift

enum CoordinationResult {
    case language(String)
    case cancel
}

class DetailViewCoordinator: BaseCoordinator<CoordinationResult> {

    private let rootViewController: UIViewController
    private let character: CharacterViewModel

    init(rootViewController: UIViewController, character: CharacterViewModel) {
        self.rootViewController = rootViewController
        self.character = character
    }

    override func start() {
        let detailViewController = DetailViewController.initFromStoryboard(name: "Main")
        detailViewController.viewModel = DetailViewModel(character: character)
        let navigationController = UINavigationController(rootViewController: detailViewController)
        rootViewController.present(navigationController, animated: true)
    }
}



/// Base abstract coordinator generic over the return type of the `start` method.
class BaseCoordinator<ResultType> {

    /// Typealias which will allows to access a ResultType of the Coordainator by `CoordinatorName.CoordinationResult`.
    typealias CoordinationResult = ResultType

    /// Utility `DisposeBag` used by the subclasses.
    let disposeBag = DisposeBag()

    /// Unique identifier.
    private let identifier = UUID()

    /// Dictionary of the child coordinators. Every child coordinator should be added
    /// to that dictionary in order to keep it in memory.
    /// Key is an `identifier` of the child coordinator and value is the coordinator itself.
    /// Value type is `Any` because Swift doesn't allow to store generic types in the array.
    private var childCoordinators = [UUID: Any]()


    /// Stores coordinator to the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Child coordinator to store.
    private func store<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    /// Release coordinator from the `childCoordinators` dictionary.
    ///
    /// - Parameter coordinator: Coordinator to release.
    private func free<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }

    /// 1. Stores coordinator in a dictionary of child coordinators.
    /// 2. Calls method `start()` on that coordinator.
    /// 3. On the `onNext:` of returning observable of method `start()` removes coordinator from the dictionary.
    ///
    /// - Parameter coordinator: Coordinator to start.
    /// - Returns: Result of `start()` method.
    func coordinate(to coordinator: BaseCoordinator){
        store(coordinator: coordinator)
        coordinator.start()
    }

    /// Starts job of the coordinator.
    ///
    /// - Returns: Result of coordinator job.
    func start(){
        fatalError("Start method should be implemented.")
    }
}
