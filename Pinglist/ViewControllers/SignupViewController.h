//
//  SignupViewController.h
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol signupDelegate
- (void)update:(NSString *)email;
@end

@interface SignupViewController : UIViewController

- (IBAction)onBack:(id)sender;
- (IBAction)onRegister:(id)sender;

@property id<signupDelegate> delegate;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldPassword;

@end
