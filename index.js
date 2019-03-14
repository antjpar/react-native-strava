
import { NativeModules } from 'react-native';

const { RNReactNativeStrava } = NativeModules;

class RNStrava {
  static login(client_id, redirect_uri, response_type = 'code', approval_prompt = 'auto', scope = 'activity:write,read') {
    RNReactNativeStrava.login(client_id, redirect_uri, response_type, approval_prompt, scope);
  }
}

export default RNStrava;
