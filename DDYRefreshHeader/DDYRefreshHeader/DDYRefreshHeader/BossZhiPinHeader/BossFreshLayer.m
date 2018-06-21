#import "BossFreshLayer.h"
#import <UIKit/UIKit.h>

const CGFloat lineWidth = 10.0;
const CGFloat marginOff = 15.0;

static inline UIColor *color1(void) {return [UIColor colorWithRed:245./255. green:198./255. blue:  4./255. alpha:1];}
static inline UIColor *color2(void) {return [UIColor colorWithRed:136./255. green:136./255. blue:136./255. alpha:1];}
static inline UIColor *color3(void) {return [UIColor colorWithRed: 51./255. green:153./255. blue:153./255. alpha:1];}
static inline UIColor *color4(void) {return [UIColor colorWithRed:237./255. green:119./255. blue:  0./255. alpha:1];}

@interface BossFreshLayer ()
/** 正在刷新动画时四个圆点离合动画 */
@property (nonatomic, assign) CGFloat pointScale;

@end

static BOOL _isAnimating;

@implementation BossFreshLayer

#pragma mark 如果属性pointScale被修改将触发绘制
+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"pointScale"] ? YES : [super needsDisplayForKey:key];
}

- (void)setComplete:(CGFloat)complete {
    if (_complete != complete) {
        _complete = complete;
        [self setNeedsDisplay];
    }
}

- (void)startAnimating {
    _isAnimating = YES;
    CGFloat duration = 0.4;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"pointScale"];
    scaleAnimation.fromValue = @(1.0);
    scaleAnimation.toValue = @(0.5);
    scaleAnimation.duration = duration;
    scaleAnimation.repeatCount = MAXFLOAT;
    scaleAnimation.autoreverses = YES;
    [self addAnimation:scaleAnimation forKey:nil];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = @(0);
    rotateAnimation.toValue = @(M_PI * 2);
    rotateAnimation.duration = duration * 4;
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotateAnimation.repeatCount = MAXFLOAT;
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.removedOnCompletion = NO;
    [self addAnimation:rotateAnimation forKey:nil];
}

- (void)stopAnimating {
    _isAnimating = NO;
    self.complete = 0.0;
    [self removeAllAnimations];
}

CGPoint targetPoint(CGPoint basePoint, CGPoint movePoint, CGFloat scale) {
    return CGPointMake(basePoint.x + (movePoint.x-basePoint.x)*scale, basePoint.y + (movePoint.y-basePoint.y)*scale);
}

#pragma mark 用于绘制两点间逐渐连线 isPoint为YES表示圆点
void drawResult(CGContextRef ctx, CGPoint basePoint, CGPoint movePoint, UIColor *color, BOOL isPoint) {
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextMoveToPoint(ctx, basePoint.x, basePoint.y);
    CGContextAddLineToPoint(ctx, isPoint ? basePoint.x : movePoint.x, isPoint ? basePoint.y : movePoint.y);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextDrawPath(ctx, kCGPathStroke);
};

- (void)drawInContext:(CGContextRef)ctx {
    
    CGPoint point1 = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)-marginOff);
    CGPoint point2 = CGPointMake(CGRectGetMidX(self.bounds)-marginOff, CGRectGetMidY(self.bounds));
    CGPoint point3 = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)+marginOff);
    CGPoint point4 = CGPointMake(CGRectGetMidX(self.bounds)+marginOff, CGRectGetMidY(self.bounds));
    if (_isAnimating) {
        CGFloat tempScale = [(BossFreshLayer *)self.presentationLayer pointScale];
        CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        drawResult(ctx, targetPoint(centerPoint, point1, tempScale), CGPointZero, color1(), YES);
        drawResult(ctx, targetPoint(centerPoint, point2, tempScale), CGPointZero, color2(), YES);
        drawResult(ctx, targetPoint(centerPoint, point3, tempScale), CGPointZero, color3(), YES);
        drawResult(ctx, targetPoint(centerPoint, point4, tempScale), CGPointZero, color4(), YES);
    } else {
        if (_complete > 0.95) {
            drawResult(ctx, point1, targetPoint(point1, point4, ((1.00-_complete)/0.05)), color1(), NO);
        } else if (_complete > 0.85) {
            drawResult(ctx, point4, targetPoint(point4, point1, ((_complete-0.85)/0.10)), color4(), NO);
        } else if (_complete > 0.80) {
            drawResult(ctx, point4, targetPoint(point4, point3, ((0.85-_complete)/0.05)), color4(), NO);
        } else if (_complete > 0.70) {
            drawResult(ctx, point3, targetPoint(point3, point4, ((_complete-0.70)/0.10)), color3(), NO);
        } else if (_complete > 0.65) {
            drawResult(ctx, point3, targetPoint(point3, point2, ((0.70-_complete)/0.05)), color3(), NO);
        } else if (_complete > 0.55) {
            drawResult(ctx, point2, targetPoint(point2, point3, ((_complete-0.55)/0.10)), color2(), NO);
        } else if (_complete > 0.50) {
            drawResult(ctx, point2, targetPoint(point2, point1, ((0.55-_complete)/0.05)), color2(), NO);
        } else if (_complete > 0.40) {
            drawResult(ctx, point1, targetPoint(point1, point2, ((_complete-0.40)/0.10)), color1(), NO);
        }
        if (_complete > 0.85) drawResult(ctx, point4, CGPointZero, color4(), YES);
        if (_complete > 0.70) drawResult(ctx, point3, CGPointZero, color3(), YES);
        if (_complete > 0.55) drawResult(ctx, point2, CGPointZero, color2(), YES);
        if (_complete > 0.40) drawResult(ctx, point1, CGPointZero, color1(), YES);
    }
}

@end
