//
//  Global.h
//  WUSHU
//
//  Created by Andrei on 2/17/15.
//  Copyright (c) 2015 admin. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "AFOAuth2Manager.h"
#import "Alarm.h"
#import "AlarmTableViewCell.h"
#import "Incident.h"
#import "IncidentTableViewCell.h"
#import "Location.h"
#import "MFSideMenu.h"
#import "NSDictionary+Utils.h"
#import "SVProgressHUD.h"
#import "Team.h"
#import "TeamMember.h"
#import "TeamTableViewCell.h"

#define alarmsPagingLimit 10
#define endpointURL @"https://api.pingli.st"
#define client_ID @"pDhu739AAFDSqlmc83bua"
#define client_Secret @"Ie93fasbjnfU842pA002fkX"

//#define endpointURL     @"https://stage-api.pingli.st"
//#define client_ID       @"test_client_1"
//#define client_Secret   @"test_secret"

#define RED_COLOR                                                              \
  [UIColor colorWithRed:233 / 255.0f                                           \
                  green:29 / 255.0f                                            \
                   blue:41 / 255.0f                                            \
                  alpha:1.0f]
#define GREEN_COLOR                                                            \
  [UIColor colorWithRed:184 / 255.0f                                           \
                  green:233 / 255.0f                                           \
                   blue:134 / 255.0f                                           \
                  alpha:1.0f]
#define YELLOW_COLOR                                                           \
  [UIColor colorWithRed:245 / 255.0f                                           \
                  green:199 / 255.0f                                           \
                   blue:36 / 255.0f                                            \
                  alpha:1.0f]
#define GREY_COLOR                                                             \
  [UIColor colorWithRed:187 / 255.0f                                           \
                  green:187 / 255.0f                                           \
                   blue:189 / 255.0f                                           \
                  alpha:1.0f]

#define IS_IPHONE_4                                                            \
  (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)480) <    \
   DBL_EPSILON)
#define IS_IPHONE_5                                                            \
  (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) <    \
   DBL_EPSILON)
#define IS_IPHONE_6                                                            \
  (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)667) <    \
   DBL_EPSILON)
#define IS_IPHONE_6Plus                                                        \
  (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)736) <    \
   DBL_EPSILON)

@interface Global : NSObject

+ (Global *)sharedInstance;
+ (UIStoryboard *)getStoryboard;
+ (BOOL)validateEmail:(NSString *)emailStr;
+ (BOOL)validateUrl:(NSString *)url;
+ (BOOL)validateInteger:(NSString *)string;
+ (AFHTTPRequestOperationManager *)afManager;
+ (void)showAlert:(NSString *)body sender:(id)sender;
+ (void)changePlaceholderTextColor:(UITextField *)textField
                              text:(NSString *)string
                             color:(UIColor *)color;
+ (void)refreshAccessToken:(void (^)(NSString *accessTok,
                                     NSString *refreshTok))success
                   failure:(void (^)(NSError *error))failure;
+ (void)logout:(UINavigationController *)navigationController;

@property(nonatomic, strong) NSString *accessToken;
@property(nonatomic, strong) NSString *fb_accessToken;
@property(nonatomic, strong) NSString *refreshToken;
@property(nonatomic, strong) NSString *deviceToken;
@property(nonatomic, strong) NSMutableArray *locations;
@property(nonatomic, strong) NSMutableArray *alarms;
@property(nonatomic, strong) AFOAuthCredential *credential;

@end
