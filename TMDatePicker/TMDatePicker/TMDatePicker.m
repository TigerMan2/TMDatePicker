//
//  TMDatePicker.m
//  TMDatePicker
//
//  Created by Luther on 2020/3/26.
//  Copyright © 2020 mrstock. All rights reserved.
//

#import "TMDatePicker.h"
#import "TMDatePickerMacro.h"
#import "NSDate+TMDatePicker.h"

@interface TMDatePicker () <UIPickerViewDataSource,UIPickerViewDelegate>
/// 蒙层
@property (nonatomic, strong) UIView *maskView;
/// 弹框视图
@property (nonatomic, strong) UIView *alertView;
/// 日期视图
@property (nonatomic, strong) UIPickerView *pickerView;
/// 取消按钮
@property (nonatomic, strong) UIButton *cancelButton;
/// 确定按钮
@property (nonatomic, strong) UIButton *doneButton;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 头部
@property (nonatomic, strong) UIView *toolBar;

/// 日期存储数组
@property (nonatomic, copy) NSArray *yearArr;
@property (nonatomic, copy) NSArray *monthArr;
@property (nonatomic, copy) NSArray *dayArr;
@property (nonatomic, copy) NSArray *hourArr;
@property (nonatomic, copy) NSArray *minuteArr;
@property (nonatomic, copy) NSArray *secondArr;

/// 记录当前选择的位置 【年 月 日 时 分 秒】
@property (nonatomic, assign) NSInteger yearIndex;
@property (nonatomic, assign) NSInteger monthIndex;
@property (nonatomic, assign) NSInteger dayIndex;
@property (nonatomic, assign) NSInteger hourIndex;
@property (nonatomic, assign) NSInteger minuteIndex;
@property (nonatomic, assign) NSInteger secondIndex;

/// 记录选择的值
@property (nonatomic, strong) NSDate *mSelectDate;

/// 日期的格式
@property (nonatomic, copy) NSString *dateFormatter;
/// 单位数组
@property (nonatomic, copy) NSArray *unitArr;
/// 单位Label数组
@property (nonatomic, copy) NSArray <UILabel *> *unitLabelArr;
/// 获取所有月份名称
@property (nonatomic, copy) NSArray <NSString *> *monthNames;

@end

@implementation TMDatePicker

- (void)reloadData {
    // 1.处理数据源
    [self handlerPickerData];
    // 2.刷新选择器
    [self.pickerView reloadAllComponents];
    // 3.滚动到选择的时间
    [self scrollToSelectDate:self.mSelectDate animated:NO];
}

- (void)handlerPickerData {
    // 最小日期限制
    if (!self.minDate) {
        if (self.pickerMode == TMDatePickerModeMDHM) {
            self.minDate = [NSDate tm_setMonth:1 day:1 hour:0 minute:0];
        } else if (self.pickerMode == TMDatePickerModeMD) {
            self.minDate = [NSDate tm_setMonth:1 day:1];
        } else if (self.pickerMode == TMDatePickerModeHMS) {
            self.minDate = [NSDate tm_setHour:0 minute:0 second:0];
        } else if (self.pickerMode == TMDatePickerModeMS) {
            self.minDate = [NSDate tm_setMinute:0 second:0];
        } else {
            self.minDate = [NSDate distantPast];
        }
    }
    // 最大日期限制
    if (!self.maxDate) {
        if (self.pickerMode == TMDatePickerModeMDHM) {
            self.maxDate = [NSDate tm_setMonth:12 day:31 hour:23 minute:59];
        } else if (self.pickerMode == TMDatePickerModeMD) {
            self.maxDate = [NSDate tm_setMonth:12 day:31];
        } else if (self.pickerMode == TMDatePickerModeHMS) {
            self.maxDate = [NSDate tm_setHour:23 minute:59 second:59];
        } else if (self.pickerMode == TMDatePickerModeMS) {
            self.maxDate = [NSDate tm_setMinute:59 second:59];
        } else {
            self.maxDate = [NSDate distantFuture];
        }
    }
    
    BOOL minMoreThanMax = [self.minDate tm_compare:self.maxDate format:self.dateFormatter] == NSOrderedDescending;
    NSAssert(!minMoreThanMax, @"最小日期不能大于最大日期！");
    if (minMoreThanMax) {
        // 如果最小日期大于了最大日期，就忽略两个值
        self.minDate = [NSDate distantPast];
        self.maxDate = [NSDate distantFuture];
    }
    // 3.默认选中的日期
    [self handlerDefaultSelectDate];
    
    [self initDataArray];
}

