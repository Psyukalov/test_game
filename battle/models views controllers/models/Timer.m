//
//  Timer.m
//  Battle
//
//  Created by Vladimir Psyukalov on 12.11.2018.
//  Copyright © 2018 Rubeum Macula. All rights reserved.
//


#import "Timer.h"


#define TIME_INTERVAL (1.0f)


@interface Timer ()

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) NSUInteger time;

@property (assign, nonatomic) BOOL countdown;

@end


@implementation Timer

#pragma mark - Public methods

- (void)start {
    if (_timer) {
        [self stop];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)startCountdownFromTime:(NSUInteger)time {
    _time      = time;
    _countdown = YES;
    [self start];
}

- (void)stop {
    [_timer invalidate];
    _timer     = nil;
    _time      = 0;
    _countdown = NO;
}

#pragma mark - Selector methods

- (void)updateTime {
    if (_countdown) {
        if (_time > 0) {
            _time--;
            if (_time > 0) {
                if ([_delegate respondsToSelector:@selector(timer:didUpdateTime:)]) {
                    [_delegate timer:self didUpdateTime:_time];
                }
            } else {
                [self stop];
                if ([_delegate respondsToSelector:@selector(didCompleteCountdownWithTimer:)]) {
                    [_delegate didCompleteCountdownWithTimer:self];
                }
            }
        }
    } else {
        if ([_delegate respondsToSelector:@selector(didUpdateTimeWithTimer:)]) {
            [_delegate didUpdateTimeWithTimer:self];
        }
    }
}

@end
