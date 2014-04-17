//
//  LoginViewController.m
//  SenseVital
//
//  Created by Pim Nijdam on 17/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import "LoginViewController.h"
#import <Cortex/CSSensePlatform.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction) login:(id)sender {
    //TODO: show animated progress viewer
    //Check for internet connection
    //check that all fields are filled in
    NSString* username = self.usernameTextField.text;
    NSString* password = self.passwordTextField.text;
    BOOL error = NO;
    if (username.length == 0) {
        [self showError:@"Provide a username"];
        [self.usernameTextField.layer setBorderColor:(__bridge CGColorRef)([UIColor redColor])];
        error = YES;
    }
    if (password.length == 0) {
        [self.passwordTextField.layer setBorderColor:(__bridge CGColorRef)([UIColor redColor])];
        if (error == NO)
        [self showError:@"Provide a password"];
    }
    
    if (error)
        return;
    
    BOOL loginSucceed = [CSSensePlatform loginWithUser:username andPassword:password];
    if (loginSucceed) {
        //go to next screen
        [self showError:@"Login succesfully"];
        UIStoryboard *storyboard = self.storyboard;
        UIViewController *destVC = [storyboard instantiateViewControllerWithIdentifier:@"Home"];
        [self.navigationController pushViewController:destVC animated:YES];
    } else {
        [self showError:@"Couldn't login. Check username and password."];
    }
}

- (void) showError:(NSString*) error {
    [self.errorLabel setText:error];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end