- (void)setupDateFormatter:(TMDatePickerMode)mode {
    switch (mode) {
        case TMDatePickerModeYMDHMS:
        {
            self.dateFormatter = @"yyyy-MM-dd HH:mm:ss";
        }
            break;
        case TMDatePickerModeYMDHM:
        {
            self.dateFormatter = @"yyyy-MM-dd HH:mm";
        }
            break;
        case TMDatePickerModeYMDH:
        {
            self.dateFormatter = @"yyyy-MM-dd HH";
        }
            break;
        case TMDatePickerModeMDHM:
        {
            self.dateFormatter = @"MM-dd HH:mm";
        }
            break;
        case TMDatePickerModeYMD:
        {
            self.dateFormatter = @"yyyy-MM-dd";
        }
            break;
        case TMDatePickerModeYM:
        {
            self.dateFormatter = @"yyyy-MM";
        }
            break;
        case TMDatePickerModeMD:
        {
            self.dateFormatter = @"MM-dd";
        }
            break;
        case TMDatePickerModeY:
        {
            self.dateFormatter = @"yyyy";
        }
            break;
        case TMDatePickerModeHMS:
        {
            self.dateFormatter = @"HH:mm:ss";
        }
            break;
        case TMDatePickerModeHM:
        {
            self.dateFormatter = @"HH:mm";
        }
            break;
        case TMDatePickerModeMS:
        {
            self.dateFormatter = @"mm:ss";
        }
            break;
            
        default:
            break;
    }
}

- (void)handlerDefaultSelectDate {
    if (!self.selectDate) {
        self.mSelectDate = [NSDate date];
    }
    
    BOOL selectLessThanMin = [self.mSelectDate tm_compare:self.minDate format:self.dateFormatter] == NSOrderedAscending;
    BOOL selectMoreThanMax = [self.mSelectDate tm_compare:self.maxDate format:self.dateFormatter] == NSOrderedDescending;
    if (selectLessThanMin) {
        self.mSelectDate = self.minDate;
    }
    if (selectMoreThanMax) {
        self.mSelectDate = self.maxDate;
    }
}

- (void)initDataArray {
    self.yearArr = [self getYearArr];
    self.monthArr = [self getMonthArr:self.mSelectDate.tm_year];
    self.dayArr = [self getDayArr:self.mSelectDate.tm_year month:self.mSelectDate.tm_month];
    self.hourArr = [self getHourArr:self.mSelectDate.tm_year month:self.mSelectDate.tm_month day:self.mSelectDate.tm_day];
    self.minuteArr = [self getMinuteArr:self.mSelectDate.tm_year month:self.mSelectDate.tm_month day:self.mSelectDate.tm_day hour:self.mSelectDate.tm_hour];
    self.secondArr = [self getSecondArr:self.mSelectDate.tm_year month:self.mSelectDate.tm_month day:self.mSelectDate.tm_day hour:self.mSelectDate.tm_hour minute:self.mSelectDate.tm_minute];
}

- (void)reloadDataArrayWithUpdateMonth:(BOOL)updateMonth updateDay:(BOOL)updateDay updateHour:(BOOL)updateHour updateMinute:(BOOL)updateMinute updateSecond:(BOOL)updateSecond {
    // 1.更新month
    if (self.yearArr.count == 0) {
        return;
    }
    NSString *yearString = self.yearArr[self.yearIndex];
    if (updateMonth) {
        self.monthArr = [self getMonthArr:[yearString integerValue]];
    }
    
    // 2.更新day
    if (self.monthArr.count == 0) {
        return;
    }
    NSString *monthString = self.monthArr[self.monthIndex];
    if (updateDay) {
        self.dayArr = [self getDayArr:[yearString integerValue] month:[monthString integerValue]];
    }
    
    // 3.更新hour
    if (self.dayArr.count == 0) {
        return;
    }
    NSString *dayString = self.dayArr[self.dayIndex];
    if (updateDay) {
        self.hourArr = [self getHourArr:[yearString integerValue] month:[monthString integerValue] day:[dayString integerValue]];
    }
    
    // 4.更新minute
    if (self.hourArr.count == 0) {
        return;
    }
    NSString *hourString = self.hourArr[self.hourIndex];
    if (updateDay) {
        self.minuteArr = [self getMinuteArr:[yearString integerValue] month:[monthString integerValue] day:[dayString integerValue] hour:[hourString integerValue]];
    }
    
    // 5.更新second
    if (self.minuteArr.count == 0) {
        return;
    }
    NSString *minuteString = self.minuteArr[self.minuteIndex];
    if (updateDay) {
        self.secondArr = [self getSecondArr:[yearString integerValue] month:[monthString integerValue] day:[dayString integerValue] hour:[hourString integerValue] minute:[minuteString integerValue]];
    }
}

