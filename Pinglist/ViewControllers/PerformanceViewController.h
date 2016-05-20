//
//  PerformanceViewController.h
//  Pinglist
//
//  Created by admin on 5/7/16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "BEMSimpleLineGraphView.h"

@interface PerformanceViewController : UIViewController <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    int                 previousStepperValue;
    int                 totalNumber;
    int                 selection;
    NSMutableArray      *incidents;
    NSString            *pagingUrl;
    UIRefreshControl    *refreshControl;
}

- (IBAction)onBack:(id)sender;
- (IBAction)onTrend:(id)sender;
- (IBAction)onIncident:(id)sender;
- (IBAction)onAllTime:(id)sender;
- (IBAction)on1Hour:(id)sender;
- (IBAction)on24Hour:(id)sender;
- (IBAction)on7Days:(id)sender;
- (IBAction)on30Days:(id)sender;
- (IBAction)onIncidentAllTime:(id)sender;
- (IBAction)onIncident1Hour:(id)sender;
- (IBAction)onIncident24Hour:(id)sender;
- (IBAction)onIncident7Day:(id)sender;
- (IBAction)onIncident30Day:(id)sender;
- (IBAction)onCloseDetails:(id)sender;

@property (strong, nonatomic) NSMutableArray        *arrayOfValues;
@property (strong, nonatomic) NSMutableArray        *arrayOfDates;
@property (nonatomic, strong) Alarm                 *alarm;

@property (weak, nonatomic) IBOutlet UIButton       *btnTrend;
@property (weak, nonatomic) IBOutlet UIButton       *btnIncident;
@property (weak, nonatomic) IBOutlet UIButton       *btnAllTime;
@property (weak, nonatomic) IBOutlet UIButton       *btn1Hour;
@property (weak, nonatomic) IBOutlet UIButton       *btn24Hours;
@property (weak, nonatomic) IBOutlet UIButton       *btn7Days;
@property (weak, nonatomic) IBOutlet UIButton       *btn30Days;
@property (weak, nonatomic) IBOutlet UIButton       *btnIncidentAllTime;
@property (weak, nonatomic) IBOutlet UIView         *vwIncidentDetails;
@property (weak, nonatomic) IBOutlet UIButton       *btnIncident1Hour;
@property (weak, nonatomic) IBOutlet UIButton       *btnIncident24Hour;
@property (weak, nonatomic) IBOutlet UIButton       *btnIncident7Day;
@property (weak, nonatomic) IBOutlet UIButton       *btnIncident30Day;

@property (weak, nonatomic) IBOutlet UILabel        *lblUrl;
@property (weak, nonatomic) IBOutlet UILabel        *lblUptime;
@property (weak, nonatomic) IBOutlet UILabel        *lblAvgTime;
@property (weak, nonatomic) IBOutlet UILabel        *lblDrops;
@property (weak, nonatomic) IBOutlet UILabel        *lblSlows;
@property (weak, nonatomic) IBOutlet UILabel        *lblType;
@property (weak, nonatomic) IBOutlet UILabel        *lblHttpCode;
@property (weak, nonatomic) IBOutlet UILabel        *lblOccurredAt;
@property (weak, nonatomic) IBOutlet UILabel        *lblResolvedAt;
@property (weak, nonatomic) IBOutlet UILabel        *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel        *lblPerformance;
@property (weak, nonatomic) IBOutlet UITextView     *txtViewResponse;

@property (weak, nonatomic) IBOutlet UIView         *vwTrend;
@property (weak, nonatomic) IBOutlet UIView         *vwIncident;

@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UILabel        *tabSelectionBar;
@property (weak, nonatomic) IBOutlet UILabel        *btnSelectionbar;
@property (weak, nonatomic) IBOutlet UILabel        *incidentSelectionBar;

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraph;

@end
