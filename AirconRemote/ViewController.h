//
//  ViewController.h
//  AirconRemote
//
//  Created by Matt Harlum on 5/3/17.
//  Copyright © 2017 Matt Harlum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MQTTClient.h"
#import <WatchConnectivity/WatchConnectivity.h>
@interface ViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, WCSessionDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
-(void)SendMQTTPacket;
@end
