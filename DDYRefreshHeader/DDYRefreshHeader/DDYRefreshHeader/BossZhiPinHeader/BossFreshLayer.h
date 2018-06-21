#import <QuartzCore/QuartzCore.h>

@interface BossFreshLayer : CALayer
/** 动画进度 0.0=未开始或者结束 1.0=正在刷新时动画 0.0<初始步进动画>1.0 */
@property (nonatomic, assign) CGFloat complete;

- (void)startAnimating;

- (void)stopAnimating;

@end
