//
//  TrailBlazeTests.m
//  TrailBlazeTests
//
//  Created by Adam Issah on 6/24/22.
//

#import <XCTest/XCTest.h>

@interface TrailBlazeTests : XCTestCase

@end

@implementation TrailBlazeTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


//Daniel Duma
- (void)testAsync {
    XCTestExpectation *expec = [self expectationWithDescription:@"should wait until done"];
    
    dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", nil);
    dispatch_group_t group = dispatch_group_create();
    
    for (int i=0; i < 5; i++) {
        NSLog(@"starting operation %@..", @(i));
        
        NSString *const message = [[NSString alloc] initWithFormat:@"completed operation %@!", @(i)];
        dispatch_group_enter(group);
        [self waitAndLog:arc4random_uniform(5) message:message completion:^{
            dispatch_async(serialQueue, ^{
                dispatch_group_leave(group);
            });
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"everything is done!!");
        [expec fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)waitAndLog:(int)delay message:(NSString *)message completion:(void (^)(void))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((double)delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", message);
        completion();
    });
}

@end
