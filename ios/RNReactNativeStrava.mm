#import <SafariServices/SafariServices.h>
#import <Foundation/Foundation.h>

#import "RNReactNativeStrava.h"
//#import <AuthenticationServices/AuthenticationServices.h>

#import "ActivityExample.h"

@implementation RNReactNativeStrava

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

// client_id, redirect_uri, response_type = 'code', approval_prompt = 'auto', scope = 'activity:write,read'
RCT_EXPORT_METHOD(login:(NSString*)client_id
                  redirect_uri:(NSString*)redirect_uri
                  response_type:(NSString*)response_type
                  approval_prompt:(NSString*)approval_prompt
                  scope:(NSString*)scope
                  ) {
  
  NSString* mobileUri = [NSString stringWithFormat: @"strava://oauth/mobile/authorize?client_id=%@&redirect_uri=%@&response_type=%@&approval_prompt=%@&scope=%@", client_id, redirect_uri, response_type, approval_prompt, scope ];
  NSString* webUri = [NSString stringWithFormat: @"https://www.strava.com/oauth/mobile/authorize?client_id=%@&redirect_uri=%@&response_type=%@&approval_prompt=%@&scope=%@", client_id, redirect_uri, response_type, approval_prompt, scope ];
  
  
  NSURL* appOAuthUrl = [NSURL URLWithString: mobileUri];
  NSURL* webOAuthUrl = [NSURL URLWithString: webUri];
  
  if ([UIApplication.sharedApplication canOpenURL:appOAuthUrl ]) {
    [UIApplication.sharedApplication openURL:appOAuthUrl];
  } else {
    if (@available(iOS 11.0, *)) {
      _authSession = [[SFAuthenticationSession alloc] initWithURL:webOAuthUrl callbackURLScheme:@"noblepro://" completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
        [[UIApplication sharedApplication] openURL:callbackURL];
      }];
      [_authSession start];
    }
    
//    if (@available(iOS 12.0, *)) {
//
//      _authSessionA = [[ASWebAuthenticationSession alloc] initWithURL: webOAuthUrl callbackURLScheme:@"noblepro://mobile" completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
//        [[UIApplication sharedApplication] openURL:callbackURL];
//      }];
//      [_authSessionA start];
//    } else {
//      if (@available(iOS 11.0, *)) {
//        _authSession = [[SFAuthenticationSession alloc] initWithURL:webOAuthUrl callbackURLScheme:@"noblepro://" completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
//          [[UIApplication sharedApplication] openURL:callbackURL];
//        }];
//        [_authSession start];
//      } else {
//        // Fallback on earlier versions
//      }
//    }
  }
}

RCT_EXPORT_METHOD(generateFitFile:(NSDictionary*) session
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

  ActivityExample *ae = [[ActivityExample alloc] init];
  [ae encode:session];
  resolve(ae.filePath);
}
RCT_EXPORT_MODULE(RNReactNativeStrava);

@end

