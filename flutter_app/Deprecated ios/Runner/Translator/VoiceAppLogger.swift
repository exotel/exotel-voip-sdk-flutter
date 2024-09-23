/*
 * Copyright (c) 2022 Exotel Techcom Pvt Ltd
 * All rights reserved
 */

import Foundation

class VoiceAppLogger {
    private static let TAG = "VoiceAppLogger"
    private static let ZIP_LOGS_AFTER_DAYS = 1
    private static var sFilesDir: String = ""
    private static var DAYS_IN_MS = 1000 * 60 * 60 * 24
    private static var UPLOAD_LOG_NUM_DAYS = 7
    private static var coordinator = NSFileCoordinator()
    private static var error: NSError?
    
    static func debug(TAG: String, message: String) {
        print("\(TAG): \(message)")
    }
    
    static func info(TAG: String, message: String) {
        print("\(TAG): \(message)")
    }
    
    static func error(TAG:String, message:String) {
        print("\(TAG): \(message)")
    }
    
    static func warning(TAG:String, message:String) {
        print("\(TAG): \(message)")
    }
}
