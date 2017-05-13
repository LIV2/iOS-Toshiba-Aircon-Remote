//
//  ViewController.m
//  AirconRemote
//
//  Created by Matt Harlum on 5/3/17.
//  Copyright © 2017 Matt Harlum. All rights reserved.
//

#import "ViewController.h"
#import "MQTTClient.h"
#import "MQTTSessionManager.h"

@interface ViewController () <WCSessionDelegate,MQTTSessionManagerDelegate>
{
    NSArray *_pickerData;

}
@property (nonatomic, strong) MQTTSessionManager *mqsession;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ModeSelectSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *FanSelectSeg;
@property (weak, nonatomic) IBOutlet UISwitch *PowerSwitch;
@property struct ac_settings *acsettings;
@property (strong,nonatomic) MQTTSSLSecurityPolicy *sslpol;
@property (strong,nonatomic) NSString *topic;
@property (weak, nonatomic) IBOutlet UIButton *SendButton;
@property (weak, nonatomic) IBOutlet UILabel *status;
@end


@implementation ViewController

struct ac_settings {
    uint8_t temp;
    uint8_t fan;
    uint8_t mode;
    bool power;
};
- (void)viewDidLoad {
    _pickerData = @[@"17℃", @"18℃", @"19℃", @"20℃", @"21℃", @"22℃", @"23℃", @"24℃", @"25℃", @"26℃", @"27℃", @"28℃", @"29℃", @"30℃"];
    self.picker.dataSource = self;
    self.picker.delegate = self;
    [self LoadSettings];
    [self UpdateControls];
    [super viewDidLoad];
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    [self ConnectMQTT];

}
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View will appear");
    [self ConnectMQTT];
    [self.mqsession addObserver:self
                     forKeyPath:@"state"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"View will disappear");
    [self.mqsession removeObserver:self forKeyPath:@"state"];
    [self DisconnectMQTT];
    self.mqsession = nil;
}

- (void)SaveSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.acsettings->temp forKey:@"temp"];
    [defaults setInteger:self.acsettings->mode forKey:@"mode"];
    [defaults setInteger:self.acsettings->fan forKey:@"fan"];
    [defaults setBool:self.acsettings->power forKey:@"power"];
}

- (void)LoadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.acsettings = malloc(sizeof(struct ac_settings));
    self.acsettings->temp = [defaults integerForKey:@"temp"];
    self.acsettings->fan = [defaults integerForKey:@"fan"];
    self.acsettings->mode = [defaults integerForKey:@"mode"];
    self.acsettings->power = [defaults boolForKey:@"power"];
}

- (void)UpdateControls {
    [self.picker selectRow:self.acsettings->temp inComponent:(NSInteger) 0x00 animated:FALSE];
    [self.ModeSelectSeg setSelectedSegmentIndex:self.acsettings->mode];
    [self.FanSelectSeg setSelectedSegmentIndex:self.acsettings->fan];
    [self.PowerSwitch setOn:self.acsettings->power];
}

- (void)ConnectMQTT {
    if (!self.mqsession)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.topic = [[NSString alloc] init];
        self.mqsession = [[MQTTSessionManager alloc] init];
        self.mqsession.delegate = self;
        NSString *host = [defaults valueForKey:@"host"];
        NSInteger port = [[defaults valueForKey:@"port"] intValue];
        NSString *user = [defaults valueForKey:@"user"];
        NSString *pass = [defaults valueForKey:@"pass"];
        BOOL tls = [defaults boolForKey:@"tls"];
        self.topic = [defaults valueForKey:@"topic"];
        self.sslpol = [[MQTTSSLSecurityPolicy alloc] init];
        self.sslpol.allowInvalidCertificates = TRUE;
        self.sslpol.validatesDomainName = FALSE;
        self.sslpol.validatesCertificateChain = FALSE;
        [self.mqsession connectTo:host
                             port:port
                              tls:tls
                        keepalive:60
                            clean:false
                             auth:true
                             user:user
                             pass:pass
                             will:true
                        willTopic:self.topic
                          willMsg:[@"Offline" dataUsingEncoding:NSUTF8StringEncoding]
                          willQos:0
                   willRetainFlag:false
                     withClientId:nil
                   securityPolicy:self.sslpol
                     certificates:nil];
    }
    else
    {
        [self.mqsession connectToLast];
    }
}

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
}


- (void)DisconnectMQTT {
    if (self.mqsession)
    {
        [self.mqsession disconnect];
    }
}

