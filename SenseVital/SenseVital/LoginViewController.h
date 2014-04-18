//
//  LoginViewController.h
//  SenseVital
//
//  Created by Pim Nijdam on 17/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIScrollViewDelegate>
- (IBAction) login:(id)sender;

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UITextField* usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField* passwordTextField;
@property (nonatomic, retain) IBOutlet UITextView* errorLabel;
@end
