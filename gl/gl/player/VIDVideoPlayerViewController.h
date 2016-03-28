//
//  VIDVideoPlayerViewController.h
//  Video360
//
//  Created by Jean-Baptiste Rieu on 24/05/13.
//  Copyright (c) 2013 Video360 Developper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface VIDVideoPlayerViewController : UIViewController<AVPlayerItemOutputPullDelegate>

@property (strong, nonatomic) NSString *videoURL;
@property (assign, nonatomic) BOOL  isVideoLocal;





- (id)initWithUrl:(NSString*)url  local:(BOOL)isLocal Fen:(BOOL) fen;

-(CVPixelBufferRef) retrievePixelBufferToDraw;
-(void) toggleControls;

@end
