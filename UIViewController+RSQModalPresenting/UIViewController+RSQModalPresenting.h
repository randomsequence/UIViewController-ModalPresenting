//
//  UIViewController+ModalPresenting.h
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

#import <UIKit/UIKit.h>

/**

 RSQModalPresenting is a category on UIViewController which provides an alternative to presentViewController:animated:completion: which works in multiple user interface orientations.

 Use a combination of preferredContentSize, rsq_presentationEdgeInsets and rsq_presentationCenterOffset to size and position your presented view controller.
 
 Custom view controller transitions (UIViewControllerAnimatedTransitioning) are supported.
 
*/

@interface UIViewController (RSQModalPresenting)
/** @name Properties */
/** Edge insets from the edges of the presenting container view */
@property (nonatomic, readonly) UIEdgeInsets rsq_presentationEdgeInsets;
/** Offset from the center of the presenting container view (non-fullscreen presentation only) */
@property (nonatomic, readonly) CGSize rsq_presentationCenterOffset;
/** The view controller responsible for presenting this view controller 
    Call rsq_dismissViewControllerAnimated:completion: on this view controller to dismiss the modal presentation
 */
@property (nonatomic, unsafe_unretained, readonly) UIViewController *rsq_presentingViewController;
/** The view controller presented by this view controller */
@property (nonatomic, unsafe_unretained, readonly) UIViewController *rsq_presentedViewController;
/** @name Instance methods */
/** Presents viewControllerToPresent modally.
    This method is a direct replacement for presentViewController:animated:completion:
 */
- (void)rsq_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
/** Dismisses the rsq_presentedViewController of this view controller.
 This method is a direct replacement for dismissViewControllerAnimated:completion:
 */
- (void)rsq_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
@end
