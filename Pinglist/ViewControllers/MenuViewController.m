//
//  MenuViewController.m
//  Pinglist
//
//  Created by admin on 5/2/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "MenuViewController.h"
#import "AlarmViewController.h"
#import "ProfileViewController.h"
#import "TeamViewController.h"
#import "Global.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (IBAction)onAlarm:(id)sender {
    UIStoryboard *storyBoard    =   [Global getStoryboard];
    AlarmViewController *alarm  =   [storyBoard instantiateViewControllerWithIdentifier:@"alarm"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:alarm];
    [navigationController setNavigationBarHidden:YES];
    self.menuContainerViewController.centerViewController = navigationController;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (IBAction)onTeams:(id)sender {
    UIStoryboard *storyBoard    =   [Global getStoryboard];
    TeamViewController *team    =   [storyBoard instantiateViewControllerWithIdentifier:@"team"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:team];
    [navigationController setNavigationBarHidden:YES];
    self.menuContainerViewController.centerViewController = navigationController;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (IBAction)onProfile:(id)sender {
    UIStoryboard *storyBoard        =   [Global getStoryboard];
    ProfileViewController *profile  =   [storyBoard instantiateViewControllerWithIdentifier:@"profile"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profile];
    [navigationController setNavigationBarHidden:YES];
    self.menuContainerViewController.centerViewController = navigationController;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (IBAction)onLogout:(id)sender {
    [Global sharedInstance].accessToken     =   @"";
    [Global sharedInstance].refreshToken    =   @"";
    [Global sharedInstance].fb_accessToken  =   @"";
    
    NSUserDefaults *defaults                =   [NSUserDefaults standardUserDefaults];
    [defaults setObject:[Global sharedInstance].accessToken forKey:@"accessToken"];
    [defaults setObject:[Global sharedInstance].refreshToken forKey:@"refreshToken"];
    [defaults synchronize];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
