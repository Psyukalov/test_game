//
//  Timer.h
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import <Foundation/Foundation.h>


@class Timer;


@protocol TimerDelegate <NSObject>

@optional

- (void)didUpdateTimeWithTimer:(Timer *)timer;

- (void)didCompleteCountdownWithTimer:(Timer *)timer;

- (void)timer:(Timer *)timer didUpdateTime:(NSUInteger)time;

@end


@interface Timer : NSObject

@property (weak, nonatomic) id<TimerDelegate> delegate;

- (void)start;

- (void)startCountdownFromTime:(NSUInteger)time;

- (void)stop;

@end
