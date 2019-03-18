
#import "RNReactNativeStrava.h"

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

}

RCT_EXPORT_MODULE(RNReactNativeStrava);

@end

