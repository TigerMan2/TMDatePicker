//
//  ViewController.m
//  TMDatePicker
//
//  Created by Luther on 2020/3/26.
//  Copyright © 2020 mrstock. All rights reserved.
//

#import "ViewController.h"
#import "TMDatePicker.h"
#import "NSDate+TMDatePicker.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton *tapButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.tapButton.frame = CGRectMake(0, 0, 200, 40);
    self.tapButton.backgroundColor = [UIColor redColor];
    self.tapButton.center = self.view.center;
    [self.tapButton addTarget:self action:@selector(tapClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tapButton];
    
}

- (void)tapClick:(UIButton *)sender {
    TMDatePicker *pickerView = [[TMDatePicker alloc] init];
    pickerView.pickerMode = TMDatePickerModeYMDHMS;
    pickerView.isAutoSelect = YES;
    [pickerView show];
    
    __weak typeof(self) weakSelf = self;
    pickerView.resultBlock = ^(NSDate * _Nullable selectDate) {
        NSString *selectValue = [NSDate tm_getDataString:selectDate format:@"yyyy-MM-dd HH:mm:ss"];
        [weakSelf.tapButton setTitle:selectValue forState:UIControlStateNormal];
    };
}


@end
