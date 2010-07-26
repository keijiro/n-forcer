#import "OscServiceFinder.h"
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation OscServiceFinder

@synthesize serviceName;
@synthesize address;
@synthesize port;
@synthesize found;

- (id)init {
  if ((self = [super init])) {
    netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    [netServiceBrowser setDelegate:self];
    [netServiceBrowser searchForServicesOfType:@"_osc._udp" inDomain:@""];
    serviceName = nil;
    address = nil;
    port = 0;
    found = NO;
  }
  return self;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing {
  NSLog(@"didFindService:%@", netService);
  [netService retain];
  [netService setDelegate:self];
  [netService resolveWithTimeout:5];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
  if (found) return;
  
  for (int i = 0; i < sender.addresses.count; ++i) {
    NSData *data = [sender.addresses objectAtIndex:i];
    const struct sockaddr *saddr = (struct sockaddr *)[data bytes];
    if (saddr->sa_family != AF_INET) continue;

    struct sockaddr_in *saddr_in = (struct sockaddr_in *)saddr;
    char addrstr[INET_ADDRSTRLEN];
    inet_ntop(AF_INET, &saddr_in->sin_addr, addrstr, INET_ADDRSTRLEN);
    
    serviceName = [sender.name copy];
    address = [[NSString alloc] initWithUTF8String:addrstr];
    port = sender.port;
    found = YES;
    
    NSLog(@"%@(%@:%d)", serviceName, address, port);
    break;
  }
  
  [sender release];
}

- (void)dealloc {
  [netServiceBrowser release];
  [serviceName release];
  [address release];
  [super dealloc];
}

@end
