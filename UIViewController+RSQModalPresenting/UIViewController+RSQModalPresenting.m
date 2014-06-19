//
//  UIViewController+ModalPresenting.m
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

#import "UIViewController+RSQModalPresenting.h"
#import <objc/runtime.h>

static void * RSQModalPresentingViewControllerKey = &RSQModalPresentingViewControllerKey;
static void * RSQModalPresentedViewControllerKey = &RSQModalPresentedViewControllerKey;
static void * RSQModalPresentedWindowKey = &RSQModalPresentedWindowKey;

@interface RSQViewControllerTransitioningContext : NSObject <UIViewControllerContextTransitioning>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, copy) NSDictionary *viewControllers;
@property (nonatomic, copy) NSDictionary *viewControllerInitialFrames;
@property (nonatomic, copy) NSDictionary *viewControllerFinalFrames;
@property (nonatomic, getter = isAnimated) BOOL animated;
@property (nonatomic, copy) void (^completionBlock)(BOOL finished);
@end

@implementation RSQViewControllerTransitioningContext

- (void)cancelInteractiveTransition {}

- (CGRect)initialFrameForViewController:(UIViewController *)vc {
    __block id key = nil;
    [self.viewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == vc) {
            key = key;
        }
    }];
    
    if (nil != key) {
        return [self.viewControllerInitialFrames[key] CGRectValue];
    }
    
    return CGRectZero;
}

- (CGRect)finalFrameForViewController:(UIViewController *)vc {
    __block id key = nil;
    [self.viewControllers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == vc) {
            key = key;
        }
    }];
    
    if (nil != key) {
        return [self.viewControllerFinalFrames[key] CGRectValue];
    }
    
    return CGRectZero;
}

- (void)completeTransition:(BOOL)didComplete {
    if (NULL != self.completionBlock) {
        self.completionBlock(didComplete);
        self.completionBlock = nil;
    }
}

- (void)finishInteractiveTransition {}

- (BOOL)isInteractive {
    return NO;
}

- (UIModalPresentationStyle)presentationStyle {
    return UIModalPresentationCustom;
}

- (BOOL)transitionWasCancelled {
    return NO;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.viewControllers[key];
}


@end

@interface RSQRootViewController : UIViewController
@property (nonatomic, strong) UIViewController *rsq_viewControllerToPresent;
@property (nonatomic) BOOL rsq_animateViewControllerToPresentation;
@property (nonatomic, copy) void (^rsq_presentationCompletionBlock)();
@property (nonatomic, copy) NSArray *contentSizeConstraints;
@property (nonatomic, copy) NSArray *centerConstraints;
@property (nonatomic, strong) UIViewController *root_presentedViewController;
@end

