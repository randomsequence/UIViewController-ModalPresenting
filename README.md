UIViewController+ModalPresenting
================================

UIViewController category which provides animated modal presentation which works in multiple user interface orientations for view controllers which don't fill the containing view.

##Motivation

Using the UIKit standard methods, presenting a modal view controller with a non-fullscreen presentation is done like this:

    UIViewController *modal = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    modal.modalTransitionStyle = UIModalPresentationCustom;
    modal.transitioningDelegate = self; // UIViewControllerTransitioningDelegate
    [self presentViewController:modal animated:YES completion:NULL];

It is the responsibility of `transitioningDelegate` to return an animator (id <UIViewControllerAnimatedTransitioning>) for the modal presentation. The animator can specify the final frame for the modal view controller.

Unfortunately the modally presented view controller is presented in a new view whose frame is always in window coordinates, and whose bounds are rotated to match the presenting view controller. This makes it impossible, as far as I've been able to determine, to use any sensible method to specify the non-fullscreen frame when the interface is rotated (or otherwise resized). There is a discussion on this on [Apple's developer forums][Forum discussion]. [Cameron Cooke][] found a suitable workaround for modal views which fill the width of the screen.

##Using UIViewController+ModalPresenting

This category provides alternatives to `presentViewController:animated:completion:` and `dismissViewControllerAnimated:completion:` with a prefix:

    - (void)rsq_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
    - (void)rsq_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;

Example use:

    UIViewController *modal = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    modal.modalTransitionStyle = UIModalPresentationCustom;
    modal.transitioningDelegate = self; // UIViewControllerTransitioningDelegate
    modal.preferredContentSize = CGSizeMake(320, CGFLOAT_MAX); // as tall as possible    
    [self rsq_presentViewController:modal animated:YES completion:NULL];

…

    [self rsq_dismissViewControllerAnimated:YES completion:NULL];

##Status bar edge insets

If your modal view controller doesn't want to extend under the status bar, you should return suitable edge insets for the `rsq_presentationEdgeInsets` property:

    - (UIEdgeInsets)rsq_presentationEdgeInsets {
        CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
        return UIEdgeInsetsMake(MIN(statusBarSize.width, statusBarSize.height), 0, 0, 0);
    }

##How does it work?

The presented view controller is presented in a new window with a root view controller to handle positioning and rotations.


[Forum discussion]: https://devforums.apple.com/thread/196451
[Cameron Cooke]: http://www.brightec.co.uk/blog/ios-7-custom-view-controller-transitions-and-rotation-making-it-all-work