//
//  ForgotViewController.h
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotViewController : UIViewController

- (IBAction)onBack:(id)sender;
- (IBAction)onSubmit:(id)sender;

@property(weak, nonatomic) IBOutlet UITextField *txtFieldEmail;

@end
