#import <Foundation/Foundation.h>

@interface OscServiceFinder : NSObject <NSNetServiceBrowserDelegate,
                                        NSNetServiceDelegate> {
@private
  NSNetServiceBrowser *netServiceBrowser;
  NSString *serviceName;
  NSString *address;
  NSInteger port;
  BOOL found;
}

@property (readonly, nonatomic) NSString *serviceName;
@property (readonly, nonatomic) NSString *address;
@property (readonly, nonatomic) NSInteger port;
@property (readonly, nonatomic) BOOL found;

@end
