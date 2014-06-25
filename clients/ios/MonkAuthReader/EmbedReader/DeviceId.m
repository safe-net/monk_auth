//
//  DeviceId.m
//  EmbedReader
//
//  Created by Sharma, Hemant on 6/25/14.
//
//

#import "DeviceId.h"
#import "SSKeychain.h"

@implementation DeviceId

// Stores value of 'identifierForVendor' in keychain to use same id across delete/re-install
// of the app.
-(NSString *) getUniqueDeviceIdentifierAsString
{
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        // An alphanumeric string that uniquely identifies a device to the app’s vendor.
        // The value of this property is the same for apps that come from the same vendor
        // running on the same device. A different value is returned for apps on the same
        // device that come from different vendors, and for apps on different devices
        // regardless of vendor.
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    
    return strApplicationUUID;
}

-(NSString *) getDeviceName
{
    // The value of this property is an arbitrary alphanumeric string that is associated
    // with the device as an identifier.
    return [[UIDevice currentDevice] name];
}
@end