- (NSArray *)getYearArr {
    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSInteger i = self.minDate.tm_year; i <= self.maxDate.tm_year; i ++) {
        [tempArr addObject:[@(i) stringValue]];
    }
    return [tempArr copy];
}

- (NSArray *)getMonthArr:(NSInteger)year {
    NSInteger startMonth = 1;
    NSInteger endMonth = 12;
    if (year == self.minDate.tm_year) {
        startMonth = self.minDate.tm_month;
    }
    if (year == self.maxDate.tm_year) {
        endMonth = self.maxDate.tm_month;
    }
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:(endMonth - startMonth + 1)];
    for (NSInteger i = startMonth; i <= endMonth; i ++) {
        [tempArr addObject:[@(i) stringValue]];
    }
    return [tempArr copy];
    
}

- (NSArray *)getDayArr:(NSInteger)year month:(NSInteger)month {
    NSInteger startDay = 1;
    NSInteger endDay = [NSDate tm_getDaysInYear:year month:month];
    
    if (year == self.minDate.tm_year && month == self.minDate.tm_month) {
        startDay = self.minDate.tm_day;
    }
    if (year == self.maxDate.tm_year && month == self.maxDate.tm_month) {
        endDay = self.maxDate.tm_day;
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:(endDay - startDay + 1)];
    for (NSInteger i = startDay; i <= endDay; i ++) {
        [tempArr addObject:[@(i) stringValue]];
    }
    return [tempArr copy];
}

- (NSArray *)getHourArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSInteger startHour = 0;
    NSInteger endHour = 23;
    if (year == self.minDate.tm_year && month == self.minDate.tm_month && day == self.minDate.tm_day) {
        startHour = self.minDate.tm_hour;
    }
    if (year == self.maxDate.tm_year && month == self.maxDate.tm_month && day == self.maxDate.tm_day) {
        endHour = self.maxDate.tm_hour;
    }
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:(endHour - startHour + 1)];
    for (NSInteger i = startHour; i <= endHour; i ++) {
        [tempArr addObject:[@(i) stringValue]];
    }
    return [tempArr copy];
}

- (NSArray *)getMinuteArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour {
    NSInteger startMinute = 0;
    NSInteger endMinute = 59;
    if (year == self.minDate.tm_year && month == self.minDate.tm_month && day == self.minDate.tm_day && hour == self.minDate.tm_hour) {
        startMinute = self.minDate.tm_minute;
    }
    if (year == self.maxDate.tm_year && month == self.maxDate.tm_month && day == self.maxDate.tm_day  && hour == self.maxDate.tm_hour) {
        endMinute = self.maxDate.tm_minute;
    }
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:(endMinute - startMinute + 1)];
    for (NSInteger i = startMinute; i <= endMinute; i ++) {
        [tempArr addObject:[@(i) stringValue]];
    }
    return [tempArr copy];
}

- (NSArray *)getSecondArr:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute {
    NSInteger startSecond = 0;
    NSInteger endSecond = 59;
    if (year == self.minDate.tm_year && month == self.minDate.tm_month && day == self.minDate.tm_day && hour == self.minDate.tm_hour && minute == self.minDate.tm_minute) {
        startSecond = self.minDate.tm_second;
    }
    if (year == self.maxDate.tm_year && month == self.maxDate.tm_month && day == self.maxDate.tm_day && hour == self.maxDate.tm_hour && minute == self.maxDate.tm_minute) {
        endSecond = self.maxDate.tm_second;
    }
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:(endSecond - startSecond + 1)];
    for (NSInteger i = startSecond; i <= endSecond; i ++) {
        [tempArr addObject:[@(i) stringValue]];
    }
    return [tempArr copy];
}

