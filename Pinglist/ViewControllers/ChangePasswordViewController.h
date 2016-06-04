//
//  ChangePasswordViewController.h
//  Pinglist
//
//  Created by admin on 5/6/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController

- (IBAction)onBack:(id)sender;
- (IBAction)onChange:(id)sender;

@property int myUserId;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldOld;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldNew;
@property(weak, nonatomic) IBOutlet UITextField *txtFieldConfirm;

@end
