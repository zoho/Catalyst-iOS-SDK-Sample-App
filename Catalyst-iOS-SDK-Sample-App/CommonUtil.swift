//
//  CommonUtil.swift
//  CatalystTestApp
//
//  Created by Umashri R on 14/09/20.
//  Copyright © 2020 Umashri R. All rights reserved.
//

import Foundation

extension Formatter
{
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale( identifier : "en_US_POSIX" )
        formatter.timeZone = TimeZone( secondsFromGMT : 0 )
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
    static let dateFormatterWithTimeZone : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy' at 'HH:mm"
        return formatter
    }()
    
    static let dateFormatterForAPI : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let dateFormatterWithTimeZoneForAPI : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        return formatter
    }()
}

extension Date
{
    var date : String
    {
        return Formatter.dateFormatter.string( from : self )
    }
    
    var dateTime : String
    {
        return Formatter.dateFormatterWithTimeZone.string( from : self )
    }
    
    var iso8601 : String
    {
        return Formatter.dateFormatterForAPI.string( from : self )
    }
    
    var iso8601WithTimeZone : String
    {
        return Formatter.dateFormatterWithTimeZoneForAPI.string( from : self )
    }
}

extension String
{
    var date : Date?
    {
        return Formatter.dateFormatter.date( from : self )
    }
    
    var dateTime : Date?
    {
        return Formatter.dateFormatterWithTimeZone.date( from : self )
    }
    
    var dateFromISO8601 : Date?
    {
        return Formatter.dateFormatterForAPI.date( from : self )   // "Nov 14, 2017, 10:22 PM"
    }
    
    var dateFromISO8601WithTimeZone : Date?
    {
        return Formatter.dateFormatterWithTimeZoneForAPI.date( from : self )
    }
}
