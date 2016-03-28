//
//  AppDelegate.m
//  gl
//
//  Created by Yuyangdexue on 15/7/21.
//  Copyright (c) 2015年 yuyang. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "MainViewController.h"
#import "SVProgressHUD.h"
float kDeviceFactor = 1.0;
float kDeviceWidth = 320.0;
float kDeviceHeight = 568.0;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    CGRect cframe = [[UIScreen mainScreen] bounds];
    kDeviceWidth = cframe.size.width;
    kDeviceHeight = cframe.size.height;
    kDeviceFactor = kDeviceHeight <= 568.0 ? 1.0 : kDeviceHeight / 568.0;
    
    [SVProgressHUD
     setBackgroundColor:[UIColor colorWithHexRGBAString:@"00000099"]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
//    NSString *scriptpath = [[[NSBundle mainBundle] resourcePath]
//                        stringByAppendingPathComponent:@"tudou.lua"];
//    
//
//    
//    LuaViewController *vc=[[LuaViewController alloc]init];
//    
//    
//    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
//     self.window.rootViewController=vc;
    
//     //Google's treasure example
//    PanoPlayerViewController *cardboardViewController = [PanoPlayerViewController new];
//    
//    //    float *frameParameters = calloc(80, sizeof(float));
//    //    _unity_getFrameParameters(frameParameters);
//    
//    self.window.rootViewController = cardboardViewController;
   MainViewController *playerViewController=[[MainViewController alloc]init];
    //UINavigationController *rNavC=[[UINavigationController alloc]initWithRootViewController:playerViewController];
    self.window.rootViewController=playerViewController;
     //*/
    
    return YES;
    // Override point for customization after application launch.
   
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
