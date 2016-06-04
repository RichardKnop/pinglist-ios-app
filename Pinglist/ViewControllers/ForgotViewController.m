//
//  ForgotViewController.m
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "ForgotViewController.h"
#import "Global.h"

@interface ForgotViewController ()

@end

@implementation ForgotViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.txtFieldEmail.font = [UIFont fontWithName:@"Lato-Regular" size:15.0f];
  [Global changePlaceholderTextColor:self.txtFieldEmail
                                text:@"email"
                               color:[UIColor colorWithRed:184 / 255.0f
                                                     green:223 / 255.0f
                                                      blue:136 / 255.0f
                                                     alpha:1.0f]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.txtFieldEmail resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)onBack:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSubmit:(id)sender {
  if (![Global validateEmail:self.txtFieldEmail.text]) {
    [Global showAlert:@"Invalid email address" sender:self];
    return;
  }

  AFHTTPRequestOperationManager *manager =
      [AFHTTPRequestOperationManager manager];
  AFSecurityPolicy *policy =
      [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  [manager.requestSerializer setValue:@"application/json"
                   forHTTPHeaderField:@"Content-Type"];

  [policy setValidatesDomainName:NO];
  [policy setAllowInvalidCertificates:NO];
  manager.securityPolicy = policy;

  AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer
      serializerWithReadingOptions:NSJSONReadingAllowFragments];
  [manager setResponseSerializer:responseSerializer];

  NSString *authStr =
      [NSString stringWithFormat:@"%@:%@", client_ID, client_Secret];
  NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
  NSString *authValue = [NSString
      stringWithFormat:@"Basic %@",
                       [authData
                           base64EncodedStringWithOptions:
                               NSDataBase64Encoding64CharacterLineLength]];

  [manager.requestSerializer setValue:authValue
                   forHTTPHeaderField:@"Authorization"];
  manager.responseSerializer.acceptableContentTypes =
      [NSSet setWithObject:@"application/json"];

  NSString *requestURL =
      [NSString stringWithFormat:@"%@/v1/accounts/password-reset", endpointURL];
  NSDictionary *params = @{ @"email" : self.txtFieldEmail.text };

  [SVProgressHUD showWithStatus:@"Reset" maskType:SVProgressHUDMaskTypeClear];
  [manager POST:requestURL
      parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD
            showSuccessWithStatus:
                @"Email sent. Check your inbox for further instructions."];
        [self.navigationController popViewControllerAnimated:YES];
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *respone = [NSJSONSerialization
            JSONObjectWithData:
                (NSData *)error.userInfo
                    [AFNetworkingOperationFailingURLResponseDataErrorKey]
                       options:kNilOptions
                         error:&error];
        [SVProgressHUD showErrorWithStatus:respone[@"error"]
                                  maskType:SVProgressHUDMaskTypeClear];
      }];
}

@end
