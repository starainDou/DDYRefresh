#import "BossHeaderView.h"
#import "BossFreshLayer.h"

const CGFloat BossHeaderHeight = 80.0;

@interface BossHeaderView ()

@property (nonatomic, strong) BossFreshLayer *freshLayer;

@end

@implementation BossHeaderView

- (BossFreshLayer *)freshLayer {
    if (!_freshLayer) {
        _freshLayer = [BossFreshLayer layer];
        _freshLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_freshLayer];
    }
    return _freshLayer;
}

#pragma mark 初始化配置
- (void)prepare {
    [super prepare];
    self.mj_h = BossHeaderHeight;
}

- (void)placeSubviews {
    [super placeSubviews];
    self.freshLayer.frame = CGRectMake(0, 15, self.bounds.size.width, 40);
}

- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
    self.mj_y = -self.mj_h * MAX(0.0, MIN(1.0, pullingPercent));
    self.freshLayer.frame = CGRectMake(0, 15*MAX(0.0, MIN(1.0, pullingPercent)), self.bounds.size.width, 40);
    self.freshLayer.complete = MAX(0.0, MIN(1.0, pullingPercent));
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState
    if (state == MJRefreshStateIdle) { //普通闲置状态
        [self.freshLayer stopAnimating];
    } else if (state == MJRefreshStateRefreshing) { //正在刷新中的状态
        [self.freshLayer startAnimating];
    }
}

- (void)dealloc {
    [_freshLayer removeFromSuperlayer];
    _freshLayer = nil;
}

@end
