//
//  TMDatePicker.h
//  TMDatePicker
//
//  Created by Luther on 2020/3/26.
//  Copyright © 2020 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TMDatePickerMode) {
    TMDatePickerModeYMDHMS,         //!< 【yyyy-MM-dd HH:mm:ss】年月日时分秒
    TMDatePickerModeYMDHM,          //!< 【yyyy-MM-dd HH:mm】年月日时分
    TMDatePickerModeYMDH,           //!< 【yyyy-MM-dd HH】年月日时
    TMDatePickerModeMDHM,           //!< 【MM-dd HH:mm】月日时分
    TMDatePickerModeYMD,            //!< 【yyyy-MM-dd】年月日
    TMDatePickerModeYM,             //!< 【yyyy-MM】年月
    TMDatePickerModeY,              //!< 【yyyy】年
    TMDatePickerModeMD,             //!< 【MM-dd】月日
    TMDatePickerModeHMS,            //!< 【HH:mm:ss】时分秒
    TMDatePickerModeHM,             //!< 【HH:mm】时分
    TMDatePickerModeMS,             //!< 【mm:ss】分秒
};

typedef void(^TMDateResultBlock)(NSDate * _Nullable selectDate);

@interface TMDatePicker : UIView

/// 日期选择器显示类型
@property (nonatomic, assign) TMDatePickerMode pickerMode;
/// 选中日期(NSDate类型)
@property (nonatomic, strong) NSDate *selectDate;
/// 最小时间
@property (nonatomic, strong) NSDate *minDate;
/// 最大时间
@property (nonatomic, strong) NSDate *maxDate;

/// 选择结果的block
@property (nonatomic, copy) TMDateResultBlock resultBlock;
/// 滚动结束时，出发的回调
@property (nonatomic, copy) TMDateResultBlock changeBlock;

/// 是否滚动结束自动选择 默认是NO
@property (nonatomic, assign) BOOL isAutoSelect;

- (void)dismiss;
- (void)show;

@end

NS_ASSUME_NONNULL_END
