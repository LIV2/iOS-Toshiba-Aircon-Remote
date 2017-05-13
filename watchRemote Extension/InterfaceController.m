//
//  InterfaceController.m
//  watchRemote Extension
//
//  Created by Matt Harlum on 7/3/17.
//  Copyright © 2017 Matt Harlum. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *picker;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceSwitch *switchin;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *buttonin;
@end


@implementation InterfaceController
NSInteger ac_temp;
BOOL ac_power;

- (void)pickerDidSettle:(WKInterfacePicker *)picker
{
    
}
- (IBAction)pickerAction:(NSInteger)value {
    ac_temp = value;
}

- (IBAction)switchAction:(BOOL)value {
    ac_power = value;
}

- (IBAction)buttonAction {
    [self SaveSettings];
    [self sendCommand];
}

- (void)SaveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:ac_temp forKey:@"temp"];
    [defaults setInteger:ac_power forKey:@"power"];
}

- (void)LoadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    ac_temp = [defaults integerForKey:@"temp"];
    ac_power = [defaults boolForKey:@"power"];
    [self.picker setSelectedItemIndex:ac_temp];
    [self.switchin setOn:ac_power];
}

- (void)sendCommand {
    NSDictionary *ac_settings = @{@"temp": [NSNumber numberWithInt:ac_temp], @"power": [NSNumber numberWithBool:ac_power]};
    [[WCSession defaultSession] sendMessage:ac_settings
                               replyHandler:^(NSDictionary *reply) {
                                   //handle reply from iPhone app here
                               }
                               errorHandler:^(NSError *error) {
                                   //catch any errors here
                               }
     ];
    NSLog(@"Sending");
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSArray *temperature = @[@"17℃", @"18℃", @"19℃", @"20℃", @"21℃", @"22℃", @"23℃", @"24℃", @"25℃", @"26℃", @"27℃", @"28℃", @"29℃", @"30℃"];
    int i;
    for (i=0;i<[temperature count];i++)
    {
        WKPickerItem *item = [WKPickerItem alloc];
        item.title = (NSString *) temperature[i];
        [items addObject:item];
    }
    [self.picker setItems:items];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    [self LoadSettings];
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    ac_temp = ([[message objectForKey:@"temp"] intValue]);
    ac_power = ([[message objectForKey:@"power"] boolValue]);
    [self.picker setSelectedItemIndex:ac_temp];
    [self.switchin setOn:ac_power];
    [self SaveSettings];
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error
{
}

- (void) sessionDidBecomeInactive:(WCSession *)session {
}
@end



