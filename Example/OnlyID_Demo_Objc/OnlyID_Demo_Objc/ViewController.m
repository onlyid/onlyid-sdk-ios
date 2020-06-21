//
//  ViewController.m
//  OnlyID_Demo_Objc
//
//  Created by Jarvis on 2020/6/21.
//  Copyright © 2020 QFish. All rights reserved.
//

#import "ViewController.h"
#import <OnlyID-Swift.h>

#define ClientId @"73c6cce568d34a25ac426a26a1ca0c1e"
#define SecretId @"36c820ba83bb4944a0744208066e8bbf"

@interface ViewController () <OnlyIDOAuthDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *loginItem = [[UIBarButtonItem alloc] initWithTitle:@"login" style:UIBarButtonItemStylePlain target:self action:@selector(oauth)];
    self.navigationItem.rightBarButtonItem = loginItem;
}

- (void)oauth {
    OnlyIDOAuthConfig *config = [[OnlyIDOAuthConfig alloc] initWithClientId:ClientId view:nil theme:nil state:nil];
    [OnlyID oauthWithConfig:config fromController:nil delegate:self];
}

- (void)onCompleteWithCode:(NSString *)code state:(NSString *)state {
    NSLog(@"Login successed: %@, %@", code, state);
    
    UILabel *label = [UILabel new];
    label.text = code;
    label.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

- (void)onErrorWithError:(NSError *)error {
    NSLog(@"Login failed: %@", error);
}

- (void)onCancel {
    NSLog(@"Login canceled");
}

@end
