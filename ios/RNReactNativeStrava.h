
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <AuthenticationServices/AuthenticationServices.h>
#import <SafariServices/SafariServices.h>

API_AVAILABLE(ios(12.0))
@interface RNReactNativeStrava : NSObject <RCTBridgeModule>
  @property (nonatomic) ASWebAuthenticationSession *authSessionA;
  @property (nonatomic) SFAuthenticationSession *authSession;
@end
