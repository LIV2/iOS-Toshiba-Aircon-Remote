//
//  TableViewController.m
//  AirconRemote
//
//  Created by Matt Harlum on 10/3/17.
//  Copyright © 2017 Matt Harlum. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *hostvalue;
@property (weak, nonatomic) IBOutlet UITextField *portvalue;
@property (weak, nonatomic) IBOutlet UITextField *topicvalue;
@property (weak, nonatomic) IBOutlet UISwitch *sslvalue;
@property (weak, nonatomic) IBOutlet UITextField *uservalue;
@property (weak, nonatomic) IBOutlet UITextField *passvalue;
@end

@implementation TableViewController
- (IBAction)hostField:(id)sender {
}
- (IBAction)portField:(id)sender {
}
- (IBAction)topicField:(id)sender {
}
- (IBAction)sslToggle:(id)sender {
}
- (IBAction)userField:(id)sender {
}
- (IBAction)passField:(id)sender {
}
- (IBAction)savePressed:(id)sender {
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self LoadSettings];
}

- (IBAction)saveButton:(id)sender {
    [self SaveSettings];
}

- (void)SaveSettings {
    NSString *host = [_hostvalue text];
    NSString *port = [_portvalue text];
    NSString *topic = [_topicvalue text];
    BOOL tls = [_sslvalue isOn];
    NSString *user = [_uservalue text];
    NSString *pass = [_uservalue text];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:host forKey:@"host"];
    [defaults setValue:port forKey:@"port"];
    [defaults setValue:topic forKey:@"topic"];
    [defaults setBool:tls forKey:@"tls"];
    [defaults setValue:user forKey:@"user"];
    [defaults setValue:pass forKey:@"pass"];
    
}

- (void)LoadSettings {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _hostvalue.text = [defaults valueForKey:@"host"];
    _portvalue.text = [defaults valueForKey:@"port"];
    _topicvalue.text = [defaults valueForKey:@"topic"];
    _sslvalue.on = [defaults boolForKey:@"tls"];
    _uservalue.text = [defaults valueForKey:@"user"];
    _passvalue.text = [defaults valueForKey:@"pass"];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
