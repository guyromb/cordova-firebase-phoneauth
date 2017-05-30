#import "FirebasePhoneNumberAuthPlugin.h"
@import Firebase;

@implementation FirebasePhoneNumberAuthPlugin

- (void)initialize:(CDVInvokedUrlCommand *)command {

    [UIApplication sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [UIApplication sharedInstance].uiDelegate = self.viewController;
    [UIApplication sharedInstance].delegate = self;
    self.allowedDomains = [command argumentAtIndex:0];


    self.eventCallbackId = command.callbackId;
}


- (void)getToken:(CDVInvokedUrlCommand *)command {

    FIRUser *currentUser = [FIRAuth auth].currentUser;
    [currentUser getTokenForcingRefresh:YES
                             completion:^(NSString *_Nullable idToken,
                                          NSError *_Nullable error) {

                                 NSDictionary *message;

                                 if (error) {
                                     message = @{
                                                 @"type": @"signinfailure",
                                                 @"data": @{
                                                         @"code": [NSNumber numberWithInteger:error.code],
                                                         @"message": error.description == nil ? [NSNull null] : error.description
                                                         }
                                                 };
                                     CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                                                   messageAsDictionary:@{
                                                                                                         @"code": [NSNumber numberWithInteger:error.code],
                                                                                                         @"message": error.description == nil ? [NSNull null] : error.description
                                                                                                         }];
                                     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

                                 } else {

                                     CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:idToken];
                                     [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                 }
                             }];

}

- (void)sendSMS:(CDVInvokedUrlCommand *)command {

    [[FIRPhoneAuthProvider provider]
    verifyPhoneNumber:phoneNumber
           completion:^(NSString *_Nullable verificationID,
                        NSError *_Nullable error) {
  if (error) {
    // Verification code not sent.
  } else {
    // Successful.

    // Show the Screen to enter the Code.
    // Developer may want to save that verificationID along with other app states in case
    // the app is terminated before the user gets the SMS verification code.
  }
}];

}

- (void)verifyCode:(CDVInvokedUrlCommand *)command {
[[FIRAuth auth]
    signInWithCredential:credential
              completion:^(FIRUser *user, NSError *error) {
  if (error) {
    // Error
  } else {
     // Successful.
     // User is signed in.
     // This should display the phone number.
     NSLog(@"Phone number: %@", user.phoneNumber);
     // Get the phone number provider.
     id userInfo = user.providerData[0];
     // The phone number provider UID is the phone number itself.
     NSLog(@"Phone provider uid: %@", userInfo.uid);
     // The phone number providerID is 'phone'
     NSLog(@"Phone provider ID: %@", userInfo.providerID);
    }
  }];
  
//     [[UIApplication sharedInstance] signIn];
}

- (void)signOut:(CDVInvokedUrlCommand *)command {

    NSDictionary *message = nil;
    NSError *error;

    [[FIRAuth auth] signOut:&error];

    if (error == nil) {
        message = @{
                @"type": @"signoutsuccess"
        };
    } else {

        message = @{
                @"type": @"signoutfailure",
                @"data": @{
                        @"code": [NSNumber numberWithInteger:error.code],
                        @"message": error.description == nil ? [NSNull null] : error.description
                }
        };
    }

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCallbackId];
}


// 
// #pragma mark - Helper functions
// 
// - (NSString *)toJSON:(NSDictionary *)data {
//     NSError *error = nil;
//     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
// 
//     return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
// }
// 
// - (void)signIn:(NSString *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
// 
//     NSDictionary *message = nil;
//     if (error == nil) {
//         if([self.allowedDomains indexOfObject: user.hostedDomain] == NSNotFound) {
// 
//             [[UIApplication sharedInstance] signOut];
//             CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
//                     @"type": @"signinfailure",
//                     @"data": @{
//                             @"code": @"domain_not_allowed",
//                             @"message": @"the domain is not allowed"
//                     }
//             }];
//             [pluginResult setKeepCallbackAsBool:YES];
//             [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCallbackId];
//         } else {
//             GIDAuthentication *authentication = user.authentication;
//             FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
//                                                                              accessToken:authentication.accessToken];
//             [[FIRAuth auth] signInWithCredential:credential
//                                       completion:[self handleLogin]];
//         }
//     } else {
//         CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{
//                 @"type": @"signinfailure",
//                 @"data": @{
//                         @"code": @(error.code),
//                         @"message": error.description
//                 }
//         }];
//         [pluginResult setKeepCallbackAsBool:YES];
//         [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCallbackId];
//     }
// 
// }
// 
// - (void (^)(FIRUser *, NSError *))handleLogin {
//     return ^(FIRUser *user, NSError *error) {
// 
//         if (error == nil) {
//             FIRUser *currentUser = [FIRAuth auth].currentUser;
//             [currentUser getTokenForcingRefresh:YES
//                                      completion:^(NSString *_Nullable idToken,
//                                                   NSError *_Nullable error) {
//                                          
//                                          NSDictionary *message;
//                                          
//                                          if (error) {
//                                              message = @{
//                                                          @"type": @"signinfailure",
//                                                          @"data": @{
//                                                                  @"code": [NSNumber numberWithInteger:error.code],
//                                                                  @"message": error.description == nil ? [NSNull null] : error.description
//                                                                  }
//                                                          };
//                                          } else {
//                                         
//                                             message = @{
//                                                          @"type": @"signinsuccess",
//                                                          @"data": @{
//                                                                  @"token": idToken,
//                                                                  @"id": user.uid == nil ? [NSNull null] : user.uid,
//                                                                  @"name": user.displayName == nil ? [NSNull null] : user.displayName,
//                                                                  @"email": user.email == nil ? [NSNull null] : user.email,
//                                                                  @"photoUrl": user.photoURL == nil ? [NSNull null] : [user.photoURL absoluteString]
//                                                                  }
//                                                          };
//                                              
//                                              
//                                              CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
//                                              [pluginResult setKeepCallbackAsBool:YES];
//                                              [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCallbackId];
//                                          }
//                                          
//                                          // Send token to your backend via HTTPS
//                                          // ...
//                                      }];
//         } else {
//             NSDictionary *message = @{
//                     @"type": @"signinfailure",
//                     @"data": @{
//                             @"code": [NSNumber numberWithInteger:error.code],
//                             @"message": error.description == nil ? [NSNull null] : error.description
//                     }
//             };
//             
//             CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
//             [pluginResult setKeepCallbackAsBool:YES];
//             [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCallbackId];
//         }
//     };
// }
// 
// - (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
// 
//     NSDictionary *message = nil;
//     if (error == nil) {
//         GIDProfileData *profile = user.profile;
//         message = @{
//                 @"type": @"signoutsuccess"
//         };
//     } else {
//         message = @{
//                 @"type": @"signoutfailure",
//                 @"data": @{
// 
//                         @"code": [NSNumber numberWithInteger:error.code],
//                         @"message": error.description == nil ? [NSNull null] : error.description
//                 }
//         };
//     }
// 
//     CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
//     [pluginResult setKeepCallbackAsBool:YES];
//     [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCallbackId];
// }

@end
