//
//  DropDownListView.m
//  KDropDownMultipleSelection
//
//  Created by macmini17 on 03/01/14.
//  Copyright (c) 2014 macmini17. All rights reserved.
//

#import "DropDownListView.h"
#import "DropDownViewCell.h"

#define DROPDOWNVIEW_SCREENINSET 0
#define DROPDOWNVIEW_HEADER_HEIGHT 0.
#define RADIUS .0f


@interface DropDownListView (private)
- (void)fadeIn;
- (void)fadeOut;
@end
@implementation DropDownListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions xy:(CGPoint)point size:(CGSize)size isMultiple:(BOOL)isMultiple
{
    self.isOpen = YES;
    isMultipleSelection=isMultiple;
    float height = MIN(size.height, DROPDOWNVIEW_HEADER_HEIGHT+[aOptions count]*44);
    CGRect rect = CGRectMake(point.x, point.y, size.width, height);
    if (self = [super initWithFrame:rect])
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowColor = [UIColor clearColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(2.5, 2.5);
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOpacity = 0.5f;
        
        _kTitleText = [aTitle copy];
        _kDropDownOption = [aOptions copy];
        self.arryData=[[NSMutableArray alloc]init];
        _kTableView = [[UITableView alloc] initWithFrame:CGRectMake(DROPDOWNVIEW_SCREENINSET,
                                                                   DROPDOWNVIEW_SCREENINSET + DROPDOWNVIEW_HEADER_HEIGHT,
                                                                   rect.size.width - 2 * DROPDOWNVIEW_SCREENINSET,
                                                                   rect.size.height - 2 * DROPDOWNVIEW_SCREENINSET - DROPDOWNVIEW_HEADER_HEIGHT - RADIUS)];
        _kTableView.separatorColor = [UIColor colorWithWhite:1 alpha:.2];
        _kTableView.separatorInset = UIEdgeInsetsZero;
        _kTableView.backgroundColor = [UIColor whiteColor];
        _kTableView.dataSource = self;
        _kTableView.delegate = self;
        [self addSubview:_kTableView];
        
        if (isMultipleSelection) {
            UIButton *btnDone=[UIButton  buttonWithType:UIButtonTypeCustom];
            [btnDone setFrame:CGRectMake(rect.origin.x+182,rect.origin.y-45, 82, 31)];
            [btnDone setImage:[UIImage imageNamed:@"done@2x.png"] forState:UIControlStateNormal];
            [btnDone addTarget:self action:@selector(Click_Done) forControlEvents: UIControlEventTouchUpInside];
            [self addSubview:btnDone];
        }

        
    }
    return self;
}
-(void)Click_Done{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(DropDownListView:Datalist:)]) {
        NSMutableArray *arryResponceData=[[NSMutableArray alloc]init];
        NSLog(@"%@",self.arryData);
        for (int k=0; k<self.arryData.count; k++) {
            NSIndexPath *path=[self.arryData objectAtIndex:k];
            [arryResponceData addObject:[_kDropDownOption objectAtIndex:path.row]];
            NSLog(@"pathRow=%d",path.row);
        }
    
        [self.delegate DropDownListView:self Datalist:arryResponceData];
        
    }
    // dismiss self
    [self fadeOut];
}
#pragma mark - Private Methods
- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}
- (void)fadeOut
{
    self.isOpen = NO;
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_kDropDownOption count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"DropDownViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    cell = [[DropDownViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    
    int row = [indexPath row];
    UIImageView *imgarrow=[[UIImageView alloc]init ];
    
    if([self.arryData containsObject:indexPath]){
        imgarrow.frame=CGRectMake(230,2, 27, 27);
        imgarrow.image=[UIImage imageNamed:@"check_mark@2x.png"];
	} else
        imgarrow.image=nil;
    
    [cell addSubview:imgarrow];
    cell.textLabel.text = [_kDropDownOption objectAtIndex:row] ;
    cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:13.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isMultipleSelection) {
        if([self.arryData containsObject:indexPath]){
            [self.arryData removeObject:indexPath];
        } else {
            [self.arryData addObject:indexPath];
        }
        [tableView reloadData];

    } else {
    
        if (self.delegate && [self.delegate respondsToSelector:@selector(DropDownListView:didSelectedIndex:array:)]) {
            [self.delegate DropDownListView:self didSelectedIndex:[indexPath row] array:_kDropDownOption];
        }
        // dismiss self
        [self fadeOut];
    }
	
}

#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // tell the delegate the cancellation
}

#pragma mark - DrawDrawDraw
- (void)drawRect:(CGRect)rect {
    CGRect bgRect = CGRectInset(rect, DROPDOWNVIEW_SCREENINSET, DROPDOWNVIEW_SCREENINSET);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw the background with shadow
    [[UIColor colorWithRed:R/255 green:G/255 blue:B/255 alpha:1.0f] setFill];
    
    float x = DROPDOWNVIEW_SCREENINSET;
    float y = DROPDOWNVIEW_SCREENINSET;
    float width = bgRect.size.width;
    float height = bgRect.size.height;
    CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, x, y + RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + width, y, x + width, y + RADIUS, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + width, y + height, x + width - RADIUS, y + height, RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y + height, x, y + height - RADIUS, RADIUS);
	CGPathCloseSubpath(path);
	CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    
    // Draw the title and the separator with shadow
//    CGContextSetShadowWithColor(ctx, CGSizeMake(1, 1), 0.5f, [UIColor blackColor].CGColor);
//    [[UIColor colorWithWhite:1 alpha:1.] setFill];
//    
//    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)) {
//        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
//        UIColor *cl=[UIColor blackColor];
//        
//        NSDictionary *attributes = @{ NSFontAttributeName: font,NSForegroundColorAttributeName:cl};
//        [_kTitleText drawInRect:titleRect withAttributes:attributes];
//    }
//    else
//        [_kTitleText drawInRect:titleRect withFont:[UIFont systemFontOfSize:16.]];
//    
//    CGContextFillRect(ctx, separatorRect);
}

-(void)SetBackGroundDropDown_R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alph {
    R=r;
    G=g;
    B=b;
    A=alph;
}

@end
