//
//  ViewController.m
//  TestBeacon
//
//  Created by ky on 14/01/2017.
//  Copyright © 2017 yellfun. All rights reserved.
//

#import "ViewController.h"
#import <IndoorunSDK/IndoorunSDK.h>
#import <MessageUI/MessageUI.h>

@interface ViewController ()<IDRBaseLocationServerDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) IDRBaseLocationServer *baseLocator;
@property (nonatomic, copy) NSString *beaconUUID;
@property (nonatomic, assign) NSInteger testCount;

@property (nonatomic) IBOutlet UITextView *ibUUID;
@property (nonatomic) IBOutlet UIButton *ibStart;
@property (nonatomic) IBOutlet UIButton *ibEnd;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.beaconUUID = @"AB8190D5-D11E-4941-ACC4-42F30510B408";
    
    self.testCount = 0;
    
    [_ibUUID setText:self.beaconUUID];
}

- (void)startCollect {
    
    ++_testCount;
    
    [_ibStart setEnabled:NO];
    
    if (!_baseLocator) {
        
        _baseLocator = [[IDRBaseLocationServer alloc] init];
    }
    
    [[IDRLogManager sharedInstance] log1:@"开始记录"];
    
    [[IDRLogManager sharedInstance] log1:[NSString stringWithFormat:@"测试干扰数据源:%d", (int)_testCount]];
    
    [_baseLocator setBeaconUUID:@[_beaconUUID]];
    
    [_baseLocator setDelegate:self];
    
    [_baseLocator startUpdateBeacons];
}

- (IBAction)onSetCountOk:(id)sender {
    
    [_ibUUID resignFirstResponder];
    
    self.beaconUUID = [_ibUUID text];
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
    
    [_ibUUID resignFirstResponder];
    
    self.beaconUUID = [_ibUUID text];
}

- (void)didGetRangeBeacons:(NSArray *)beacons {
    
    for (NSDictionary *data in beacons) {
        
        NSString *dis = [data objectForKey:@"distance"];
        
        NSString *mac = [data objectForKey:@"mac"];
        
        NSString *rss = [data objectForKey:@"rss"];
        
        [[IDRLogManager sharedInstance] log1:[NSString stringWithFormat:@"%@, distance:%@, rss:%@", mac, dis, rss]];
    }
    
    [[IDRLogManager sharedInstance] log1:@"这是一次beacon扫描"];
}

- (void)sendMail {
    
    NSMutableString *mailUrl = [[NSMutableString alloc] init];
    
    [mailUrl appendFormat:@"mailto:yanli@yellfun.com, "];
    
    [mailUrl appendFormat:@"subject=my email"];
    
    [mailUrl appendFormat:@"&body=<b>email</b>body!"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailUrl] options:@{@"":@""} completionHandler:^(BOOL success) {
        
        
    }];
}

- (IBAction)onSendClick:(id)sender {
    
    [self newSendMail];
}

- (void)newSendMail {
    
    if (![MFMailComposeViewController canSendMail]) {
        
        return;
    }
    
    MFMailComposeViewController *vctl = [[MFMailComposeViewController alloc] init];
    
    vctl.mailComposeDelegate = self;
    
    [vctl setSubject:@"TestBeacon数据"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *fileName1 = [NSString stringWithFormat:@"logfile1.log"];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:fileName1];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (data) {
        
        [vctl setToRecipients:@[@"yanli@yellfun.com"]];
        
        [vctl setCcRecipients:@[@"hexiaofeng@yellfun.com"]];
        
        [vctl addAttachmentData:data mimeType:@"" fileName:@"log1"];
        
        [self presentViewController:vctl animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *fileName1 = [NSString stringWithFormat:@"logfile1.log"];
    
    NSString *path = [documentDirectory stringByAppendingPathComponent:fileName1];
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