- (void)SendMQTTPacket {
    if (!self.mqsession)
    {
        [self ConnectMQTT];
    }
    Byte hdr[5] = {0xF2,0x0D,0x03,0xFC,0x01};
    NSMutableData *ir_packet = [NSMutableData data];
    Byte temp_byte = (self.acsettings->temp << 4);
    Byte mode_byte;
    Byte unknown_byte = 0x00;
    if (self.acsettings->power == true)
    {
        mode_byte = self.acsettings->mode;
    }
    else
    {
        mode_byte = 0x07;
    }
    if (self.acsettings->fan > 0)
    {
        mode_byte |= ((self.acsettings->fan + 1) << 5);
    }
    else
    {
        mode_byte |= (mode_byte & 0x0F);
    }
    uint8_t checksum_byte;
    checksum_byte = 0;
    for (int i=0; i<5; i++)
    {
        checksum_byte ^= hdr[i];
    }
    checksum_byte ^=temp_byte;
    checksum_byte ^=mode_byte;
    checksum_byte ^=unknown_byte;
    
    [ir_packet appendBytes:hdr length:5];
    [ir_packet appendBytes:&temp_byte length:1];
    [ir_packet appendBytes:&mode_byte length:1];
    [ir_packet appendBytes:&unknown_byte length:1];
    [ir_packet appendBytes:&checksum_byte length:1];

    
    [self.mqsession sendData:ir_packet
                        topic:self.topic
                         qos:MQTTQosLevelAtMostOnce
                      retain:FALSE];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (self.mqsession.state) {
        case MQTTSessionManagerStateClosed:
            self.status.text = @"closed";
            self.picker.userInteractionEnabled = false;
            self.ModeSelectSeg.enabled = false;
            self.FanSelectSeg.enabled = false;
            self.PowerSwitch.enabled = false;
            self.SendButton.enabled = false;

            break;
        case MQTTSessionManagerStateClosing:
            self.status.text = @"closing";
            self.picker.userInteractionEnabled = false;
            self.ModeSelectSeg.enabled = false;
            self.FanSelectSeg.enabled = false;
            self.PowerSwitch.enabled = false;
            self.SendButton.enabled = false;
            break;
        case MQTTSessionManagerStateConnected:
            self.status.text = @"connected";
            self.picker.userInteractionEnabled = true;
            self.ModeSelectSeg.enabled = true;
            self.FanSelectSeg.enabled = true;
            self.PowerSwitch.enabled = true;
            self.SendButton.enabled = true;
            break;
        case MQTTSessionManagerStateConnecting:
            self.status.text = @"connecting";
            self.picker.userInteractionEnabled = false;
            self.ModeSelectSeg.enabled = false;
            self.FanSelectSeg.enabled = false;
            self.PowerSwitch.enabled = false;
            self.SendButton.enabled = false;
            break;
        case MQTTSessionManagerStateError:
            self.status.text = @"error";
            self.picker.userInteractionEnabled = false;
            self.ModeSelectSeg.enabled = false;
            self.FanSelectSeg.enabled = false;
            self.PowerSwitch.enabled = false;
            self.SendButton.enabled = false;
            break;
        case MQTTSessionManagerStateStarting:
        default:
            self.status.text = @"not connected";
            self.picker.userInteractionEnabled = false;
            self.ModeSelectSeg.enabled = false;
            self.FanSelectSeg.enabled = false;
            self.PowerSwitch.enabled = false;
            self.SendButton.enabled = false;
            break;
    }
}

- (IBAction)SendCommand:(UIButton *)sender {
    NSDictionary *message = @{@"temp": [NSNumber numberWithInt:self.acsettings->temp], @"power": [NSNumber numberWithBool:self.acsettings->power]};
    [[WCSession defaultSession] sendMessage:message
                               replyHandler:^(NSDictionary *reply) {
                                   //handle reply from iPhone app here
                               }
                               errorHandler:^(NSError *error) {
                                   //catch any errors here
                               }
     ];
    NSLog(@"Sending");

    [self SendMQTTPacket];
    [self SaveSettings];
    
}

- (IBAction)FanSelection:(id)sender {
    UISegmentedControl *fanSelector = (UISegmentedControl *) sender;
    NSInteger fanSetting = fanSelector.selectedSegmentIndex;
    self.acsettings->fan = (uint8_t) fanSetting;
}

- (IBAction)ModeSelection:(id)sender {
    UISegmentedControl *modeSelector = (UISegmentedControl *) sender;
    NSInteger mode = modeSelector.selectedSegmentIndex;
    self.acsettings->mode = (uint8_t) mode;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.acsettings->temp = (uint8_t)row;
}


// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

- (IBAction)powerSwitch:(id)sender {
    if ([sender isOn])
    {
        self.acsettings->power = TRUE;
    }
    else
    {
        self.acsettings->power = FALSE;
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    self.acsettings->temp = ([[message objectForKey:@"temp"] intValue]);
    self.acsettings->power = ([[message objectForKey:@"power"] boolValue]);
    NSLog(@"%02X", self.acsettings->temp);
    dispatch_async(dispatch_get_main_queue(), ^{
    [self UpdateControls];
    });
    [self SaveSettings];
    [self SendMQTTPacket];
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error
{
}

- (void)sessionDidDeactivate:(WCSession *)session
{
}

- (void)sessionDidBecomeInactive:(WCSession *)session
{
}

@end
