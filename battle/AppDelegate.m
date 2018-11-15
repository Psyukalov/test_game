//
//  AppDelegate.m
//  battle
//
//  Created by Vladimir Psyukalov on 14.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "AppDelegate.h"

#import "GameViewController.h"


@interface AppDelegate ()



@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupWithCompletion:^(UIWindow *window) {
        window.rootViewController = [GameViewController new];
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Empty...
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Empty...
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Empty...
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Empty...
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Empty...
}

#pragma mark - Private methods

- (void)setupWithCompletion:(void (^)(UIWindow *window))completion {
    self.window                 = [UIWindow new];
    self.window.frame           = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor blackColor];
    if (completion) {
        completion(self.window);
    }
    [self.window makeKeyAndVisible];
}

@end
