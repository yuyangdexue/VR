//
//  VIDViewController.h
//  Video360
//
//  Created by Jean-Baptiste Rieu on 08/05/13.
//  Copyright (c) 2013 Video360 Developper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@class VIDVideoPlayerViewController;

@interface VIDGlkViewController : GLKViewController<UIGestureRecognizerDelegate>

@property (strong, nonatomic, readwrite) VIDVideoPlayerViewController* videoPlayerController;
@property (assign, nonatomic, readonly) BOOL isUsingMotion;
@property (assign, nonatomic)CGFloat mfingerRotationX;
@property (assign, nonatomic)CGFloat mfingerRotationY;
@property (assign, nonatomic)CGFloat fingerRotationX;
@property (assign, nonatomic)CGFloat fingerRotationY;
@property (assign, nonatomic)CGFloat overture;
@property (nonatomic,assign) BOOL     isFen;
- (void)startDeviceMotion;
- (void)stopDeviceMotion;
- (void)removeDealloc;
@end
