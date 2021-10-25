//
//  ViewController.swift
//  task
//
//  Created by Harun Cem DERE on 22.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

class CharacterListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    private let refreshControl = UIRefreshControl()
    let viewModel = CharacterListViewModel(initialOffset: 0, githubService: Service())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupBindings()
        refreshControl.sendActions(for: .valueChanged) // force reload
    }

    private func configureTableView() {
        tableView.rowHeight = 96
        tableView.showLoadingMoreSpinner()
    }
    
    private func setupBindings() {
        
        tableView.rx
            .willDisplayCell
            .subscribe(onNext: { cell, indexPath in
                let size = self.viewModel.githubService.allCharacters.count
                if indexPath.row == size-1{
                    print("bottom  reached")
                    self.tableView.showLoadingMoreSpinner()
                    self.refreshControl.sendActions(for: .valueChanged)
                }
            })
            .disposed(by: disposeBag)
        
        tableView
            .rx
            .modelSelected(CharacterViewModel.self)
            .subscribe(onNext: { [weak self] coffee in
                if let vc = self{
                    let coordinator = DetailViewCoordinator(rootViewController: vc, character: coffee)
                    coordinator.start()
                }
                if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            })
            .disposed(by: disposeBag)
    
        // MARK: TODO: insert only new rows?
        viewModel.characters
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.refreshControl.endRefreshing() })
            .bind(to: tableView.rx.items(cellIdentifier: Strings.characterCellIdentifier, cellType: CharacterCell.self)) {(_, char, cell) in
                cell.setupCell(character: char)
            }
            .disposed(by: disposeBag)

        viewModel.alertMessage
            .subscribe(onNext: { [weak self] in self?.presentAlert(message: $0) })
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.reload)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(CharacterViewModel.self)
            .bind(to: viewModel.selectCharacter)
            .disposed(by: disposeBag)

    }
    
    private func presentAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
}

