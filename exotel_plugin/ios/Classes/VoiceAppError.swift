//
//  VoiceAppError.swift
//  Pods
//
//  Created by Afrah Mahmud on 18/09/24.
//

import Foundation

public class VoiceAppError: Error {
    ///Name of the module that throwed this error.
    public var module: String
    
    ///Localized description is the complete sentence (or more) describing what failed.
    public var localizedDescription: String
    
    ///module and Localized description should never be nil.
    public init(module: String, localizedDescription: String) {
        self.module = module
        self.localizedDescription = localizedDescription
    }
}