#pragma mark  滚动到指定的时间位置
- (void)scrollToSelectDate:(NSDate *)selectDate animated:(BOOL)animated {
    // 根据当前的日期，计算出对映的索引
    NSInteger yearIndex = selectDate.tm_year - self.minDate.tm_year;
    NSInteger monthIndex = selectDate.tm_month - ((yearIndex == 0) ? self.minDate.tm_month : 1);
    NSInteger dayIndex = selectDate.tm_day - ((yearIndex == 0 && monthIndex == 0) ? self.minDate.tm_day : 1);
    NSInteger hourIndex = selectDate.tm_hour - ((yearIndex == 0 && monthIndex == 0 && dayIndex == 0) ? self.minDate.tm_hour : 0);
    NSInteger minuteIndex = selectDate.tm_minute - ((yearIndex == 0 && monthIndex == 0 && dayIndex == 0 && hourIndex == 0) ? self.minDate.tm_minute : 0);
    NSUInteger secondIndex = selectDate.tm_second - ((yearIndex == 0 && monthIndex == 0 && dayIndex == 0 && hourIndex == 0 && minuteIndex == 0) ? self.minDate.tm_second : 0);
    
    self.yearIndex = yearIndex;
    self.monthIndex = monthIndex;
    self.dayIndex = dayIndex;
    self.hourIndex = hourIndex;
    self.minuteIndex = minuteIndex;
    self.secondIndex = secondIndex;
    NSArray *indexArr = [NSArray array];
    if (self.pickerMode == TMDatePickerModeYMDHMS) {
        indexArr = @[@(yearIndex), @(monthIndex), @(dayIndex), @(hourIndex), @(minuteIndex), @(secondIndex)];
    } else if (self.pickerMode == TMDatePickerModeYMDHM) {
        indexArr = @[@(yearIndex), @(monthIndex), @(dayIndex), @(hourIndex), @(minuteIndex)];
    } else if (self.pickerMode == TMDatePickerModeYMDH) {
        indexArr = @[@(yearIndex), @(monthIndex), @(dayIndex), @(hourIndex)];
    } else if (self.pickerMode == TMDatePickerModeMDHM) {
        indexArr = @[@(monthIndex), @(dayIndex), @(hourIndex), @(minuteIndex)];
    } else if (self.pickerMode == TMDatePickerModeYMD) {
        indexArr = @[@(yearIndex), @(monthIndex), @(dayIndex)];
    } else if (self.pickerMode == TMDatePickerModeYM) {
        indexArr = @[@(yearIndex), @(monthIndex)];
    } else if (self.pickerMode == TMDatePickerModeY) {
        indexArr = @[@(yearIndex)];
    } else if (self.pickerMode == TMDatePickerModeMD) {
        indexArr = @[@(monthIndex), @(dayIndex)];
    } else if (self.pickerMode == TMDatePickerModeHMS) {
        indexArr = @[@(hourIndex), @(minuteIndex), @(secondIndex)];
    } else if (self.pickerMode == TMDatePickerModeHM) {
        indexArr = @[@(hourIndex), @(minuteIndex)];
    } else if (self.pickerMode == TMDatePickerModeMS) {
        indexArr = @[@(minuteIndex), @(secondIndex)];
    }
    for (NSInteger i = 0; i < indexArr.count; i++) {
        [self.pickerView selectRow:[indexArr[i] integerValue] inComponent:i animated:animated];
    }
}

#pragma mark  UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.pickerMode == TMDatePickerModeYMDHMS) {
        return 6;
    } else if (self.pickerMode == TMDatePickerModeYMDHM) {
        return 5;
    } else if (self.pickerMode == TMDatePickerModeYMDH) {
        return 4;
    } else if (self.pickerMode == TMDatePickerModeMDHM) {
        return 4;
    } else if (self.pickerMode == TMDatePickerModeYMD) {
        return 3;
    } else if (self.pickerMode == TMDatePickerModeYM) {
        return 2;
    } else if (self.pickerMode == TMDatePickerModeY) {
        return 1;
    } else if (self.pickerMode == TMDatePickerModeMD) {
        return 2;
    } else if (self.pickerMode == TMDatePickerModeHMS) {
        return 3;
    } else if (self.pickerMode == TMDatePickerModeHM) {
        return 2;
    } else if (self.pickerMode == TMDatePickerModeMS) {
        return 2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *rowsArr = [NSArray array];
    if (self.pickerMode == TMDatePickerModeYMDHMS) {
        rowsArr = @[@(self.yearArr.count),@(self.monthArr.count),@(self.dayArr.count),
                    @(self.hourArr.count),@(self.minuteArr.count),@(self.secondArr.count)];
    } else if (self.pickerMode == TMDatePickerModeYMDHM) {
        rowsArr = @[@(self.yearArr.count),@(self.monthArr.count),@(self.dayArr.count),
                    @(self.hourArr.count),@(self.minuteArr.count)];
    } else if (self.pickerMode == TMDatePickerModeYMDH) {
        rowsArr = @[@(self.yearArr.count),@(self.monthArr.count),@(self.dayArr.count),
                    @(self.hourArr.count)];
    } else if (self.pickerMode == TMDatePickerModeMDHM) {
        rowsArr = @[@(self.monthArr.count),@(self.dayArr.count),@(self.hourArr.count),
                    @(self.minuteArr.count)];
    } else if (self.pickerMode == TMDatePickerModeYMD) {
        rowsArr = @[@(self.yearArr.count),@(self.monthArr.count),@(self.dayArr.count)];
    } else if (self.pickerMode == TMDatePickerModeYM) {
        rowsArr = @[@(self.yearArr.count),@(self.monthArr.count)];
    } else if (self.pickerMode == TMDatePickerModeY) {
        rowsArr = @[@(self.yearArr.count)];
    } else if (self.pickerMode == TMDatePickerModeMD) {
        rowsArr = @[@(self.monthArr.count),@(self.dayArr.count)];
    } else if (self.pickerMode == TMDatePickerModeHMS) {
        rowsArr = @[@(self.hourArr.count),@(self.minuteArr.count),@(self.secondArr.count)];
    } else if (self.pickerMode == TMDatePickerModeHM) {
        rowsArr = @[@(self.hourArr.count),@(self.minuteArr.count)];
    } else if (self.pickerMode == TMDatePickerModeMS) {
        rowsArr = @[@(self.minuteArr.count),@(self.secondArr.count)];
    }
    return [rowsArr[component] integerValue];
}

