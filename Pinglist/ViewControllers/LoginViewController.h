//
//  LoginViewController.h
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "SignupViewController.h"
#import <UIKit/UIKit.h>

@interface LoginViewController
    : UIViewController <UITextFieldDelegate, signupDelegate>

- (IBAction)onLogin:(id)sender;
- (IBAction)onLoginFacebook:(id)sender;

@property(weak, nonatomic) IBOutlet UITextField *txtFieldEMail;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldPassword;

@end
