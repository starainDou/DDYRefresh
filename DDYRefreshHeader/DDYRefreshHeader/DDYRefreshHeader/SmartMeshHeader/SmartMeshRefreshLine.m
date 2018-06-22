#import "SmartMeshRefreshLine.h"

@interface SmartMeshRefreshLine ()

@property (nonatomic, assign) CGRect bounds;

@end

@implementation SmartMeshRefreshLine

+ (id)lineWithPointDict:(NSDictionary *)dict inBounds:(CGRect)bounds {
    return [[self alloc] initWithDict:dict inBounds:bounds];
}

- (instancetype)initWithDict:(NSDictionary *)dict inBounds:(CGRect)bounds {
    if (self = [super init]) {
        CGPoint orignalStartPoint = CGPointFromString(dict[@"startPoint"]);
        CGPoint orignalEndPoint = CGPointFromString(dict[@"endPoint"]);
        _bounds = bounds;
        _startPoint = CGPointMake(bounds.size.width/2.-25 + orignalStartPoint.x, bounds.size.height/2.-25 + orignalStartPoint.y);
        _endPoint = CGPointMake(bounds.size.width/2.-25 + orignalEndPoint.x, bounds.size.height/2.-25 + orignalEndPoint.y);
        _translationX = (_startPoint.x+_endPoint.x)/2.-arc4random_uniform(floorl(bounds.size.width));
        _translationY = -MAX(_startPoint.y, _endPoint.y)-3;
        _isHighLight = arc4random_uniform(2)==1 ? YES : NO;
    }
    return self;
}

- (void)remakeTranslationX {
    _translationX = (_startPoint.x+_endPoint.x)/2.-arc4random_uniform(floorl(_bounds.size.width));
}

@end
