//
//  PerformanceViewController.m
//  Pinglist
//
//  Created by admin on 5/7/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PerformanceViewController.h"

@interface PerformanceViewController ()

@end

@implementation PerformanceViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (NSString *)labelForDateAtIndex:(NSInteger)index {
    NSDate *date        =   self.arrayOfDates[index];
    NSDateFormatter *df =   [[NSDateFormatter alloc] init];
    
    switch (selection) {
        case 1:
            df.dateFormat   =   @"HH:mm";
            break;
            
        case 24:
            df.dateFormat   =   @"HH:mm";
            break;
            
        case 7:
            df.dateFormat   =   @"MM/dd";
            break;
            
        case 30:
            df.dateFormat   =   @"MM/dd";
            break;
            
        case 99:
            df.dateFormat   =   @"HH:mm";
            break;
            
        default:
            break;
    }
    
    NSString *label     =   [df stringFromDate:date];
    return label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.btnTrend.titleLabel.font   =   [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    self.btnIncident.titleLabel.font   =   [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    
    self.btnIncident1Hour.titleLabel.font   =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.btnIncident24Hour.titleLabel.font   =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.btnIncident30Day.titleLabel.font   =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.btnIncident7Day.titleLabel.font   =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.btnIncidentAllTime.titleLabel.font   =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    
    self.lblType.font           =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.lblHttpCode.font       =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.lblOccurredAt.font     =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.lblResolvedAt.font     =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.lblMessage.font        =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.txtViewResponse.font   =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    
    self.btnAllTime.titleLabel.font     =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.btn1Hour.titleLabel.font       =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.btn24Hours.titleLabel.font     =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.btn7Days.titleLabel.font       =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.btn30Days.titleLabel.font      =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    
    self.lblAvgTime.font    =   [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    self.lblDrops.font      =   [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    self.lblSlows.font      =   [UIFont fontWithName:@"Lato-Regular" size:14.0f];
    self.lblUptime.font     =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    self.lblUrl.font        =   [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    
    self.lblUrl.text        =   self.alarm.endpoint_url;
    self.arrayOfValues      =   [[NSMutableArray alloc] init];
    self.arrayOfDates       =   [[NSMutableArray alloc] init];
    incidents               =   [[NSMutableArray alloc] init];
    selection               =   1;
    
    //Pull to refresh
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:refreshControl];

    //Initialize graph & load performance data
    [self initGraph];

}

- (void)initGraph {
    if ([Global sharedInstance].credential.isExpired) {
        [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
            [self initGraph];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
    
    else {
        NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/alarms/%d/response-times?limit=100", endpointURL, self.alarm.ID];
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
        [[Global afManager] GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            NSString *symbol = @"%";
            self.lblUptime.text     =   [NSString stringWithFormat:@"uptime: %.2f%@",[responseObject[@"uptime"] floatValue], symbol];
            self.lblAvgTime.text    =   [NSString stringWithFormat:@"%.0f ms", [responseObject[@"average"] floatValue] / 1000000];
            self.lblDrops.text      =   [responseObject[@"incident_type_counts"][@"timeout"] stringValue];
            self.lblSlows.text      =   [responseObject[@"incident_type_counts"][@"slow"] stringValue];
            
            //Loading graphc data
            NSArray *array  =   responseObject[@"_embedded"][@"response_times"];
            for (int i = 0; i < array.count; i ++) {
                [self.arrayOfValues addObject:@([array[i][@"value"] longLongValue] / 1000000)];
                [self.arrayOfDates addObject:[self getDate:array[i][@"timestamp"]]];
            }
            
            //Drawing Graph
            [self setupGraph];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
            [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
        }];
    }
}

- (void)refresh {
    NSString    *requestURL     =   [NSString stringWithFormat:@"%@/v1/alarms/%d/incidents?order_by=id desc",endpointURL, self.alarm.ID];
    [self loadIncidents:requestURL];
}

- (void)setupGraph {
    self.myGraph.dataSource =   self;
    self.myGraph.delegate   =   self;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    self.myGraph.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Enable and disable various graph properties and axis displays
    self.myGraph.enableTouchReport = YES;
    self.myGraph.enablePopUpReport = YES;
    self.myGraph.enableYAxisLabel = YES;
    self.myGraph.autoScaleYAxis = YES;
    self.myGraph.alwaysDisplayDots = NO;
    self.myGraph.enableReferenceXAxisLines = YES;
    self.myGraph.enableReferenceYAxisLines = YES;
    self.myGraph.enableReferenceAxisFrame = YES;
    
    // Draw an average line
    self.myGraph.averageLine.enableAverageLine = YES;
    self.myGraph.averageLine.alpha = 0.6;
    self.myGraph.averageLine.color = [UIColor darkGrayColor];
    self.myGraph.averageLine.width = 2.5;
    self.myGraph.averageLine.dashPattern = @[@(2),@(2)];
    
    // Set the graph's animation style to draw, fade, or none
    self.myGraph.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    self.myGraph.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    self.myGraph.formatStringForValues = @"%.1f";
    
    [self.myGraph reloadGraph];
}

- (void)resetTabSelection {
    [self.btnTrend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnIncident setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)resetTimeSelection {
    [self.btnAllTime setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn1Hour setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn24Hours setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn7Days setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn30Days setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)resetIncidentSelection {
    [self.btnIncidentAllTime setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnIncident1Hour setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnIncident24Hour setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnIncident7Day setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnIncident30Day setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (NSDate *)getDate :(NSString *)str {
    NSDateFormatter *dateFormatter  =   [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    return [dateFormatter dateFromString:str];
}

- (NSString *)getFormattedString :(int)seconds {
    NSDateFormatter *dateFormatter  =   [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone            =   [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:timeZone];
    NSString *from  =   [dateFormatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:seconds]];
    return from;
}

- (NSString *)getConvertedString :(NSString *)str {
    NSDateFormatter *formatter1  =  [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate          *date        =  [formatter1 dateFromString:str];
    
    NSDateFormatter *formatter2  =  [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    NSString        *final       =  [formatter2 stringFromDate:date];
    
    return final;
}

- (NSString *)getConvertedStringForIncidentDetails :(NSString *)str {
    NSDateFormatter *formatter1  =  [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate          *date        =  [formatter1 dateFromString:str];
    
    NSDateFormatter *formatter2  =  [[NSDateFormatter alloc] init];
    [formatter2 setDateFormat:@"dd.MM.yyyy [HH:mm:ss]"];
    NSString        *final       =  [formatter2 stringFromDate:date];
    
    return final;
}

- (void)loadMetricsData :(NSString *)requestURL {
    if ([Global sharedInstance].credential.isExpired) {
        [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
            [self loadMetricsData:requestURL];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
    
    else {
        [self.arrayOfValues removeAllObjects];
        [self.arrayOfDates removeAllObjects];
        
        NSString *encodedURL    =  [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
        
        [[Global afManager] GET:encodedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            NSArray *array  =   responseObject[@"_embedded"][@"response_times"];
            
            if (array.count == 0 || array.count == 1) {
                [Global showAlert:@"No metrics data" sender:self];
            }
            
            for (int i = 0; i < array.count; i ++) {
                [self.arrayOfValues addObject:@([array[i][@"value"] intValue] / 1000000)];
                [self.arrayOfDates addObject:[self getDate:array[i][@"timestamp"]]];
            }
            
            [self.myGraph reloadGraph];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary    *respone  =   [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&error];
            [SVProgressHUD showErrorWithStatus:respone[@"error"] maskType:SVProgressHUDMaskTypeClear];
        }];
    }
}

- (void)loadIncidents :(NSString *)requestURL {
    if ([Global sharedInstance].credential.isExpired) {
        [Global refreshAccessToken:^(NSString *accessTok, NSString *refreshTok) {
            [self loadIncidents:requestURL];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.description);
        }];
    }
    
    else {
        NSString *encodedURL    =  [requestURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        [[Global afManager] GET:encodedURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            NSArray *array  =   responseObject[@"_embedded"][@"incidents"];
            pagingUrl       =   responseObject[@"_links"][@"next"][@"href"];
            
            if (array.count == 0) {
                [Global showAlert:@"No incidents data" sender:self];
            }
            
            for (int i = 0; i < array.count; i ++) {
                Incident *inc    =   [[Incident alloc] initWithData:array[i]];
                [incidents addObject:inc];
            }
            
            [self.tableView reloadData];
            
            self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 104 * incidents.count);
            if (self.tableView.frame.size.height < self.scrollView.frame.size.height) {
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 50);
            }
            else
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 104 * incidents.count);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", operation.responseString);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Trend Actions

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onTrend:(id)sender {
    [self resetTabSelection];
    self.tabSelectionBar.frame = CGRectMake(self.tabSelectionBar.frame.origin.x, self.tabSelectionBar.frame.origin.y, self.btnTrend.frame.size.width - 10, self.tabSelectionBar.frame.size.height);
    self.tabSelectionBar.backgroundColor    =   GREEN_COLOR;
    self.lblPerformance.textColor           =   GREEN_COLOR;
    [self.btnTrend setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    
    [UIView animateWithDuration:.3f animations:^{
        self.tabSelectionBar.center = CGPointMake(self.btnTrend.center.x, self.tabSelectionBar.center.y);
    }];
    
    self.vwIncident.hidden          =   YES;
    self.vwIncidentDetails.hidden   =   YES;
}

- (IBAction)onAllTime:(id)sender {
    self.lblPerformance.textColor   =   GREEN_COLOR;
    selection                       =   99;
    [self resetTimeSelection];
    
    NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/alarms/%d/response-times?limit=100&order_by=timestamp desc", endpointURL, self.alarm.ID];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [self loadMetricsData:requestURL];
    
    [UIView animateWithDuration:.3f animations:^{
        self.btnSelectionbar.center = CGPointMake(self.btnAllTime.center.x, self.btnSelectionbar.center.y);
    } completion:^(BOOL finished) {
        [self.btnAllTime setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    }];
}

- (IBAction)on1Hour:(id)sender {
    [self resetTimeSelection];
    selection               =   1;
    NSString *from          =   [self getFormattedString:-3600];
    NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/alarms/%d/response-times?limit=100&from=%@&order_by=timestamp desc", endpointURL, self.alarm.ID, from];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [self loadMetricsData:requestURL];
    
    [UIView animateWithDuration:.3f animations:^{
        self.btnSelectionbar.center = CGPointMake(self.btn1Hour.center.x, self.btnSelectionbar.center.y);
    } completion:^(BOOL finished) {
        [self.btn1Hour setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    }];
}

- (IBAction)on24Hour:(id)sender {
    [self resetTimeSelection];
    selection               =   24;
    NSString *from          =   [self getFormattedString:-3600*24];
    NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/alarms/%d/response-times?limit=100&date_trunc=hour&from=%@&order_by=timestamp desc", endpointURL, self.alarm.ID, from];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [self loadMetricsData:requestURL];
    
    [UIView animateWithDuration:.3f animations:^{
        self.btnSelectionbar.center = CGPointMake(self.btn24Hours.center.x, self.btnSelectionbar.center.y);
    } completion:^(BOOL finished) {
        [self.btn24Hours setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    }];
}

- (IBAction)on7Days:(id)sender {
    [self resetTimeSelection];
    selection               =   7;
    NSString *from          =   [self getFormattedString:-3600*24*7];
    NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/alarms/%d/response-times?limit=100&date_trunc=day&from=%@&order_by=timestamp desc", endpointURL, self.alarm.ID, from];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [self loadMetricsData:requestURL];
    
    [UIView animateWithDuration:.3f animations:^{
        self.btnSelectionbar.center = CGPointMake(self.btn7Days.center.x, self.btnSelectionbar.center.y);
    } completion:^(BOOL finished) {
        [self.btn7Days setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    }];
}

- (IBAction)on30Days:(id)sender {
    [self resetTimeSelection];
    selection               =   30;
    NSString *from          =   [self getFormattedString:-3600*24*30];
    NSString *requestURL    =   [NSString stringWithFormat:@"%@/v1/alarms/%d/response-times?limit=100&date_trunc=day&from=%@", endpointURL, self.alarm.ID, from];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [self loadMetricsData:requestURL];
    
    [UIView animateWithDuration:.3f animations:^{
        self.btnSelectionbar.center = CGPointMake(self.btn30Days.center.x, self.btnSelectionbar.center.y);
    } completion:^(BOOL finished) {
        [self.btn30Days setTitleColor:GREEN_COLOR forState:UIControlStateNormal];
    }];
}

#pragma mark - Incidents Actions

- (IBAction)onIncident:(id)sender {
    self.lblPerformance.textColor   =   RED_COLOR;
    self.vwIncident.hidden          =   NO;
    self.vwIncidentDetails.hidden   =   YES;
    NSString    *requestURL         =   [NSString stringWithFormat:@"%@/v1/alarms/%d/incidents?order_by=id desc",
                                         endpointURL, self.alarm.ID];
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [self loadIncidents:requestURL];
    [self resetTabSelection];
    
    self.tabSelectionBar.frame = CGRectMake(0, self.tabSelectionBar.frame.origin.y, self.btnIncident.frame.size.width - 6, self.tabSelectionBar.frame.size.height);
    self.tabSelectionBar.backgroundColor    =   RED_COLOR;
    
    [self.btnIncident setTitleColor:RED_COLOR forState:UIControlStateNormal];
    
    [UIView animateWithDuration:.3f animations:^{
        self.tabSelectionBar.center = CGPointMake(self.btnIncident.center.x, self.tabSelectionBar.center.y);
    }];
}

- (IBAction)onIncidentAllTime:(id)sender {
    NSString    *requestURL     =   [NSString stringWithFormat:@"%@/v1/alarms/%d/incidents?order_by=id desc",endpointURL, self.alarm.ID];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [incidents removeAllObjects];
    [self loadIncidents:requestURL];
    [self resetIncidentSelection];
    
    [self.btnIncidentAllTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:.3f animations:^{
        self.incidentSelectionBar.center    =   CGPointMake(self.btnIncidentAllTime.center.x, self.incidentSelectionBar.center.y);
    }];
}

- (IBAction)onIncident1Hour:(id)sender {
    NSString *from              =   [self getFormattedString:-3600];
    NSString    *requestURL     =   [NSString stringWithFormat:@"%@/v1/alarms/%d/incidents?from=%@&order_by=id desc",endpointURL, self.alarm.ID, from];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [incidents removeAllObjects];
    [self loadIncidents:requestURL];
    [self resetIncidentSelection];
    
    [self.btnIncident1Hour setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:.3f animations:^{
        self.incidentSelectionBar.center    =   CGPointMake(self.btnIncident1Hour.center.x, self.incidentSelectionBar.center.y);
    }];
}

- (IBAction)onIncident24Hour:(id)sender {
    NSString *from              =   [self getFormattedString:-3600 * 24];
    NSString    *requestURL     =   [NSString stringWithFormat:@"%@/v1/alarms/%d/incidents?from=%@&order_by=id desc", endpointURL,self.alarm.ID, from];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [incidents removeAllObjects];
    [self loadIncidents:requestURL];
    [self resetIncidentSelection];
    
    [self.btnIncident24Hour setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:.3f animations:^{
        self.incidentSelectionBar.center    =   CGPointMake(self.btnIncident24Hour.center.x, self.incidentSelectionBar.center.y);
    }];
}

- (IBAction)onIncident7Day:(id)sender {
    NSString *from              =   [self getFormattedString:-3600 * 24 * 7];
    NSString    *requestURL     =   [NSString stringWithFormat:@"%@/v1/alarms/%d/incidents?from=%@&order_by=id desc",endpointURL, self.alarm.ID, from];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [incidents removeAllObjects];
    [self loadIncidents:requestURL];
    [self resetIncidentSelection];
    
    [self.btnIncident7Day setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:.3f animations:^{
        self.incidentSelectionBar.center    =   CGPointMake(self.btnIncident7Day.center.x, self.incidentSelectionBar.center.y);
    }];
}

- (IBAction)onIncident30Day:(id)sender {
    NSString *from              =   [self getFormattedString:-3600 * 24 * 30];
    NSString    *requestURL     =   [NSString stringWithFormat:@"%@/v1/alarms/%d/incidents?from=%@&order_by=id desc",endpointURL, self.alarm.ID, from];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [incidents removeAllObjects];
    [self loadIncidents:requestURL];
    [self resetIncidentSelection];
    
    [self.btnIncident30Day setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:.3f animations:^{
        self.incidentSelectionBar.center    =   CGPointMake(self.btnIncident30Day.center.x, self.incidentSelectionBar.center.y);
    }];
}

- (IBAction)onCloseDetails:(id)sender {
    self.vwIncidentDetails.hidden = YES;
}

#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[self.arrayOfValues count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[self.arrayOfValues objectAtIndex:index] doubleValue];
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 2;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    
    NSString *label = [self labelForDateAtIndex:index];
    return [label stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return incidents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IncidentTableViewCell *cell =   (IncidentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"incident"];
    Incident *incident          =   incidents[indexPath.row];
    
    cell.lblType.text           =   incident.type;
    cell.lblOccurred.text       =   [self getConvertedString:incident.created_at];
    cell.lblResolvedAt.text     =   [self getConvertedString:incident.resolved_at];
    cell.btnView.tag            =   indexPath.row;
    cell.selectionStyle         =   UITableViewCellSelectionStyleNone;
    
    [cell.btnView addTarget:self action:@selector(onViewIncident:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)onViewIncident :(id)sender {
    self.vwIncidentDetails.hidden   =   NO;
    
    Incident *incident          =   incidents[[sender tag]];
    self.lblType.text           =   incident.type;
    self.lblHttpCode.text       =   [NSString stringWithFormat:@"%d", incident.http_code];
    self.lblOccurredAt.text     =   [self getConvertedStringForIncidentDetails:incident.created_at];
    self.lblResolvedAt.text     =   [self getConvertedStringForIncidentDetails:incident.resolved_at];
    self.lblMessage.text        =   incident.error_message;
    self.txtViewResponse.text   =   incident.response;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    float y         =   self.scrollView.contentOffset.y;
    float offset    =   self.scrollView.contentSize.height - self.scrollView.frame.size.height;
    
    if (y >= offset) {
        if (![pagingUrl isEqualToString:@""]) {
            [SVProgressHUD showWithStatus:@"Load more" maskType:SVProgressHUDMaskTypeClear];
            [self loadIncidents:pagingUrl];
        }
    }
}

@end
