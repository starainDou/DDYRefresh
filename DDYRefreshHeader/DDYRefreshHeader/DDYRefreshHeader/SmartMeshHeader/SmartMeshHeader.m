#import "SmartMeshHeader.h"
#import "SmartMeshRefreshLine.h"

const CGFloat SmartMeshHeaderHeight = 80.0;
const CGFloat SmartMeshHeaderLineW = 2.0;
const CGFloat SmartMeshEndDuration = 0.4;
static inline UIColor *smartMeshMainColor(CGFloat alpha) {return [UIColor colorWithRed:228./255. green:200./255. blue:0./255. alpha:alpha];}

@interface SmartMeshHeader ()
@property (nonatomic, strong) NSMutableArray *lineArray;
@property (nonatomic, assign) CGFloat complete;
@property (nonatomic, strong) CADisplayLink *displayLink;
/** 从即将结束到完全结束逐步调节 */
@property (nonatomic, strong) NSOperationQueue *graduallyQueue;
/** 文字 */
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation SmartMeshHeader

#pragma mark - swizzle
+ (void)load {
    SEL originakSEL = NSSelectorFromString(@"endRefreshing");
    SEL swizzleSEL = NSSelectorFromString(@"endSmartMeshRefreshing");
    Method originalMethod = class_getInstanceMethod([self class], originakSEL);
    Method swizzleMethod = class_getInstanceMethod([self class], swizzleSEL);
    if (class_addMethod([self class], originakSEL, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod))) {
        class_replaceMethod([self class], swizzleSEL, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzleMethod);
    }
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        _tipLabel.font = [UIFont systemFontOfSize:13];
        _tipLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_tipLabel];
    }
    return _tipLabel;
}

- (NSOperationQueue *)graduallyQueue {
    if (!_graduallyQueue) {
        _graduallyQueue = [[NSOperationQueue alloc] init];
        _graduallyQueue.maxConcurrentOperationCount = 1;
    }
    return _graduallyQueue;
}

- (NSMutableArray *)lineArray {
    if (!_lineArray) {
        _lineArray = [NSMutableArray array];
        NSArray *pointArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SmartMesh" ofType:@"plist"]];
        for (NSDictionary *tempDict in pointArray) {
            [_lineArray addObject:[SmartMeshRefreshLine lineWithPointDict:tempDict inBounds:self.bounds]];
        }
    }
    return _lineArray;
}

- (void)setComplete:(CGFloat)complete {
    if (_complete != complete) {
        _complete = complete;
        [self setNeedsDisplay];
    }
}

#pragma mark 初始化配置
- (void)prepare {
    [super prepare];
    self.mj_h = SmartMeshHeaderHeight;
}

- (void)placeSubviews {
    [super placeSubviews];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[tipLabel]-|" options:0 metrics:nil views:@{@"tipLabel":self.tipLabel}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=50)-[tipLabel(20)]-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:@{@"tipLabel":self.tipLabel}]];
    if (MJRefreshStateIdle == self.state) {
        // 变换随机translationX
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(remakeTranslationX) object:nil];
        [self performSelector:@selector(remakeTranslationX) withObject:nil afterDelay:0.1];
    }
}

- (void)remakeTranslationX {
    for (int i = 0; i < self.lineArray.count; i++) {
        SmartMeshRefreshLine *line = self.lineArray[i];
        line.isHighLight = i%2==1 ? YES : NO;
        [line remakeTranslationX];
    }
}

- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    self.mj_y = -self.mj_h * MAX(0.0, MIN(1.0, pullingPercent));
    self.complete = MAX(0.0, MIN(1.0, pullingPercent));
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    if (state == MJRefreshStateIdle) { //普通闲置状态
        [self stopDisplayLink];
        self.tipLabel.text = @"下拉刷新";
    } else if (state == MJRefreshStatePulling) { //正在刷新中的状态
        self.tipLabel.text = @"松开刷新";
    } else if (state == MJRefreshStateRefreshing) { //正在刷新中的状态
        [self startDisplayLink];
        self.tipLabel.text = @"正在刷新";
    }
}

- (void)endSmartMeshRefreshing {
    [self stopDisplayLink];
    [self graduallyEndAnimation];
    [self performSelector:@selector(endSmartMeshRefreshing) withObject:nil afterDelay:SmartMeshEndDuration];
}

- (void)graduallyEndAnimation {
    [self.graduallyQueue cancelAllOperations];
    CGFloat times = 20.0;
    CGFloat stepValue = self.complete/times;
    __weak __typeof__ (self)weakSelf = self;
    for (int i = 1; i < (int)(times+1.0); i++) {
        [self.graduallyQueue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:(SmartMeshEndDuration/times)];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                __strong __typeof__ (weakSelf)strongSelf = weakSelf;
                strongSelf.complete = MAX(0.0, MIN(1.0, strongSelf.complete-stepValue*i));
            }];
        }];
    }
}

- (void)dealloc {
    [self.graduallyQueue cancelAllOperations];
    [self stopDisplayLink];
}

- (void)drawRect:(CGRect)rect {
    for (SmartMeshRefreshLine *line in self.lineArray) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:line.startPoint];
        [path addLineToPoint:line.endPoint];
        [path setLineWidth:SmartMeshHeaderLineW];
        [path applyTransform:CGAffineTransformMakeTranslation(line.translationX*(1.0-self.complete), line.translationY * (1.0-self.complete))];
        if (self.state == MJRefreshStateRefreshing) {
            [smartMeshMainColor((line.isHighLight = !line.isHighLight) ? 0.5 : 1) set];
        } else {
            [smartMeshMainColor(self.complete<=0.5 ? self.complete : 1) set];
        }
        [path stroke];
    }
}

- (void)startDisplayLink {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
    _displayLink.frameInterval = 30;
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopDisplayLink {
    [_displayLink invalidate];
    _displayLink = nil;
}

@end