#pragma mark  UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    // 设置分割线的颜色
    for (UIView *subView in pickerView.subviews) {
        if (subView && [subView isKindOfClass:[UIView class]] && subView.frame.size.height <= 1) {
            subView.backgroundColor = BR_RGB_HEX(0xc6c6c8, 1.0f);;
        }
    }
    
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = kBRDefaultTextColor;
        // 字体自适应属性
        label.adjustsFontSizeToFitWidth = YES;
        // 自适应最小字体缩放比例
        label.minimumScaleFactor = 0.5f;
    }
    
    if (self.pickerMode == TMDatePickerModeYMDHMS) {
        if (component == 0) {
            label.text = self.yearArr[row];
        } else if (component == 1) {
            label.text = self.monthArr[row];
        } else if (component == 2) {
            label.text = self.dayArr[row];
        } else if (component == 3) {
            label.text = self.hourArr[row];
        } else if (component == 4) {
            label.text = self.minuteArr[row];
        } else if (component == 5) {
            label.text = self.secondArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeYMDHM) {
        if (component == 0) {
            label.text = self.yearArr[row];
        } else if (component == 1) {
            label.text = self.monthArr[row];
        } else if (component == 2) {
            label.text = self.dayArr[row];
        } else if (component == 3) {
            label.text = self.hourArr[row];
        } else if (component == 4) {
            label.text = self.minuteArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeYMDH) {
        if (component == 0) {
            label.text = self.yearArr[row];
        } else if (component == 1) {
            label.text = self.monthArr[row];
        } else if (component == 2) {
            label.text = self.dayArr[row];
        } else if (component == 3) {
            label.text = self.hourArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeMDHM) {
        if (component == 0) {
            label.text = self.monthArr[row];
        } else if (component == 1) {
            label.text = self.dayArr[row];
        } else if (component == 2) {
            label.text = self.hourArr[row];
        } else if (component == 3) {
            label.text = self.minuteArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeYMD) {
        if (component == 0) {
            label.text = self.yearArr[row];
        } else if (component == 1) {
            label.text = self.monthArr[row];
        } else if (component == 2) {
            label.text = self.dayArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeYM) {
        if (component == 0) {
            label.text = self.yearArr[row];
        } else if (component == 1) {
            label.text = self.monthArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeY) {
        if (component == 0) {
            label.text = self.yearArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeMD) {
        if (component == 0) {
            label.text = self.monthArr[row];
        } else if (component == 1) {
            label.text = self.dayArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeHMS) {
        if (component == 0) {
            label.text = self.hourArr[row];
        } else if (component == 1) {
            label.text = self.minuteArr[row];
        } else if (component == 2) {
            label.text = self.secondArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeHM) {
        if (component == 0) {
            label.text = self.hourArr[row];
        } else if (component == 1) {
            label.text = self.minuteArr[row];
        }
    } else if (self.pickerMode == TMDatePickerModeMS) {
        if (component == 0) {
            label.text = self.minuteArr[row];
        } else if (component == 1) {
            label.text = self.secondArr[row];
        }
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.pickerMode == TMDatePickerModeYMDHMS) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDataArrayWithUpdateMonth:YES updateDay:YES updateHour:YES updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
            [self.pickerView reloadComponent:5];
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:YES updateHour:YES updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
            [self.pickerView reloadComponent:5];
        } else if (component == 2) {
            self.dayIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
            [self.pickerView reloadComponent:5];
        } else if (component == 3) {
            self.hourIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:4];
            [self.pickerView reloadComponent:5];
        } else if (component == 4) {
            self.minuteIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:YES];
            [self.pickerView reloadComponent:5];
        } else if (component == 5) {
            self.secondIndex = row;
        }
        
        if (self.yearArr.count == 0 || self.monthArr.count == 0 || self.dayArr.count == 0 || self.hourArr.count == 0 || self.minuteArr.count == 0 || self.secondArr.count == 0) {
            return;
        }
        NSInteger year = [self.yearArr[self.yearIndex] integerValue];
        NSInteger month = [self.monthArr[self.monthIndex] integerValue];
        NSInteger day = [self.dayArr[self.dayIndex] integerValue];
        NSInteger hour = [self.hourArr[self.hourIndex] integerValue];
        NSInteger minute = [self.minuteArr[self.minuteIndex] integerValue];
        NSInteger second = [self.secondArr[self.secondIndex] integerValue];
        self.mSelectDate = [NSDate tm_setYear:year month:month day:day hour:hour minute:minute second:second];
    } else if (self.pickerMode == TMDatePickerModeYMDHM) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDataArrayWithUpdateMonth:YES updateDay:YES updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:YES updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
        } else if (component == 2) {
            self.dayIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:3];
            [self.pickerView reloadComponent:4];
        } else if (component == 3) {
            self.hourIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:4];
        } else if (component == 4) {
            self.minuteIndex = row;
        }
        
        if (self.yearArr.count == 0 || self.monthArr.count == 0 || self.dayArr.count == 0 || self.hourArr.count == 0 || self.minuteArr.count == 0) {
            return;
        }
        NSInteger year = [self.yearArr[self.yearIndex] integerValue];
        NSInteger month = [self.monthArr[self.monthIndex] integerValue];
        NSInteger day = [self.dayArr[self.dayIndex] integerValue];
        NSInteger hour = [self.hourArr[self.hourIndex] integerValue];
        NSInteger minute = [self.minuteArr[self.minuteIndex] integerValue];
        self.mSelectDate = [NSDate tm_setYear:year month:month day:day hour:hour minute:minute];
    } else if (self.pickerMode == TMDatePickerModeYMDH) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDataArrayWithUpdateMonth:YES updateDay:YES updateHour:YES updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:YES updateHour:YES updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
        } else if (component == 2) {
            self.dayIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:3];
        } else if (component == 3) {
            self.hourIndex = row;
        }
        
        if (self.yearArr.count == 0 || self.monthArr.count == 0 || self.dayArr.count == 0 || self.hourArr.count == 0) {
            return;
        }
        NSInteger year = [self.yearArr[self.yearIndex] integerValue];
        NSInteger month = [self.monthArr[self.monthIndex] integerValue];
        NSInteger day = [self.dayArr[self.dayIndex] integerValue];
        NSInteger hour = [self.hourArr[self.hourIndex] integerValue];
        self.mSelectDate = [NSDate tm_setYear:year month:month day:day hour:hour];
    } else if (self.pickerMode == TMDatePickerModeMDHM) {
        if (component == 0) {
            self.monthIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:YES updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
        } else if (component == 1) {
            self.dayIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:YES updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:2];
            [self.pickerView reloadComponent:3];
        } else if (component == 2) {
            self.hourIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:3];
        } else if (component == 3) {
            self.minuteIndex = row;
        }
        
        if (self.monthArr.count == 0 || self.dayArr.count == 0 || self.hourArr.count == 0 || self.minuteArr.count == 0) {
            return;
        }
        NSInteger month = [self.monthArr[self.monthIndex] integerValue];
        NSInteger day = [self.dayArr[self.dayIndex] integerValue];
        NSInteger hour = [self.hourArr[self.hourIndex] integerValue];
        NSInteger minute = [self.minuteArr[self.minuteIndex] integerValue];
        self.mSelectDate = [NSDate tm_setMonth:month day:day hour:hour minute:minute];
    } else if (self.pickerMode == TMDatePickerModeYMD) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDataArrayWithUpdateMonth:YES updateDay:YES updateHour:NO updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:1];
            [self.pickerView reloadComponent:2];
        } else if (component == 1) {
            self.monthIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:YES updateHour:NO updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:2];
        } else if (component == 2) {
            self.dayIndex = row;
        }
        
        if (self.yearArr.count == 0 || self.monthArr.count == 0 || self.dayArr.count == 0) {
            return;
        }
        NSInteger year = [self.yearArr[self.yearIndex] integerValue];
        NSInteger month = [self.monthArr[self.monthIndex] integerValue];
        NSInteger day = [self.dayArr[self.dayIndex] integerValue];
        self.mSelectDate = [NSDate tm_setYear:year month:month day:day];
    } else if (self.pickerMode == TMDatePickerModeYM) {
        if (component == 0) {
            self.yearIndex = row;
            [self reloadDataArrayWithUpdateMonth:YES updateDay:NO updateHour:NO updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.monthIndex = row;
        }
        
        if (self.yearArr.count == 0 || self.monthArr.count == 0) {
            return;
        }
        NSInteger year = [self.yearArr[self.yearIndex] integerValue];
        NSInteger month = [self.monthArr[self.monthIndex] integerValue];
        self.mSelectDate = [NSDate tm_setYear:year month:month];
    } else if (self.pickerMode == TMDatePickerModeY) {
        if (component == 0) {
            self.yearIndex = row;
        }
        
        if (self.yearArr.count == 0) {
            return;
        }
        NSInteger year = [self.yearArr[self.yearIndex] integerValue];
        self.mSelectDate = [NSDate tm_setYear:year];
    } else if (self.pickerMode == TMDatePickerModeMD) {
        if (component == 0) {
            self.monthIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:YES updateHour:NO updateMinute:NO updateSecond:NO];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.dayIndex = row;
        }
        
        if (self.monthArr.count == 0 || self.dayArr.count == 0) {
            return;
        }
        NSInteger month = [self.monthArr[self.monthIndex] integerValue];
        NSInteger day = [self.dayArr[self.dayIndex] integerValue];
        self.mSelectDate = [NSDate tm_setMonth:month day:day];
    } else if (self.pickerMode == TMDatePickerModeHMS) {
        if (component == 0) {
            self.hourIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:YES];
            [self.pickerView reloadComponent:0];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.minuteIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:YES];
            [self.pickerView reloadComponent:1];
        } else if (component == 2) {
            self.secondIndex = row;
        }
        
        if (self.hourArr.count == 0 || self.minuteArr.count == 0 || self.secondArr.count == 0) {
            return;
        }
        NSInteger hour = [self.hourArr[self.hourIndex] integerValue];
        NSInteger minute = [self.minuteArr[self.minuteIndex] integerValue];
        NSInteger second = [self.secondArr[self.secondIndex] integerValue];
        self.mSelectDate = [NSDate tm_setHour:hour minute:minute second:second];
    } else if (self.pickerMode == TMDatePickerModeHM) {
        if (component == 0) {
            self.hourIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:YES updateSecond:NO];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.minuteIndex = row;
        }
        
        if (self.hourArr.count == 0 || self.minuteArr.count == 0) {
            return;
        }
        NSInteger hour = [self.hourArr[self.hourIndex] integerValue];
        NSInteger minute = [self.minuteArr[self.minuteIndex] integerValue];
        self.mSelectDate = [NSDate tm_setHour:hour minute:minute];
    } else if (self.pickerMode == TMDatePickerModeMS) {
        if (component == 0) {
            self.minuteIndex = row;
            [self reloadDataArrayWithUpdateMonth:NO updateDay:NO updateHour:NO updateMinute:NO updateSecond:YES];
            [self.pickerView reloadComponent:1];
        } else if (component == 1) {
            self.secondIndex = row;
        }
        
        if (self.minuteArr.count == 0 || self.secondArr.count == 0) {
            return;
        }
        NSInteger minute = [self.minuteArr[self.minuteIndex] integerValue];
        NSInteger second = [self.secondArr[self.secondIndex] integerValue];
        self.mSelectDate = [NSDate tm_setMinute:minute second:second];
    }
    
    // 滚动选择时执行changeBlock
    if (self.changeBlock) {
        self.changeBlock(self.mSelectDate);
    }
    
    // 设置自动选择时，滚动选择时就执行 resultBlock
    if (self.isAutoSelect) {
        if (self.resultBlock) {
            self.resultBlock(self.mSelectDate);
        }
    }
}

