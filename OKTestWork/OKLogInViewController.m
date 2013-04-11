//
//  OKLoginViewController.m
//  OKTestWork
//
//  Created by Vitaliy Berg on 4/10/13.
//  Copyright (c) 2013 Vitaliy Berg. All rights reserved.
//

#import "OKLogInViewController.h"
#import "OKClient.h"
#import "UITextField+OKCarriageColor.h"
#import <QuartzCore/QuartzCore.h>


// TODO: Handle captcha for logging in

@interface OKLogInViewController ()
<
    UITextFieldDelegate,
    UIGestureRecognizerDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UIView *logInPanel;

@property (weak, nonatomic) IBOutlet UIView *textFieldsPanel;
@property (weak, nonatomic) IBOutlet UIImageView *textFieldsBG;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UILabel *sandboxLabel;

@end


@implementation OKLogInViewController
{
    CGFloat _logInPanelY1;
    CGFloat _logInPanelY2;
    CGFloat _logoY1;
    CGFloat _logoY2;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        self.backgroundImageView.image = [UIImage imageNamed:@"LogInBG-568h"];
        // I don't know how it looks on real device
        _logInPanelY1 = 170;
        _logInPanelY2 = 170;
        _logoY1 = 100;
        _logoY2 = 100;
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"LogInBG"];
        // I think it looks good
        _logInPanelY1 = 148;
        _logInPanelY2 = 91;
        _logoY1 = 72;
        _logoY2 = 23;
    }
    
    self.userNameTextField.placeholder = NSLocalizedString(@"LogInUserName", @"");
    self.passwordTextField.placeholder = NSLocalizedString(@"LogInPassword", @"");
    [self.logInButton setTitle:NSLocalizedString(@"LogIn", @"") forState:UIControlStateNormal];
    
    UIImage *bg1 = [UIImage imageNamed:@"LogInButton"];
    bg1 = [bg1 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [self.logInButton setBackgroundImage:bg1 forState:UIControlStateNormal];
    
    UIImage *bg2 = [UIImage imageNamed:@"LogInButtonH"];
    bg2 = [bg2 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [self.logInButton setBackgroundImage:bg2 forState:UIControlStateHighlighted];
    
    UIImage *bg3 = [UIImage imageNamed:@"LogInTextFieldsBG"];
    bg3 = [bg3 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
    self.textFieldsBG.image = bg3;
    
    if ([OKConfig sharedConfig].useSandbox) {
        self.sandboxLabel.text = NSLocalizedString(@"SandboxDisclaimer", @"");
    } else {
        self.sandboxLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.logInPanel.frame;
    frame.origin.y = _logInPanelY1;
    self.logInPanel.frame = frame;
    
    frame = self.logoImageView.frame;
    frame.origin.y = _logoY1;
    self.logoImageView.frame = frame;
}


#pragma mark - Log In

- (BOOL)validateTextFields
{
    if ([self.userNameTextField.text length] == 0) {
        [self shakeTextFields];
        return NO;
    } else if ([self.passwordTextField.text length] == 0) {
        [self shakeTextFields];
        return NO;
    }
    return YES;
}

- (void)tryLogIn
{
    if ([self validateTextFields]) {
        [self logIn];
    }
}

- (void)logIn
{
    [self startLogIn];
    
    [[OKClient sharedClient] logInWithUserName:self.userNameTextField.text password:self.passwordTextField.text success:^(id JSON) {
        [self endLogIn];
    } failure:^(NSError *error, id JSON) {
        NSLog(@"%@", error);
        [self endLogIn];
        [self handleError:error];
    }];
}

- (void)handleError:(NSError *)error
{
    if (error.code == OKAPIErrorCodeAuthLogin) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LogInErrorTitle", @"")
                                    message:NSLocalizedString(@"LogInErrorMessage", @"")
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"OK", @""), nil] show];
        self.passwordTextField.text = @"";
        [self.passwordTextField becomeFirstResponder];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LogInUnknownErrorTitle", @"")
                                    message:NSLocalizedString(@"LogInUnknownErrorMessage", @"")
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:NSLocalizedString(@"OK", @""), nil] show];
    }
}

- (void)startLogIn
{
    [self.view endEditing:YES];
    self.logInButton.userInteractionEnabled = NO;
    self.userNameTextField.userInteractionEnabled = NO;
    self.passwordTextField.userInteractionEnabled = NO;
    [self.logInButton setTitle:NSLocalizedString(@"LoggingIn", @"") forState:UIControlStateNormal];
    self.spinner.hidden = NO;
}

- (void)endLogIn
{
    self.logInButton.userInteractionEnabled = YES;
    self.userNameTextField.userInteractionEnabled = YES;
    self.passwordTextField.userInteractionEnabled = YES;
    [self.logInButton setTitle:NSLocalizedString(@"LogIn", @"") forState:UIControlStateNormal];
    self.spinner.hidden = YES;
}


#pragma mark - Shake Text Fields

-(void)shakeTextFields
{
    CGPoint position = self.textFieldsPanel.layer.position;
    CGFloat w = 5;
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    anim.values = @[
        [NSValue valueWithCGPoint:CGPointMake(position.x, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x - w, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x + w, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x - w, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x + w, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x - w, position.y)],
        [NSValue valueWithCGPoint:CGPointMake(position.x, position.y)],
    ];
    anim.duration = 0.25;
    [self.textFieldsPanel.layer addAnimation:anim forKey:@"position"];
}


#pragma mark - Actions

- (IBAction)tapAction:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)logInAction:(id)sender
{
    [self tryLogIn];
}


#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    if (keyboardFrameEnd.origin.y < self.view.frame.size.height) {
        [UIView animateWithDuration:duration animations:^{
            
            CGRect frame = self.logInPanel.frame;
            frame.origin.y = _logInPanelY2;
            self.logInPanel.frame = frame;
            
            frame = self.logoImageView.frame;
            frame.origin.y = _logoY2;
            self.logoImageView.frame = frame;
            
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect keyboardFrameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.view convertRect:keyboardFrameEnd fromView:nil];
    double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (keyboardFrameEnd.origin.y >= self.view.frame.size.height) {
        [UIView animateWithDuration:duration animations:^{
            
            CGRect frame = self.logInPanel.frame;
            frame.origin.y = _logInPanelY1;
            self.logInPanel.frame = frame;
            
            frame = self.logoImageView.frame;
            frame.origin.y = _logoY1;
            self.logoImageView.frame = frame;
            
        } completion:^(BOOL finished) {
        }];
    }
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField changeCarriageColorWithColor:[[UIColor orangeColor] colorWithAlphaComponent:0.7]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self logInAction:textField];
    }
    return YES;
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![touch.view isKindOfClass:[UIControl class]];
}

@end
