#import "Global.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>

@implementation Global

+ (Global *)sharedInstance {
  static Global *instance = nil;

  if (instance == nil) {
    instance = [[Global alloc] init];
  }

  return instance;
}

+ (BOOL)validateEmail:(NSString *)emailStr {
  NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
  NSPredicate *emailTest =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
  return [emailTest evaluateWithObject:emailStr];
}

+ (UIStoryboard *)getStoryboard {
  if (IS_IPHONE_5) {
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  }

  else if (IS_IPHONE_6) {
    return [UIStoryboard storyboardWithName:@"Main_6" bundle:nil];
  }

  else if (IS_IPHONE_6Plus) {
    return [UIStoryboard storyboardWithName:@"Main_6+" bundle:nil];
  }

  else
    return [UIStoryboard storyboardWithName:@"Main_4" bundle:nil];
}

+ (BOOL)validateInteger:(NSString *)string {
  if ([[NSScanner scannerWithString:string] scanInt:nil]) {
    return YES;
  }

  else
    return NO;
}

+ (AFHTTPRequestOperationManager *)afManager {

  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  AFSecurityPolicy *policy =
      [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
  [policy setValidatesDomainName:NO];
  [policy setAllowInvalidCertificates:NO];
  manager.securityPolicy = policy;

  AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer
      serializerWithReadingOptions:NSJSONReadingAllowFragments];
  [manager setResponseSerializer:responseSerializer];

  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  [manager.requestSerializer setValue:@"application/json"
                   forHTTPHeaderField:@"Content-Type"];
  [manager.requestSerializer
                setValue:[NSString stringWithFormat:@"Bearer %@",
                                                    [Global sharedInstance]
                                                        .accessToken]
      forHTTPHeaderField:@"Authorization"];
  manager.responseSerializer.acceptableContentTypes =
      [NSSet setWithObject:@"application/json"];

  return manager;
}

+ (void)showAlert:(NSString *)body sender:(id)sender {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:nil
                                          message:body
                                   preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *dismiss = [UIAlertAction
      actionWithTitle:@"Ok"
                style:UIAlertActionStyleDefault
              handler:^(UIAlertAction *_Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
              }];

  [alert addAction:dismiss];
  [sender presentViewController:alert animated:YES completion:nil];
}

+ (void)changePlaceholderTextColor:(UITextField *)textField
                              text:(NSString *)string
                             color:(UIColor *)color {
  textField.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:string
          attributes:@{NSForegroundColorAttributeName : color}];
}

+ (BOOL)validateUrl:(NSString *)url {
  NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/"
                       @"]((\\w)*|([0-9]*)|([-|_])*))+";
  NSPredicate *urlTest =
      [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
  return [urlTest evaluateWithObject:url];
}

+ (void)refreshAccessToken:(void (^)(NSString *accessTok,
                                     NSString *refreshTok))success
                   failure:(void (^)(NSError *error))failure {

  NSString *requestURL =
      [NSString stringWithFormat:@"%@/v1/oauth/tokens", endpointURL];
  AFOAuth2Manager *OAuth2Manager =
      [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:requestURL]
                                      clientID:client_ID
                                        secret:client_Secret];
  NSDictionary *params = @{
    @"grant_type" : @"refresh_token",
    @"refresh_token" : [Global sharedInstance].refreshToken
  };

  [OAuth2Manager authenticateUsingOAuthWithURLString:requestURL
      parameters:params
      success:^(AFOAuthCredential *_Nonnull credential) {
        // Saving accessToken and refreshToken
        [SVProgressHUD dismiss];

        [Global sharedInstance].credential = credential;
        [Global sharedInstance].accessToken = credential.accessToken;
        [Global sharedInstance].refreshToken = credential.refreshToken;

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:credential.accessToken forKey:@"accessToken"];
        [defaults setObject:credential.refreshToken forKey:@"refreshToken"];
        [defaults synchronize];

        success(credential.accessToken, credential.refreshToken);
        [AFOAuthCredential storeCredential:credential
                            withIdentifier:@"credential"];
      }
      failure:^(NSError *_Nonnull error) {
        // Log the error
        NSDictionary *response = [NSJSONSerialization
            JSONObjectWithData:
                (NSData *)error.userInfo
                    [AFNetworkingOperationFailingURLResponseDataErrorKey]
                       options:kNilOptions
                         error:&error];
        NSLog(@"%@", response[@"error"]);

        failure(error);
      }];
}

+ (void)logout:(UINavigationController *)navigationController {
  [Global sharedInstance].accessToken = @"";
  [Global sharedInstance].refreshToken = @"";
  [Global sharedInstance].fb_accessToken = @"";

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[Global sharedInstance].accessToken
               forKey:@"accessToken"];
  [defaults setObject:[Global sharedInstance].refreshToken
               forKey:@"refreshToken"];
  [defaults synchronize];

  [navigationController popToRootViewControllerAnimated:YES];

  [SVProgressHUD showErrorWithStatus:@"Please log in again"
                            maskType:SVProgressHUDMaskTypeClear];
}

@end
