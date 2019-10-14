//
//  EncryptedMuunKeySelector.swift
//  core
//
//  Created by Juan Pablo Civile on 03/09/2019.
//

import Foundation
import RxSwift
import Libwallet

public class EncryptedMuunKeySelector: BaseSelector<String> {

    init(keysRepository: KeysRepository) {
        super.init({
            do {
                return Observable.just(try keysRepository.getMuunPrivateKey())
            } catch {
                return Observable.error(error)
            }
        })
    }

}
