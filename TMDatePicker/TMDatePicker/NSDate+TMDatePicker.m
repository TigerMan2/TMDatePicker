//
//  NSDate+TMDatePicker.m
//  TMDatePicker
//
//  Created by Luther on 2020/3/26.
//  Copyright © 2020 mrstock. All rights reserved.
//

#import "NSDate+TMDatePicker.h"

static const NSCalendarUnit unitFlags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday);

@implementation NSDate (TMDatePicker)

+ (NSCalendar *)calendar {
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar) {
        // 创建日历对象：currentCalendar取得的值会一直保持在cache中,第一次取得以后如果用户修改该系统日历设定，这个值也不会改变。
//        sharedCalendar = [NSCalendar currentCalendar];
        // 创建日历对象：返回当前客户端的逻辑日历(当每次修改系统日历设定，其实例化的对象也会随之改变)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    }
    return sharedCalendar;
}

//!< 获取指定日期的年份
- (NSInteger)tm_year {
    NSDateComponents *components = [[NSDate calendar] components:unitFlags fromDate:self];
    return components.year;
}
//!< 获取指定日期的月份
- (NSInteger)tm_month {
    NSDateComponents *components = [[NSDate calendar] components:unitFlags fromDate:self];
    return components.month;
}
//!< 获取指定日期的天
- (NSInteger)tm_day {
    NSDateComponents *components = [[NSDate calendar] components:unitFlags fromDate:self];
    return components.day;
}
//!< 获取指定日期的小时
- (NSInteger)tm_hour {
    NSDateComponents *components = [[NSDate calendar] components:unitFlags fromDate:self];
    return components.hour;
}
//!< 获取指定日期的分钟
- (NSInteger)tm_minute {
    NSDateComponents *components = [[NSDate calendar] components:unitFlags fromDate:self];
    return components.minute;
}
//!< 获取指定日期的秒
- (NSInteger)tm_second {
    NSDateComponents *components = [[NSDate calendar] components:unitFlags fromDate:self];
    return components.second;
}
//!< 获取指定日期的星期
- (NSInteger)tm_weekday {
    NSDateComponents *components = [[NSDate calendar] components:unitFlags fromDate:self];
    return components.weekday;
}
//!< 获取中文中额星期几
- (NSString *)tm_weekdayString {
    switch (self.tm_weekday - 1) {
        case 0:
            return @"周日";
        case 1:
            return @"周一";
        case 2:
            return @"周二";
        case 3:
            return @"周三";
        case 4:
            return @"周四";
        case 5:
            return @"周五";
        case 6:
            return @"周六";
            
        default:
            break;
    }
    return @"";
}

#pragma mark  创建date
+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSCalendar *calendar = [NSDate calendar];
    // 初始化日期组件
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    if (year > 0) {
        components.year = year;
    }
    if (month > 0) {
        components.month = month;
    }
    if (day > 0) {
        components.day = day;
    }
    if (hour >= 0) {
        components.hour = hour;
    }
    if (minute >= 0) {
        components.minute = minute;
    }
    if (second >= 0) {
        components.second = second;
    }
    NSDate *date = [calendar dateFromComponents:components];
    return date;
}

+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute {
    return [self tm_setYear:year month:month day:day hour:hour minute:minute second:0];
}

+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour {
    return [self tm_setYear:year month:month day:day hour:hour minute:0 second:0];
}

+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    return [self tm_setYear:year month:month day:day hour:0 minute:0 second:0];
}

+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month {
    return [self tm_setYear:year month:month day:0 hour:0 minute:0 second:0];
}

+ (NSDate *)tm_setYear:(NSInteger)year {
    return [self tm_setYear:year month:0 day:0 hour:0 minute:0 second:0];
}

+ (NSDate *)tm_setMonth:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute {
    return [self tm_setYear:0 month:month day:day hour:hour minute:minute second:0];
}

+ (NSDate *)tm_setMonth:(NSInteger)month day:(NSInteger)day {
    return [self tm_setYear:0 month:month day:day hour:0 minute:0 second:0];
}

+ (NSDate *)tm_setHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    return [self tm_setYear:0 month:0 day:0 hour:hour minute:minute second:second];
}

+ (NSDate *)tm_setHour:(NSInteger)hour minute:(NSInteger)minute {
    return [self tm_setYear:0 month:0 day:0 hour:hour minute:minute second:0];
}

+ (NSDate *)tm_setMinute:(NSInteger)minute second:(NSInteger)second {
    return [self tm_setYear:0 month:0 day:0 hour:0 minute:minute second:second];
}

#pragma mark  NSDate和NSString之间的转换
//!< NSDate -> NSString
+ (NSString *)tm_getDataString:(NSDate *)date format:(NSString *)format {
    if (!date) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

//!< NSString -> NSDate
+ (NSDate *)tm_getDate:(NSString *)dateString format:(NSString *)format {
    if (dateString.length <= 0 || !dateString) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    // 一些夏令时时间（如：1949-05-01等），会导致 NSDateFormatter 格式化失败，返回null
    NSDate *date = [formatter dateFromString:dateString];
    if (!date) {
        date = [NSDate date];
    }
    
    // 设置转换后的目标日期时区
    NSTimeZone *toTimeZone = [NSTimeZone localTimeZone];
    // 转换后原日期与世界标准时间的偏移量（解决8小时时间差问题）
    NSInteger toGMTOffset = [toTimeZone secondsFromGMTForDate:date];
    // 设置时区：字符串时间是当前时区的时间，NSDate存储的是世界标准时间(零时区的时间)
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:toGMTOffset];
    
    date = [formatter dateFromString:dateString];
    return date;
}

#pragma mark  获取某个月的天数
+ (NSInteger)tm_getDaysInYear:(NSInteger)year month:(NSInteger)month {
    BOOL isLeapYear = year % 4 == 0 ? (year % 100 == 0 ? (year % 400 == 0 ? YES : NO) : YES) : NO;
    switch (month) {
        case 1: case 3: case 5: case 7: case 8: case 10: case 12:
            return 31;
        case 4: case 6: case 9: case 11:
            return 30;
        case 2:
            return (isLeapYear ? 29 : 28);
        default:
            break;
    }
    return 0;
}

#pragma mark  获取日期加上/减去几天的新日期
- (NSDate *)tm_getNewDate:(NSDate *)date addDays:(NSTimeInterval)days {
    return [self dateByAddingTimeInterval:60 * 60 * 24 * days];
}

- (NSComparisonResult)tm_compare:(NSDate *)targetDate format:(NSString *)format {
    NSString *dateString1 = [NSDate tm_getDataString:self format:format];
    NSString *dateString2 = [NSDate tm_getDataString:targetDate format:format];
    NSDate *date1 = [NSDate tm_getDate:dateString1 format:format];
    NSDate *date2 = [NSDate tm_getDate:dateString2 format:format];
    if ([date1 compare:date2] == NSOrderedDescending) {
        return 1;
    } else if ([date1 compare:date2] == NSOrderedAscending) {
        return -1;
    }
    return 0;
}

@end