/// 显示
- (void)show {
    
    [self setupDateFormatter:self.pickerMode];
    
    self.frame = SCREEN_BOUNDS;
    // 设置子视图的宽度随着父视图变化
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.maskView];
    [self addSubview:self.alertView];
    [self.alertView addSubview:self.toolBar];
    [self.toolBar addSubview:self.cancelButton];
    [self.toolBar addSubview:self.doneButton];
    [self.toolBar addSubview:self.titleLabel];
    
    [self reloadData];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    CGRect rect = self.alertView.frame;
    rect.origin.y = SCREEN_HEIGHT;
    self.alertView.frame = rect;
    self.maskView.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 1;
        CGFloat pickerHeight = self.alertView.bounds.size.height;
        CGRect rect = self.alertView.frame;
        rect.origin.y -= pickerHeight;
        self.alertView.frame = rect;
    }];
}

/// 消失
- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        CGFloat pickerHeight = self.alertView.bounds.size.height;
        CGRect rect = self.alertView.frame;
        rect.origin.y += pickerHeight;
        self.alertView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark  确认按钮点击
- (void)doneClick {
    [self dismiss];
    if (self.resultBlock) {
        self.resultBlock(self.mSelectDate);
    }
}

#pragma mark  setter
- (void)setSelectDate:(NSDate *)selectDate {
    _selectDate = selectDate;
    _mSelectDate = selectDate;
    if (_pickerView) {
        [self reloadData];
    }
}

