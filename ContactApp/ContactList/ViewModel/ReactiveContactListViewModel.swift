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
    }
    
    struct Output {
        let contactListCellData: Driver<[ContactListCellData]>
    }
    
    func transform(input: Input) -> Output {
        let fetchData = input.didLoadTrigger.flatMapLatest { [service] _ -> Driver<[Contact]> in
            service
                .reactiveFetchContacts()
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
        return Output(contactListCellData: contactListCellData)
    }
}
