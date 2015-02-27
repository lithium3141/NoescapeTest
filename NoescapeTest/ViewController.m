//
//  ViewController.m
//  NoescapeTest
//
//  Created by Tim Ekl on 2015.02.27.
//  Copyright (c) 2015 The Omni Group. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) void (^lastLaterBlock)(void);
@property (nonatomic, strong) NSMutableSet *laterBlocks;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self invokeBlockNow:^{
        NSLog(@"view did load");
    }];
    
    [self invokeBlockLater:^{
        NSLog(@"some time passed");
    }];
}

- (void)invokeBlockNow:(__attribute__((noescape)) void (^)(void))blk {
    blk();
}

- (void)invokeBlockLater:(__attribute__((noescape)) void (^)(void))blk {
    if (self.laterBlocks == nil) {
        self.laterBlocks = [NSMutableSet set];
    }
    
    [self.laterBlocks addObject:blk];
    self.lastLaterBlock = blk;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSSet *blocks = [self.laterBlocks copy];
        self.laterBlocks = nil;
        for (void (^blk)(void) in blocks) {
            blk();
        }
    });
}

@end
