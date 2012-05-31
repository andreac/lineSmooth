//
//  testSmoothLineAppDelegate.h
//  testSmoothLine
//
//  Created by Andrea Cappellotto on 31/05/12.
//  Copyright 2012 università di Trento. All rights reserved.
//

#import <UIKit/UIKit.h>

@class testSmoothLineViewController;

@interface testSmoothLineAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) testSmoothLineViewController *viewController;

@end
