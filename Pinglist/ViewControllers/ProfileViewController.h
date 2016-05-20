//
//  ProfileViewController.h
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
{
    int     myUserId;
}

- (IBAction)onMenu:(id)sender;
- (IBAction)onUpdate:(id)sender;
- (IBAction)onWebSite:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField    *txtFieldFirstname;
@property (weak, nonatomic) IBOutlet UITextField    *txtFieldLastname;
@property (weak, nonatomic) IBOutlet UITextField    *txtFieldEmail;
@property (weak, nonatomic) IBOutlet UILabel        *lblSubscription;

@end
