//
//  ActionState.swift
//  falcon
//
//  Created by Manu Herrera on 17/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

public class ActionState<T>: NSObject {

    public enum ActionStateType {
        case EMPTY
        case LOADING
        case VALUE
        case ERROR
    }

    public var type: ActionStateType = .EMPTY
    public var value: T?
    public var error: Error?

    private init(actionStateType: ActionStateType, value: T? = nil, error: Error? = nil) {
        self.error = error
        self.value = value
        self.type = actionStateType
    }

    static func createEmpty() -> ActionState {
        return ActionState(actionStateType: .EMPTY)
    }

    static func createLoading() -> ActionState {
        return ActionState(actionStateType: .LOADING)
    }

    static func createValue(value: T) -> ActionState {
        return ActionState(actionStateType: .VALUE, value: value)
    }

    static func createError(error: Error) -> ActionState {
        return ActionState(actionStateType: .ERROR, error: error)
    }

    public func getValue() -> T? {
        return value
    }

    public func getError() -> Error? {
        return error
    }

}
