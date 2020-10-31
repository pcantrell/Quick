@import XCTest;
@import Quick;
@import Nimble;

#import "QCKSpecRunner.h"

typedef NS_ENUM(NSUInteger, AfterEachType) {
    OuterOne,
    OuterTwo,
    OuterThree,
    InnerOne,
    InnerTwo,
    NoExamples,
};

static NSMutableArray *afterEachOrder;

QuickSpecBegin(FunctionalTests_AfterEachSpec_ObjC)

afterEach(^{ [afterEachOrder addObject:@(OuterOne)]; });
afterEach(^{ [afterEachOrder addObject:@(OuterTwo)]; });
afterEach(^{ [afterEachOrder addObject:@(OuterThree)]; });

it(@"executes the outer afterEach closures once, but not before this closure [1]", ^{
    expect(afterEachOrder).to(equal(@[]));
});

it(@"executes the outer afterEach closures a second time, but not before this closure [2]", ^{
    expect(afterEachOrder).to(equal(@[@(OuterThree), @(OuterTwo), @(OuterOne)]));
});

context(@"when there are nested afterEach", ^{
    afterEach(^{ [afterEachOrder addObject:@(InnerOne)]; });
    afterEach(^{ [afterEachOrder addObject:@(InnerTwo)]; });

    it(@"executes the outer and inner afterEach closures, but not before this closure [3]", ^{
        // The afterEach for the previous two examples should have been run.
        // The list should contain the afterEach for those example, executed from top to bottom.
        expect(afterEachOrder).to(equal(@[
            @(OuterThree), @(OuterTwo), @(OuterOne),
            @(OuterThree), @(OuterTwo), @(OuterOne),
        ]));
    });
});

context(@"when there are nested afterEach without examples", ^{
    afterEach(^{ [afterEachOrder addObject:@(NoExamples)]; });
});

QuickSpecEnd

@interface AfterEachTests_ObjC : XCTestCase; @end

@implementation AfterEachTests_ObjC

- (void)setUp {
    [super setUp];
    afterEachOrder = [NSMutableArray array];
}

- (void)tearDown {
    afterEachOrder = [NSMutableArray array];
    [super tearDown];
}

- (void)testAfterEachIsExecutedInTheCorrectOrder {
    qck_runSpec([FunctionalTests_AfterEachSpec_ObjC class]);
    NSArray *expectedOrder = @[
        // [1] The outer afterEach closures are executed from top to bottom.
        @(OuterThree), @(OuterTwo), @(OuterOne),
        // [2] The outer afterEach closures are executed from top to bottom.
        @(OuterThree), @(OuterTwo), @(OuterOne),
        // [3] The outer afterEach closures are executed from top to bottom,
        //     then the outer afterEach closures are executed from top to bottom.
        @(InnerTwo), @(InnerOne), @(OuterThree), @(OuterTwo), @(OuterOne),
    ];

    XCTAssertEqualObjects(afterEachOrder, expectedOrder);
}

@end
