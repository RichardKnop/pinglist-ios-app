//
//  LoginViewController.m
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "LoginViewController.h"
#import "Global.h"
#import "MenuViewController.h"
#import "AlarmViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.txtFieldEMail.font         =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    self.txtFieldPassword.font      =       [UIFont fontWithName:@"Lato-Regular" size:15.0f];
    
    [Global changePlaceholderTextColor:self.txtFieldPassword text:@"password" color:[UIColor colorWithRed:184/255.0f green:223/255.0f blue:136/255.0f alpha:1.0f]];
    [Global changePlaceholderTextColor:self.txtFieldEMail text:@"email" color:[UIColor colorWithRed:184/255.0f green:223/255.0f blue:136/255.0f alpha:1.0f]];
    
    if (![[Global sharedInstance].accessToken isEqualToString:@""] && [Global sharedInstance].accessToken != nil) {
        [self loadLocations];
        [self goMainScreen];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.txtFieldEMail     resignFirstResponder];
    [self.txtFieldPassword  resignFirstResponder];
}

- (NSDate *)getDate :(NSString *)str {
    NSDateFormatter *dateFormatter  =   [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    return [dateFormatter dateFromString:str];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)goMainScreen {
    UIStoryboard *storyBoard    =   [Global getStoryboard];
    MenuViewController *menu    =   [storyBoard instantiateViewControllerWithIdentifier:@"menu"];
    AlarmViewController *alarm  =   [storyBoard instantiateViewControllerWithIdentifier:@"alarm"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:alarm];
    [navigationController setNavigationBarHidden:YES];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:navigationController
                                                    leftMenuViewController:menu
                                                    rightMenuViewController:nil];
    [self.navigationController pushViewController:container animated:YES];

}

- (void)loadLocations {
    
    if ([Global sharedInstance].credential.isExpired) {
        [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
            [self loadLocations];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
    
    else {
        [Global sharedInstance].locations   =   [[NSMutableArray alloc] init];
        NSString *requestURL                =   [NSString stringWithFormat:@"%@/v1/regions", endpointURL];
        
        [[Global afManager] GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary *response      =   responseObject;
            NSArray      *locations     =   response[@"_embedded"][@"regions"];
            
            for (int i = 0; i < locations.count; i ++) {
                NSDictionary *dict       =   locations[i];
                Location     *loc        =   [[Location alloc] initWithData:dict];
                [[Global sharedInstance].locations addObject:loc];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
            [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
        }];
        
        //Register a device token

        if (![[Global sharedInstance].deviceToken isEqualToString:@""] && [Global sharedInstance].deviceToken != nil) {
            NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/devices", endpointURL];
            NSDictionary *params    =   @{@"platform"   :   @"iOS",
                                          @"token"      :   [Global sharedInstance].deviceToken
                                          };
            
            [[Global afManager] POST:requestURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"register token success");
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:operation.responseString maskType:SVProgressHUDMaskTypeClear];
            }];
        }
    }
}

- (IBAction)onLogin:(id)sender {
  
    if (![Global validateEmail:self.txtFieldEMail.text]) {
        [Global showAlert:@"Please enter the valid email address." sender:self];
        return;
    }
    
    if (self.txtFieldPassword.text.length == 0) {
        [Global showAlert:@"Please enter the password" sender:self];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Log in" maskType:SVProgressHUDMaskTypeClear];
    NSString *requestURL            =   [NSString stringWithFormat:@"%@/v1/oauth/tokens", endpointURL];
    AFOAuth2Manager *OAuth2Manager  =   [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:requestURL]
                                                                                clientID:client_ID
                                                                                secret:client_Secret];
    
    //OAuth2 with clientID & clientSecret
    
    [OAuth2Manager authenticateUsingOAuthWithURLString:requestURL username:self.txtFieldEMail.text password:self.txtFieldPassword.text scope:@"read_write" success:^(AFOAuthCredential * _Nonnull credential) {
        
        [SVProgressHUD dismiss];
        [AFOAuthCredential storeCredential:credential withIdentifier:@"credential"];
        //saving accessToken and refreshToken
        [Global sharedInstance].credential   =   credential;
        [Global sharedInstance].accessToken  =   credential.accessToken;
        [Global sharedInstance].refreshToken =   credential.refreshToken;
        
        NSUserDefaults *defaults             =   [NSUserDefaults standardUserDefaults];
        [defaults setObject:credential.accessToken forKey:@"accessToken"];
        [defaults setObject:credential.refreshToken forKey:@"refreshToken"];
        [defaults synchronize];
        
        //load locations & go to main screen
        [self loadLocations];
        [self goMainScreen];
        
    } failure:^(NSError * _Nonnull error) {
        NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
        [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
    }];
}

- (IBAction)onLoginFacebook:(id)sender {
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithReadPermissions: @[@"public_profile", @"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
    {
        
        if (error) {
             NSLog(@"Process error");
        }
        
        else if (result.isCancelled) {
             NSLog(@"Cancelled");
        }
        
        else {
             if ([FBSDKAccessToken currentAccessToken])
             {
                 //Saving facebook access token
                 [Global sharedInstance].fb_accessToken = [FBSDKAccessToken currentAccessToken].tokenString;
                 
                 [SVProgressHUD showWithStatus:@"Log in" maskType:SVProgressHUDMaskTypeClear];
                 NSString *requestURL   =   [NSString stringWithFormat:@"%@/v1/facebook/login", endpointURL];
                 
                 AFOAuth2Manager *OAuth2Manager =
                 [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:requestURL]
                                                 clientID:client_ID secret:client_Secret];
                 
                 NSDictionary *params = @{@"access_token" : [Global sharedInstance].fb_accessToken,
                                          @"scope" : @"read_write"};
                 [OAuth2Manager authenticateUsingOAuthWithURLString:requestURL parameters:params success:^(AFOAuthCredential * _Nonnull credential) {
                     [SVProgressHUD dismiss];
                     
                     [AFOAuthCredential storeCredential:credential withIdentifier:@"credential"];
                     
                     //saving accessToken and refreshToken
                     [Global sharedInstance].accessToken    =   credential.accessToken;
                     [Global sharedInstance].refreshToken   =   credential.refreshToken;
                     
                     NSUserDefaults *defaults             =   [NSUserDefaults standardUserDefaults];
                     [defaults setObject:credential.accessToken forKey:@"accessToken"];
                     [defaults setObject:credential.refreshToken forKey:@"refreshToken"];
                     [defaults synchronize];
                     
                     //go to Main screen
                     [self loadLocations];
                     [self goMainScreen];
                     
                 } failure:^(NSError * _Nonnull error) {
                     NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
                     [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
                 }];
                 
             }
         }
     }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"signup"]) {
        SignupViewController *signup    =   segue.destinationViewController;
        signup.delegate                 =   self;
    }
}

- (void)update:(NSString *)email {
    self.txtFieldEMail.text     =   email;
    [self.txtFieldPassword becomeFirstResponder];
}

@end