@implementation RSQRootViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIViewController *viewControllerToPresent = self.rsq_viewControllerToPresent;
    if (nil != viewControllerToPresent) {
        [self presentViewController:viewControllerToPresent
                           animated:self.rsq_animateViewControllerToPresentation
                         completion:self.rsq_presentationCompletionBlock];
        
        self.rsq_viewControllerToPresent = nil;
        self.rsq_presentationCompletionBlock = nil;
    }
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // now make sure the view can't get any bigger than its container
    
    UIView *containerView = self.view;
    UIView *presentedView = self.root_presentedViewController.view;
    
    CGRect bounds = containerView.bounds;
    CGSize boundsSize = bounds.size;
    CGSize contentSize = self.root_presentedViewController.preferredContentSize;
    if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
        contentSize = boundsSize;
    }
    
    contentSize.width = MIN(boundsSize.width, contentSize.width);
    contentSize.height = MIN(boundsSize.height, contentSize.height);
    UIEdgeInsets insets = self.root_presentedViewController.rsq_presentationEdgeInsets;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(containerView, presentedView);
    NSDictionary *metrics = @{@"contentWidth": @(contentSize.width),
                              @"contentHeight": @(contentSize.height)};
    
    
    NSMutableArray *contentSizeConstraints = [NSMutableArray new];
    
    [contentSizeConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[presentedView(==contentWidth)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];
    
    [contentSizeConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[presentedView(==contentHeight)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];
    
    // mark the above constraints as optional
    for (NSLayoutConstraint *c in contentSizeConstraints) c.priority = UILayoutPriorityRequired-1;
    
    [contentSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:containerView
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.0
                                                         constant:insets.top]];
    
    [contentSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:containerView
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0
                                                         constant:-insets.bottom]];
    
    [contentSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                           toItem:containerView
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1.0
                                                         constant:insets.left]];
    
    [contentSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView
                                                        attribute:NSLayoutAttributeRight
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:containerView
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0
                                                         constant:-insets.right]];
    
    if (nil != self.contentSizeConstraints) {
        [self.view removeConstraints:self.contentSizeConstraints];
    }
    
    self.contentSizeConstraints = contentSizeConstraints;
    [self.view addConstraints:contentSizeConstraints];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion {
    
    self.root_presentedViewController = viewControllerToPresent;
    
    [self addChildViewController:viewControllerToPresent];
    [self.view addSubview:viewControllerToPresent.view];
    
    CGSize centerOffset = viewControllerToPresent.rsq_presentationCenterOffset;
    
    UIView *containerView = self.view;
    UIView *toView = viewControllerToPresent.view;
    
    NSMutableArray *centerConstraints = [NSMutableArray new];
    
    // position the view as requested
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:toView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:containerView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:centerOffset.width];
    
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:toView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:containerView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:centerOffset.height];
    [centerConstraints addObject:centerXConstraint];
    [centerConstraints addObject:centerYConstraint];
    
    for (NSLayoutConstraint *c in centerConstraints) c.priority = UILayoutPriorityRequired-3;
    
    self.centerConstraints = centerConstraints;
    
    toView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:centerConstraints];
    [viewControllerToPresent didMoveToParentViewController:self];
    [viewControllerToPresent beginAppearanceTransition:YES animated:animated];
    
    [self.view layoutIfNeeded];
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        if (NULL != completion) completion();
        [viewControllerToPresent endAppearanceTransition];
    };
    
    if (animated) {
        UIViewController *presentingViewController = viewControllerToPresent.rsq_presentingViewController;
        
        id <UIViewControllerAnimatedTransitioning> transitioningDelegate = [viewControllerToPresent.transitioningDelegate animationControllerForPresentedController:viewControllerToPresent
                                                                                                                                               presentingController:self
                                                                                                                                                   sourceController:presentingViewController];
        
        if (nil == transitioningDelegate) {
            CGRect onscreenFrame = toView.frame;
            CGRect offscreenFrame = CGRectOffset(onscreenFrame, 0, CGRectGetHeight(containerView.bounds));
            toView.frame = offscreenFrame;
            
            [UIView animateWithDuration:0.4
                             animations:^{
                                 toView.frame = onscreenFrame;
                             } completion:completionBlock];
        } else {
            [transitioningDelegate animateTransition:[self transitioningContextForAppearance:YES completionBlock:completionBlock]];
        }
    } else {
        completionBlock(YES);
    }
}

- (id <UIViewControllerContextTransitioning>)transitioningContextForAppearance:(BOOL)appearance completionBlock:(void (^)(BOOL finished))completionBlock {
    
    UIViewController *fromViewController;
    UIViewController *toViewController;
    if (appearance) {
        fromViewController = self.root_presentedViewController.rsq_presentingViewController;
        toViewController = self.root_presentedViewController;
    } else {
        fromViewController = self.root_presentedViewController;
        toViewController = self.root_presentedViewController.rsq_presentingViewController;
    }
    
    RSQViewControllerTransitioningContext *context = [RSQViewControllerTransitioningContext new];
    context.containerView = self.view;
    context.viewControllers = @{
                                UITransitionContextFromViewControllerKey: fromViewController,
                                UITransitionContextToViewControllerKey: toViewController
                                };
    
    CGRect fromBaseRect = [fromViewController.view convertRect:fromViewController.view.bounds toView:nil];
    CGRect fromWindowRect = [self.view.window convertRect:fromBaseRect fromWindow:fromViewController.view.window];
    CGRect fromFrame = [self.view convertRect:fromWindowRect fromView:nil];
    
    CGRect toFrame = [self.view convertRect:toViewController.view.bounds fromView:toViewController.view];
    
    context.viewControllerInitialFrames = @{                                                UITransitionContextFromViewControllerKey: [NSValue valueWithCGRect:fromFrame],
                                                                                            UITransitionContextToViewControllerKey: [NSValue valueWithCGRect:toFrame]
                                                                                            
                                                                                            };
    context.viewControllerFinalFrames = context.viewControllerInitialFrames;

    context.animated = YES;
    context.completionBlock = completionBlock;
    return context;
}

