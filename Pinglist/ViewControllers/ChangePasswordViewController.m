//
//  ChangePasswordViewController.m
//  Pinglist
//
//  Created by admin on 5/6/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Global.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.txtFieldConfirm.font       =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    self.txtFieldOld.font           =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    self.txtFieldNew.font           =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    self.txtFieldConfirm.textColor  =       GREEN_COLOR;
    self.txtFieldNew.textColor      =       GREEN_COLOR;
    self.txtFieldOld.textColor      =       GREEN_COLOR;
    
    [Global changePlaceholderTextColor:self.txtFieldOld text:@"Old password" color:GREEN_COLOR];
    [Global changePlaceholderTextColor:self.txtFieldNew text:@"New password" color:GREEN_COLOR];
    [Global changePlaceholderTextColor:self.txtFieldConfirm text:@"Confirm password" color:GREEN_COLOR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.txtFieldConfirm   resignFirstResponder];
    [self.txtFieldNew       resignFirstResponder];
    [self.txtFieldOld       resignFirstResponder];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onChange:(id)sender {
    if (![self.txtFieldNew.text isEqualToString:self.txtFieldConfirm.text]) {
        [Global showAlert:@"Password does not match!" sender:self];
        return;
    }
    
    if ([self.txtFieldConfirm.text isEqualToString:@""] || [self.txtFieldNew.text isEqualToString:@""]) {
        [Global showAlert:@"Empty string is not allowed for password!" sender:self];
        return;
    }
    
    if ([Global sharedInstance].credential.isExpired) {
        [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
            [self onChange:sender];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
    
    else {
        NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/accounts/users/%d", endpointURL, self.myUserId];
        NSDictionary *params    =   @{@"password"       :   self.txtFieldOld.text,
                                      @"new_password"   :   self.txtFieldNew.text};
        
        [SVProgressHUD showWithStatus:@"Saving" maskType:SVProgressHUDMaskTypeClear];
        [[Global afManager] PUT:requestURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
            [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
        }];
    }
}
@end
