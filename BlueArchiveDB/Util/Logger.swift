//
//  Logger.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/10/27
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import os

public enum Logger
{
    public static let standard: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: LogCategory.standard.rawValue
    )
    public static let util: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: LogCategory.util.rawValue
    )
    public static let download: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: LogCategory.download.rawValue
    )
    public static let spotlight: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: LogCategory.spotlight.rawValue
    )
    public static let urlschema: os.Logger = .init(
        subsystem: Bundle.main.bundleIdentifier!,
        category: LogCategory.urlschema.rawValue
    )
}

// MARK: - Privates

private enum LogCategory: String
{
    case standard = "Standard"
    case util = "Util"
    case download = "Download"
    case spotlight = "Spotlight"
    case urlschema = "URLSchema"
}
