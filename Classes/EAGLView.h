#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Renderer.h"

@interface EAGLView : UIView <UIAccelerometerDelegate> {    
@private
  Renderer *renderer;
  BOOL animating;
  id displayLink;
  float fingerLevel[2]; // 指入力レベル
  float wristLevel[2];  // 手首入力レベル
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;
// タッチ共通処理
- (void)processTouch:(UITouch *)touch isOn:(BOOL)isOn;

@end
