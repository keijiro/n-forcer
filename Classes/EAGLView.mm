#import "EAGLView.h"
#import "OscClient.h"

@implementation EAGLView

@synthesize animating;

+ (Class)layerClass {
  return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder {
  if ((self = [super initWithCoder:coder])) {
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = TRUE;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:FALSE],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat,
                                    nil];

    if (!(renderer = [[Renderer alloc] init])) {
      [self release];
      return nil;
    }

    animating = FALSE;
    displayLink = nil;
    fingerLevel[0] = fingerLevel[1] = 0;
    wristLevel[0] = wristLevel[1] = 0;
  }
  return self;
}

- (void)drawView:(id)sender {
  // クリアカラーの設定
  GLfloat level = (fingerLevel[0] + fingerLevel[1]) * 0.5f;
  GLfloat gadd = level + wristLevel[0] * 0.15f;
  GLfloat badd = level + wristLevel[1] * 0.15f;
  [renderer setClearColorRed:level green:(level + gadd) blue:(level + badd)];
  // レンダリング
  [renderer render];
}

- (void)layoutSubviews {
  [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
  [self drawView:nil];
}

- (void)startAnimation {
  if (!animating) {
    displayLink = [NSClassFromString(@"CADisplayLink")
                   displayLinkWithTarget:self
                   selector:@selector(drawView:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
    animating = TRUE;
    // 加速度センサーのデリゲートを設定
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 20)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
  }
}

- (void)stopAnimation {
  if (animating) {
    [displayLink invalidate];
    displayLink = nil;
    animating = FALSE;
  }
}

// タッチ処理
- (void)processTouch:(UITouch *)touch isOn:(BOOL)isOn {
  CGPoint pt = [touch locationInView:self];
  // Ｘ座標からスロット特定
  NSInteger slot = (pt.x < self.center.x) ? 0 : 1;
  // Ｙ座標からレベル算出（中央から上に向かって上昇、指離し時はゼロ）
  float y = isOn ? 1.05f - 1.1f * pt.y / self.center.y : 0.0f;
  fingerLevel[slot] = MIN(MAX(y, 0.0f), 1.0f);
  // メッセージ送信
  OscClient::SendFingerMessage(slot, fingerLevel[slot]);
}

// タッチ開始
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  for (UITouch *touch in touches) {
    [self processTouch:touch isOn:YES];
  }
}

// タッチ移動
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    [self processTouch:touch isOn:YES];
  }
}

// タッチ終了
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  for (UITouch *touch in touches) {
    [self processTouch:touch isOn:NO];
  }
}

// 加速度センサー
- (void)accelerometer:(UIAccelerometer*)accelerometer
        didAccelerate:(UIAcceleration*)acceleration {
  // Ｙ軸からピッチ角を算出（水平から上向きに値上昇）
  float pitch = MAX(MIN(-acceleration.y * 1.1f, 1.0f), 0.0f);
  // Ｚ軸からロール角を算出（水平から上下に値上昇）
  float roll = MAX(MIN(ABS(acceleration.x) * 1.2f - 0.2f, 1.0f), 0.0f);
  // ローパスフィルター
  wristLevel[0] = 0.5f * wristLevel[0] + 0.5f * pitch;
  wristLevel[1] = 0.5f * wristLevel[1] + 0.5f * roll;
  // メッセージ送信
  OscClient::SendWristMessage(wristLevel[0], wristLevel[1]);
}

- (void)dealloc {
  [renderer release];
  [super dealloc];
}

@end
