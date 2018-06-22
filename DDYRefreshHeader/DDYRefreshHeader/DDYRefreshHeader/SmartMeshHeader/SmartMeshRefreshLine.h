#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SmartMeshRefreshLine : NSObject

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGFloat translationX;
@property (nonatomic, assign) CGFloat translationY;
@property (nonatomic, assign) BOOL isHighLight;

/** 根据两点坐标字典生成在相应bounds上的位置的线 */
+ (id)lineWithPointDict:(NSDictionary *)dict inBounds:(CGRect)bounds;
/** 重新生成随机translationX */
- (void)remakeTranslationX;

@end
