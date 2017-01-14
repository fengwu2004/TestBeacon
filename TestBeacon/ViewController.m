//
//  ViewController.m
//  TestBeacon
//
//  Created by ky on 14/01/2017.
//  Copyright © 2017 yellfun. All rights reserved.
//

#import "ViewController.h"
#import <IndoorunSDK/IndoorunSDK.h>

@interface ViewController ()<IDRBaseLocationServerDelegate, UITextViewDelegate>

@property (nonatomic) IDRBaseLocationServer *baseLocator;
@property (nonatomic, copy) NSString *major;
@property (nonatomic, copy) NSString *minor;
@property (nonatomic, copy) NSString *beaconUUID;
@property (nonatomic, copy) NSString *testCount;

@property (nonatomic) IBOutlet UITextView *ibMajor;
@property (nonatomic) IBOutlet UITextView *ibMinor;
@property (nonatomic) IBOutlet UITextView *ibTestCount;
@property (nonatomic) IBOutlet UILabel *ibUUID;
@property (nonatomic) IBOutlet UIButton *ibStart;
@property (nonatomic) IBOutlet UIButton *ibEnd;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.beaconUUID = @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825";
    
    self.testCount = @"0";
    
    self.major = @"0";
    
    self.minor = @"0";
    
    [_ibUUID setText:self.beaconUUID];
    
    [_ibTestCount setText:self.testCount];
    
    [_ibMajor setText:self.major];
    
    [_ibMinor setText:self.minor];
}

- (void)startCollect {
    
    _major = _ibMajor.text;
    
    _minor = _ibMinor.text;
    
    _testCount = _ibTestCount.text;
    
    [_ibStart setEnabled:NO];
    
    if (!_baseLocator) {
        
        _baseLocator = [[IDRBaseLocationServer alloc] init];
    }
    
    [[IDRLogManager sharedInstance] log1:@"开始记录"];
    
    [[IDRLogManager sharedInstance] log1:[NSString stringWithFormat:@"测试干扰数据源:%@", _ibTestCount.text]];
    
    [_baseLocator setBeaconUUID:@[_beaconUUID]];
    
    [_baseLocator setDelegate:self];
    
    [_baseLocator startUpdateBeacons];
}

- (IBAction)onSetCountOk:(id)sender {
    
    [_ibMajor resignFirstResponder];
    
    [_ibMinor resignFirstResponder];
    
    [_ibTestCount resignFirstResponder];
}

- (IBAction)onStart:(id)sender {
    
    [self startCollect];
}

- (IBAction)onEnd:(id)sender {
    
    [_baseLocator stopUpdateBeacons];
    
    _baseLocator = nil;
    
    [[IDRLogManager sharedInstance] log1:@"结束采集"];
    
    [[IDRLogManager sharedInstance] flush];
    
    [_ibStart setEnabled:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [_ibMinor resignFirstResponder];
    
    [_ibMinor resignFirstResponder];
    
    [_ibTestCount resignFirstResponder];
}

- (void)didGetRangeBeacons:(NSArray *)beacons {
    
    NSString *value = @"没有采集到";
    
    NSString *mm = [NSString stringWithFormat:@"major:%@minor:%@", _major, _minor];
    
    for (NSDictionary *data in beacons) {
        
        NSString *mac = [data objectForKey:@"mac"];
        
        NSString *rssi = [data objectForKey:@"rss"];
        
        if ([mac isEqualToString:mm]) {
            
            value = [rssi copy];
        }
    }
    
    [[IDRLogManager sharedInstance] log1:value];
}


@end
