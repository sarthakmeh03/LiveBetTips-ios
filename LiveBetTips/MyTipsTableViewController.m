//
//  MyTipsTableViewController.m
//  LiveBetTips
//
//  Created by Ishan Khanna on 22/07/14.
//  Copyright (c) 2014 Ishan Khanna. All rights reserved.
//

#import "MyTipsTableViewController.h"
#import <RestKit.h>
#import "Tip.h"
#import "TipCell.h"
#import "TipDetailViewController.h"

@interface MyTipsTableViewController ()

@end

@implementation MyTipsTableViewController

int rowNumber;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadTips];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _tips.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TipCell" forIndexPath:indexPath];
    Tip *tip = _tips[indexPath.row];
    cell.leagueNameLabel.text = tip.leagueType;
    cell.homeTeamLabel.text = tip.homeTeam;
    cell.awayTeamLabel.text = tip.awayTeam;
    cell.isVerifiedLabel.text = tip.isPredictionVerified;
    // Configure the cell...
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Tip *tip = _tips[rowNumber];
    TipDetailViewController* destinationViewController = segue.destinationViewController;
    destinationViewController.leagueType = tip.leagueType;
    destinationViewController.homeVsAwayTeams = [NSString stringWithFormat:@"%@ vs %@", tip.homeTeam, tip.awayTeam];
    destinationViewController.tipId = tip.id;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    rowNumber = indexPath.row;
    [self performSegueWithIdentifier:@"predictionDetailSegue" sender:nil];
}


- (void) loadTips
{
    RKObjectMapping *tipsMapping = [RKObjectMapping mappingForClass:[Tip class]];
    
    
    
    [tipsMapping addAttributeMappingsFromArray:@[@"id", @"leagueType",
                                                 @"flagURL", @"homeTeam", @"awayTeam", @"isCompleted",
                                                 @"tipDetail", @"DateTimeCreated",
                                                 @"isPredictionVerified"]];
    
    RKResponseDescriptor *tipFetchingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tipsMapping method:RKRequestMethodGET pathPattern:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    
    [[RKObjectManager sharedManager] addResponseDescriptor:tipFetchingDescriptor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *authToken = [defaults objectForKey:KEY_USER_AUTH_TOKEN];
    NSString *email = [defaults objectForKey:KEY_USER_NAME];
    NSLog(@"%@", email);
    NSString *basicAuthString = [NSString stringWithFormat:@"Basic %@",authToken];
    
    NSDictionary *params = @{@"isPushed":@"True"};
    
    NSString *mytipsPath = [NSString stringWithFormat:@"api/user/%@/predictions/", [defaults objectForKey:KEY_USER_ID]];

    
    //Setting Content-Type: application/json Header, else the api throws 404 NOT Found Error
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_AUTHORIZATON value:basicAuthString];
    [[[RKObjectManager sharedManager] HTTPClient] setDefaultHeader:HEADER_CONTENT_TYPE value:RKMIMETypeJSON];
    //[[[RKObjectManager sharedManager] HTTPClient] setAuthorizationHeaderWithUsername:email password:pass];
    
    NSLog(@"Headers %@", [[[RKObjectManager sharedManager] HTTPClient] defaultHeaders]);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    [[RKObjectManager sharedManager] getObjectsAtPath:mytipsPath parameters:params
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  _tips = mappingResult.array;
                                                  [self.tableView reloadData];
                                                  
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"WTF");
                                              }];
    
    [[RKObjectManager sharedManager] removeResponseDescriptor:tipFetchingDescriptor];
}

@end