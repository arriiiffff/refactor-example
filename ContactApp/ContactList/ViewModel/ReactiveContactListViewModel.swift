//
//  ReactiveContactListViewModel.swift
//  ContactApp
//
//  Created by GITS on 07/11/19.
//  Copyright © 2019 Ridho Pratama. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ReactiveContactListViewModel: ViewModelType {
    let service: ContactServiceProtocol
    init(service: ContactServiceProtocol = NetworkContactService()) {
        self.service = service
    }
    
    struct Input {
        let didLoadTrigger: Driver<Void>
        let didTapCellTrigger: Driver<IndexPath>
        let pullToRefreshTrigger: Driver<Void>
    }
    
    struct Output {
        let contactListCellData: Driver<[ContactListCellData]>
        let errorData: Driver<String>
        let selectedIndex: Driver<(index: IndexPath, model: ContactListCellData)>
        let isLoading: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let errorMessage = PublishSubject<String>()
        let isLoading = BehaviorRelay<Bool>(value: false)
        
        let fetchDataTrigger = Driver.merge( input.didLoadTrigger, input.pullToRefreshTrigger)
        
        let fetchData = fetchDataTrigger
            .do(onNext: { _ in
                isLoading.accept(true)
            })
            .flatMapLatest { [service] _ -> Driver<[Contact]> in
            service
                .reactiveFetchContacts()
                .do(onNext: { _ in
                    isLoading.accept(false)
                }, onError: { error in
                    errorMessage.onNext(error.localizedDescription)
                    isLoading.accept(false)
                })
                .asDriver { _ -> Driver<[Contact]> in
                    Driver.empty()
            }
        }
        let contactListCellData = fetchData
            .map { contacts -> [ContactListCellData] in
                contacts.map { contact -> ContactListCellData in
                    ContactListCellData(imageURL: contact.imageUrl, name: contact.name)
                }
                
        }
        
        let errorMessageDriver =  errorMessage
            .asDriver { error -> Driver<String> in
                Driver.empty()
        }
        
        let selectedIndexCell = input
            .didTapCellTrigger
            .withLatestFrom(contactListCellData) {
                index, contacts -> (index: IndexPath, model: ContactListCellData) in
                return (index: index, model: contacts[index.row])
        }
        
        return Output(contactListCellData: contactListCellData, errorData: errorMessageDriver, selectedIndex: selectedIndexCell, isLoading: isLoading.asDriver())
    }
    
}

