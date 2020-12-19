//  _____ _
// |_   _| |_  _ _ ___ ___ _ __  __ _
//   | | | ' \| '_/ -_) -_) '  \/ _` |_
//   |_| |_||_|_| \___\___|_|_|_\__,_(_)
//
// Threema iOS Client
// Copyright (c) 2015-2020 Threema GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License, version 3,
// as published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

#import "ModalNavigationController.h"

@interface ModalNavigationController () <UIGestureRecognizerDelegate>

@property UIBarButtonItem *doneButton;
@property UITapGestureRecognizer *tapGesture;

@end

@implementation ModalNavigationController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_showDoneButton) {
        [self setupDoneButton];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_dismissOnTapOutside) {
        [self setupTapGesture];
    }
}

- (void)setupDoneButton {
    if (self.navigationBar.backItem == nil) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        self.topViewController.navigationItem.leftBarButtonItem = _doneButton;
    }
}

- (void)setupTapGesture {
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTapped:)];
        [_tapGesture setNumberOfTapsRequired:1];
        _tapGesture.cancelsTouchesInView = NO;
        [_tapGesture setDelegate:self];
    }
    
    [self.view.window addGestureRecognizer:_tapGesture];
}

- (void)cleanup {
    [self.view.window removeGestureRecognizer:_tapGesture];
    
    if (_doneButton) {
        _doneButton = nil;
        self.topViewController.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self cleanup];
    
     if (_modalDelegate) {
           [_modalDelegate willDismissModalNavigationController];
       }
    
    [super viewWillDisappear:animated];
}

- (UIModalPresentationStyle)modalPresentationStyle {
    if (SYSTEM_IS_IPAD && _showFullScreenOnIPad == NO) {
        return UIModalPresentationFormSheet;
    }
    
    return [super modalPresentationStyle];
}

- (CGSize)preferredContentSize {
    return self.topViewController.preferredContentSize;
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (SYSTEM_IS_IPAD) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - navigation button

- (void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIGestureRecognizer Recognizer

- (void)windowTapped:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:self.view];
        
        if (![self.view pointInside:location withEvent:nil]) {
            [self done:nil];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.presentedViewController.popoverPresentationController != nil) {
        return NO;
    }
    return YES;
}

@end