#pragma mark  getter
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:SCREEN_BOUNDS];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        // 设置子视图的大小随着父视图变化
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_maskView addGestureRecognizer:tapGesture];
    }
    return _maskView;
}

- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 216.0f * kScaleFit + 44)];
        _alertView.backgroundColor = [UIColor whiteColor];
    }
    return _alertView;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 216.0f * kScaleFit)];
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.showsSelectionIndicator = YES;
        [self.alertView addSubview:_pickerView];
    }
    return _pickerView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:kBRDefaultTextColor forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _cancelButton.frame = CGRectMake(5, 8, 60, 28);
    }
    return _cancelButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
        [_doneButton setTitleColor:kBRDefaultTextColor forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _doneButton.frame = CGRectMake(SCREEN_WIDTH - 60 - 5, 8, 60, 28);
    }
    return _doneButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + 60 + 2, 0, SCREEN_WIDTH - 2 * (5 + 60 + 2), 44)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15.f];
        _titleLabel.textColor = BR_RGB_HEX(0x999999, 1.0f);
        _titleLabel.text = @"选择日期";
    }
    return _titleLabel;
}

- (UIView *)toolBar {
    if (!_toolBar) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        _toolBar.backgroundColor = UIColor.whiteColor;
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _toolBar;
}

