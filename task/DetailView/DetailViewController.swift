//
//  DetailViewController.swift
//  task
//
//  Created by Harun Cem DERE on 23.10.2021.
//

import UIKit
import RxSwift
import RxCocoa
import ImageLoader

class DetailViewController: UIViewController, StoryboardInitializable {

    let disposeBag = DisposeBag()
    var viewModel: DetailViewModel!

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tv.tableFooterView = UIView()
        setupBindings()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    private func setupBindings() {
        
        viewModel.selectedCharacter.map({ (model) -> String in
            return model.name
        }).bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.selectedCharacter.map({ (model) -> String in
            return model.description
        }).bind(to: lblDesc.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.selectedCharacter.map({ (model) -> UIImage? in
            
            let url = URL(string: (model.getImageUrl() ?? ""))
            if let data = try? Data(contentsOf: url!){
                return UIImage(data: data) ?? UIImage(named: "notfound")
            }
            return UIImage(named: "notfound")
            
        }).bind(to: imgView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.comics
            .observe(on: MainScheduler.instance)
            .bind(to: tv.rx.items(cellIdentifier: Strings.comicCellIdentifier, cellType: ComicCell.self)) { (_, language, cell) in
                cell.lblName?.text = language.name
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        // MARK: TODO: get characters comics
//        refreshControl.rx.controlEvent(.valueChanged)
//            .bind(to: viewModel.getComics)
//            .disposed(by: disposeBag)

    }

}

protocol StoryboardInitializable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardInitializable where Self: UIViewController {

    static var storyboardIdentifier: String {
        return String(describing: Self.self)
    }

    static func initFromStoryboard(name: String = "Main") -> Self {
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}
