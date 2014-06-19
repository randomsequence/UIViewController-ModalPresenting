//
//  ViewController.m
//
//  Copyright (c) 2014 Johnnie Walker
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "ViewController.h"
#import "AnimatedTransitioner.h"
#import "UIViewController+RSQModalPresenting.h"

@interface ViewController () <UIViewControllerTransitioningDelegate>
@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIViewController *presentingViewController = self.rsq_presentingViewController;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (nil != presentingViewController) {
        [button setTitle:NSLocalizedString(@"Dismiss modal view controller", @"Button title") forState:UIControlStateNormal];
        [button addTarget:presentingViewController action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [button setTitle:NSLocalizedString(@"Show modal view controller", @"Button title") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [button addTarget:presentingViewController action:@selector(show:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (nil != button) {
        [self.view addSubview:button];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self show:nil];
        });
    });
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationPortrait;
//}

#pragma mark - 

- (UIEdgeInsets)rsq_presentationEdgeInsets {
    return UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, 4, 0);
}

- (CGSize)rsq_presentationCenterOffset {
    return CGSizeZero;
}

#pragma mark - Actions

- (IBAction)show:(id)sender {
    if (nil == self.rsq_presentedViewController) {
        ViewController *v = [[ViewController alloc] initWithNibName:nil bundle:nil];
        v.view.backgroundColor = [UIColor redColor];
        v.modalTransitionStyle = UIModalPresentationCustom;
        v.transitioningDelegate = self;
        v.preferredContentSize = CGSizeMake(400, CGFLOAT_MAX);
        
        [self rsq_presentViewController:v animated:YES completion:NULL];
    }
}

- (IBAction)dismiss:(id)sender {
    [self rsq_dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [AnimatedTransitioner animatedPresenter];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [AnimatedTransitioner animatedDismisser];
}

@end