- (NSArray *)yearArr {
    if (!_yearArr) {
        _yearArr = [NSArray array];
    }
    return _yearArr;
}

- (NSArray *)monthArr {
    if (!_monthArr) {
        _monthArr = [NSArray array];
    }
    return _monthArr;
}

- (NSArray *)dayArr {
    if (!_dayArr) {
        _dayArr = [NSArray array];
    }
    return _dayArr;
}

- (NSArray *)hourArr {
    if (!_hourArr) {
        _hourArr = [NSArray array];
    }
    return _hourArr;
}

- (NSArray *)minuteArr {
    if (!_minuteArr) {
        _minuteArr = [NSArray array];
    }
    return _minuteArr;
}

- (NSArray *)secondArr {
    if (!_secondArr) {
        _secondArr = [NSArray array];
    }
    return _secondArr;
}

- (NSInteger)yearIndex {
    if (_yearIndex < 0) {
        _yearIndex = 0;
    } else {
        _yearIndex = MIN(_yearIndex, self.yearArr.count - 1);
    }
    return _yearIndex;
}

- (NSInteger)monthIndex {
    if (_monthIndex < 0) {
        _monthIndex = 0;
    } else {
        _monthIndex = MIN(_monthIndex, self.monthArr.count - 1);
    }
    return _monthIndex;
}

- (NSInteger)dayIndex {
    if (_dayIndex < 0) {
        _dayIndex = 0;
    } else {
        _dayIndex = MIN(_dayIndex, self.dayArr.count - 1);
    }
    return _dayIndex;
}

- (NSInteger)hourIndex {
    if (_hourIndex < 0) {
        _hourIndex = 0;
    } else {
        _hourIndex = MIN(_hourIndex, self.hourArr.count - 1);
    }
    return _hourIndex;
}

- (NSInteger)minuteIndex {
    if (_minuteIndex < 0) {
        _minuteIndex = 0;
    } else {
        _minuteIndex = MIN(_minuteIndex, self.minuteArr.count - 1);
    }
    return _minuteIndex;
}

- (NSInteger)secondIndex {
    if (_secondIndex < 0) {
        _secondIndex = 0;
    } else {
        _secondIndex = MIN(_secondIndex, self.secondArr.count - 1);
    }
    return _secondIndex;
}

- (NSArray *)unitArr {
    if (!_unitArr) {
        _unitArr = [NSArray array];
    }
    return _unitArr;
}

- (NSArray<UILabel *> *)unitLabelArr {
    if (!_unitLabelArr) {
        _unitLabelArr = [NSArray array];
    }
    return _unitLabelArr;
}

- (NSArray<NSString *> *)monthNames {
    if (!_monthNames) {
        _monthNames = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    }
    return _monthNames;
}

@end
