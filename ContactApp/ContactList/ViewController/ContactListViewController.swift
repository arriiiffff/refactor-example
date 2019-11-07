//
//  ContactListViewController.swift
//  ContactApp
//
//  Created by Ridho Pratama on 26/09/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContactListViewController: UIViewController {
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ContactListTableViewCell.self, forCellReuseIdentifier: ContactListTableViewCell.reuseIdentifier)
        tv.estimatedRowHeight = 80
        tv.rowHeight = 80
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    let refreshControl = UIRefreshControl()
    
    private let viewModel = ReactiveContactListViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupViewModel()
    }
    
    private func setupView() {
        title = "Contact List"
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        view.backgroundColor = .white
        tableView.refreshControl = refreshControl
    }
    
    private func setupViewModel() {
        // MARK: Input
        let input = ReactiveContactListViewModel.Input(didLoadTrigger: .just(()), didTapCellTrigger: tableView.rx.itemSelected.asDriver(), pullToRefreshTrigger: refreshControl.rx.controlEvent(.allEvents).asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.contactListCellData
            .drive(tableView.rx.items(cellIdentifier: ContactListTableViewCell.reuseIdentifier, cellType: ContactListTableViewCell.self)) {
                row, model, cell in
                cell.configureCell(with: model)
        }.disposed(by: disposeBag)
        
        output.errorData
            .drive(onNext: { errorMessage in
                print("error")
            }).disposed(by: disposeBag)
        
        output.selectedIndex.drive(onNext: { (index, model) in
            print("ini index \(index), model: \(model)")
            }).disposed(by: disposeBag)
        
        output
            .isLoading
            .drive(refreshControl.rx.isRefreshing)
        .disposed(by: disposeBag)
    }
}
