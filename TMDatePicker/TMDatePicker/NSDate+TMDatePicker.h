//
//  NSDate+TMDatePicker.h
//  TMDatePicker
//
//  Created by Luther on 2020/3/26.
//  Copyright © 2020 mrstock. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (TMDatePicker)

@property (nonatomic, assign, readonly) NSInteger tm_year;          //年
@property (nonatomic, assign, readonly) NSInteger tm_month;         //月
@property (nonatomic, assign, readonly) NSInteger tm_day;           //日
@property (nonatomic, assign, readonly) NSInteger tm_hour;          //时
@property (nonatomic, assign, readonly) NSInteger tm_minute;        //分
@property (nonatomic, assign, readonly) NSInteger tm_second;        //秒
@property (nonatomic, assign, readonly) NSInteger tm_weekday;       //星期

@property (nonatomic, copy, readonly) NSString *tm_weekdayString;   //中文中的星期几


/** 创建 date */
/// yyyy
+ (NSDate *)tm_setYear:(NSInteger)year;
/// yyyy-MM
+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month;
/// yyyy-MM-dd
+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
/// yyyy-MM-dd HH
+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour;
/// yyyy-MM-dd HH:mm
+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;
/// yyyy-MM-dd HH:mm:ss
+ (NSDate *)tm_setYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
/// MM-dd HH:mm
+ (NSDate *)tm_setMonth:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;
/// MM-dd
+ (NSDate *)tm_setMonth:(NSInteger)month day:(NSInteger)day;
/// HH:mm:ss
+ (NSDate *)tm_setHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
/// HH:mm
+ (NSDate *)tm_setHour:(NSInteger)hour minute:(NSInteger)minute;
/// mm:ss
+ (NSDate *)tm_setMinute:(NSInteger)minute second:(NSInteger)second;

#pragma mark  NSDate和NSString之间的转换
/// NSDate -> NSString
+ (NSString *)tm_getDataString:(NSDate *)date format:(NSString *)format;
/// NSString -> NSDate
+ (NSDate *)tm_getDate:(NSString *)dateString format:(NSString *)format;
///获取某个月的天数
+ (NSInteger)tm_getDaysInYear:(NSInteger)year month:(NSInteger)month;
/// 获取日期加上/减去几天的新日期
- (NSDate *)tm_getNewDate:(NSDate *)date addDays:(NSTimeInterval)days;
/// 比较两个时间大小
- (NSComparisonResult)tm_compare:(NSDate *)targetDate format:(NSString *)format;

@end

NS_ASSUME_NONNULL_END
