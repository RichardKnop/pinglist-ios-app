//
//  ProfileViewController.m
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "ProfileViewController.h"
#import "ChangePasswordViewController.h"
#import "Global.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)getMe {
    if ([Global sharedInstance].credential.isExpired) {
        [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
            [self getMe];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
    
    else {
        NSString *requestURL = [NSString stringWithFormat:@"%@/v1/accounts/me", endpointURL];
        
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
        [[Global afManager] GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            myUserId                        =   [responseObject[@"id"] intValue];
            self.txtFieldLastname.text      =   responseObject[@"last_name"];
            self.txtFieldFirstname.text     =   responseObject[@"first_name"];
            self.txtFieldEmail.text         =   responseObject[@"email"];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
            [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
        }];
        
        requestURL = [NSString stringWithFormat:@"%@/v1/subscriptions", endpointURL];
        
        [[Global afManager] GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            NSArray *subscriptions          =   responseObject[@"_embedded"][@"subscriptions"];
            
            if (subscriptions.count == 0) {
                self.lblSubscription.text   =   @"Subscription: FREE";
            }
            
            else {
                NSDictionary *first         =   subscriptions[0];
                self.lblSubscription.text   =   [NSString stringWithFormat:@"Subscription: %@", first[@"_embedded"][@"plan"][@"name"]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
            [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getMe];
    
    self.txtFieldEmail.font             =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    self.txtFieldFirstname.font         =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    self.txtFieldLastname.font          =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    self.lblSubscription.font           =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    
    self.txtFieldEmail.textColor        =       GREEN_COLOR;
    self.txtFieldFirstname.textColor    =       GREEN_COLOR;
    self.txtFieldLastname.textColor     =       GREEN_COLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.txtFieldFirstname     resignFirstResponder];
    [self.txtFieldLastname      resignFirstResponder];
}

- (IBAction)onMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
}

- (IBAction)onUpdate:(id)sender {
    if ([self.txtFieldLastname.text isEqualToString:@""]) {
        [Global showAlert:@"Pleaes enter the last name" sender:self];
        return;
    }
    
    if ([self.txtFieldFirstname.text isEqualToString:@""]) {
        [Global showAlert:@"Pleaes enter the first name" sender:self];
        return;
    }
    
    if ([Global sharedInstance].credential.isExpired) {
        [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
            [self onUpdate:sender];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
    
    else {
        NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/accounts/users/%d", endpointURL, myUserId];
        NSDictionary *params    =   @{@"first_name"     :   self.txtFieldFirstname.text,
                                      @"last_name"      :   self.txtFieldLastname.text};
        
        [SVProgressHUD showWithStatus:@"Saving" maskType:SVProgressHUDMaskTypeClear];
        [[Global afManager] PUT:requestURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:@"Done"];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
            [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
        }];
    }
}

- (IBAction)onWebSite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://pingli.st/"]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ChangePasswordViewController *change    =   segue.destinationViewController;
    change.myUserId                         =   myUserId;
}

@end
