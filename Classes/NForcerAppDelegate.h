#import <UIKit/UIKit.h>
#import "OscServiceFinder.h"

@class EAGLView;

@interface NForcerAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *window;
  EAGLView *glView;
  UILabel *messageLabel;
  UIActivityIndicatorView *activityIndicatorView;
  
  NSTimer *messageTimer;
  NSInteger messageDelay;
  OscServiceFinder *oscServiceFinder;
  BOOL connected;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (void)updateMessage:(id)sender;

@end
