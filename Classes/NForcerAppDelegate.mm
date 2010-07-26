#import "NForcerAppDelegate.h"
#import "EAGLView.h"
#import "OscClient.h"

@implementation NForcerAppDelegate

@synthesize window;
@synthesize glView;
@synthesize messageLabel;
@synthesize activityIndicatorView;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // メッセージラベルの書き換え
  messageLabel.text = @"Searching for service...";
  // OSCメッセージのベースパスをプレファレンスから取得し設定
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *pathname = [defaults stringForKey:@"osc_pathname_preference"];
  OscClient::SetBasePath([pathname UTF8String]);
  // OSCサービス検索の開始
  oscServiceFinder = [[OscServiceFinder alloc] init];
  connected = NO;
  // 表示制御用タイマーの初期化
  messageTimer = [NSTimer
                  scheduledTimerWithTimeInterval:1
                  target:self selector:@selector(updateMessage:) 
                  userInfo:nil repeats:TRUE];
  messageDelay = 0;
  // 描画開始
  [glView startAnimation];
  return YES;
}

- (void)updateMessage:(id)sender {
  if (oscServiceFinder.found && !connected) {
    // OSC接続
    OscClient::Open([oscServiceFinder.address UTF8String], oscServiceFinder.port);
    connected = YES;
    // メッセージラベルの書き換え（１０秒後に消去）
    messageLabel.text = [NSString
                         stringWithFormat:@"Connected to\n%@\n(%@:%d)",
                         oscServiceFinder.serviceName,
                         oscServiceFinder.address,
                         oscServiceFinder.port];
    messageDelay = 10;
    // 接続インジケーターを消去
    [activityIndicatorView stopAnimating];
  }
  // メッセージラベルの遅延消去
  if (messageDelay > 0) {
    if (--messageDelay == 0) {
      messageLabel.hidden = YES;
    }
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [glView stopAnimation];
}

- (void)dealloc {
  if (!connected) OscClient::Close();
  [window release];
  [glView release];
  [oscServiceFinder dealloc];
  [super dealloc];
}

@end
