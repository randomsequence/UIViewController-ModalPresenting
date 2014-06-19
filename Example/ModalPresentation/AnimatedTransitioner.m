//
//  AnimatedTransitioner.m
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

#import "AnimatedTransitioner.h"

@interface AnimatedTransitioner ()
@property (nonatomic, readwrite, getter = isPresenting) BOOL presenting;
@end

@implementation AnimatedTransitioner

+ (instancetype)animatedPresenter {
    AnimatedTransitioner *a = [AnimatedTransitioner new];
    a.presenting = YES;
    return a;
}

+ (instancetype)animatedDismisser {
    AnimatedTransitioner *a = [AnimatedTransitioner new];
    a.presenting = NO;
    return a;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat height = CGRectGetHeight(inView.bounds);
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    CGAffineTransform offscreenTransform = CGAffineTransformMakeTranslation(0, height);
    
    CGRect onscreenFrame = UIEdgeInsetsInsetRect(inView.bounds, UIEdgeInsetsMake((height/3.0), 0, 0, 0));
    CGRect offscreenFrame = CGRectApplyAffineTransform(onscreenFrame, offscreenTransform);
    
    if (self.isPresenting) {
        toViewController.view.frame = offscreenFrame;
        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [inView addSubview:toViewController.view];
        
        [UIView animateWithDuration:duration
                              delay:0
             usingSpringWithDamping:0.6 initialSpringVelocity:0
                            options:0
                         animations:^{
                             toViewController.view.frame = onscreenFrame;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    } else {
        [UIView animateWithDuration:duration
                         animations:^{
                             fromViewController.view.transform = CGAffineTransformMakeScale(0, 0);
                         }
                         completion:^(BOOL finished) {
                             [fromViewController.view removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
}
@end