- (void)addConstraints {
    UIView *containerView = self.view;
    if (nil != self.centerConstraints) [containerView addConstraints:self.centerConstraints];
    if (nil != self.contentSizeConstraints) [containerView addConstraints:self.contentSizeConstraints];
}

- (void)removeConstraints {
    UIView *containerView = self.view;
    if (nil != self.centerConstraints) [containerView removeConstraints:self.centerConstraints];
    if (nil != self.contentSizeConstraints) [containerView removeConstraints:self.contentSizeConstraints];
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *presentedViewController = self.root_presentedViewController;
    UIView *presentedView = presentedViewController.view;
    UIView *containerView = self.view;
    
    [presentedViewController willMoveToParentViewController:nil];
    [presentedViewController beginAppearanceTransition:NO animated:animated];
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        if (NULL != completion) completion();
        [presentedViewController endAppearanceTransition];
    
        [self removeConstraints];
        self.centerConstraints = nil;
        self.contentSizeConstraints = nil;
        
        [presentedView removeFromSuperview];
        [presentedViewController removeFromParentViewController];
    };
    
    if (animated) {
        
        id <UIViewControllerAnimatedTransitioning> transitioningDelegate = [presentedViewController.transitioningDelegate animationControllerForDismissedController:presentedViewController];
        
        if (nil == transitioningDelegate) {
            CGRect onscreenFrame = presentedView.frame;
            CGRect offscreenFrame = CGRectOffset(onscreenFrame, 0, CGRectGetHeight(containerView.bounds));
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 presentedView.frame = offscreenFrame;
                             } completion:completionBlock];
        } else {
            [transitioningDelegate animateTransition:[self transitioningContextForAppearance:NO completionBlock:completionBlock]];
        }
        
    } else {
        completionBlock(YES);        
    }
    
}
@end

@interface UIViewController (RSQModalPresentingPrivate)
@property (nonatomic, strong) UIWindow *rsq_modalPresentationWindow;
@end

@implementation UIViewController (RSQModalPresenting)

- (UIEdgeInsets)rsq_presentationEdgeInsets {
    return UIEdgeInsetsZero;
}

- (CGSize)rsq_presentationCenterOffset {
    return CGSizeZero;
}

- (UIViewController *)rsq_presentingViewController {
    return objc_getAssociatedObject(self, RSQModalPresentingViewControllerKey);
}

- (UIViewController *)rsq_presentedViewController {
    return objc_getAssociatedObject(self, RSQModalPresentedViewControllerKey);
}

- (UIWindow *)rsq_modalPresentationWindow {
    return objc_getAssociatedObject(self, RSQModalPresentedWindowKey);
}

- (void)rsq_presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *presentedViewController = self.rsq_presentedViewController;
    if (nil == presentedViewController) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        window.opaque = NO;
        window.backgroundColor = [UIColor clearColor];
        window.windowLevel = self.view.window.windowLevel+1;
        
        RSQRootViewController *rootViewController = [[RSQRootViewController alloc] initWithNibName:nil bundle:nil];
        rootViewController.rsq_viewControllerToPresent = viewController;
        rootViewController.rsq_animateViewControllerToPresentation = animated;
        rootViewController.rsq_presentationCompletionBlock = completion;
        
        window.rootViewController = rootViewController;
        
        objc_setAssociatedObject(self, RSQModalPresentedWindowKey, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, RSQModalPresentedViewControllerKey, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(viewController, RSQModalPresentingViewControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
        
        [window makeKeyAndVisible];
    } else {
        NSLog(@"Attempt to present an view controller when one is already presented");
    }
}

- (void)rsq_dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *presentedViewController = self.rsq_presentedViewController;
    if (nil != presentedViewController) {
        UIWindow *window = objc_getAssociatedObject(self, RSQModalPresentedWindowKey);
        UIViewController *rootViewController = window.rootViewController;
        
        void (^completionBlock)() = ^() {
            [self.rsq_modalPresentationWindow resignKeyWindow];
            objc_setAssociatedObject(presentedViewController, RSQModalPresentingViewControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(self, RSQModalPresentedViewControllerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, RSQModalPresentedWindowKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            if (NULL != completion) completion();
        };
        
        [rootViewController dismissViewControllerAnimated:animated completion:completionBlock];
    } else {
        NSLog(@"Attemping to dismiss an rsq_presentedViewController which doesn't exist");
    }
}
@end
