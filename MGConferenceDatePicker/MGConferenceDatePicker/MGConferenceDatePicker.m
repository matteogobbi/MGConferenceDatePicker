//
//  MGConferenceDatePicker.m
//  MGConferenceDatePicker
//
//  Created by Matteo Gobbi on 09/02/14.
//  Copyright (c) 2014 Matteo Gobbi. All rights reserved.
//

#import "MGConferenceDatePicker.h"
#import "MGConferenceDatePickerDelegate.h"

//Check screen macros
#define IS_WIDESCREEN (fabs ( (double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 )
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

//Editable macros
#define TEXT_COLOR [UIColor colorWithWhite:0.5 alpha:1.0]
#define SELECTED_TEXT_COLOR [UIColor whiteColor]
#define LINE_COLOR [UIColor colorWithWhite:0.80 alpha:1.0]
#define SAVE_AREA_COLOR [UIColor colorWithWhite:0.95 alpha:1.0]
#define BAR_SEL_COLOR [UIColor colorWithRed:76.0f/255.0f green:172.0f/255.0f blue:239.0f/255.0f alpha:0.8]

//Editable constants
static const float VALUE_HEIGHT = 65.0;
static const float SAVE_AREA_HEIGHT = 70.0;
static const float SAVE_AREA_MARGIN_TOP = 20.0;
static const float SV_MOMENTS_WIDTH = 100.0;
static const float SV_HOURS_WIDTH = 60.0;
static const float SV_MINUTES_WIDTH = 60.0;
static const float SV_MERIDIANS_WIDTH = 100.0;

//Editable values
float PICKER_HEIGHT = 300.0;
NSString *FONT_NAME = @"HelveticaNeue";
NSString *NOW = @"Now";

//Static macros and constants
#define SELECTOR_ORIGIN (PICKER_HEIGHT/2.0-VALUE_HEIGHT/2.0)
#define SAVE_AREA_ORIGIN_Y self.bounds.size.height-SAVE_AREA_HEIGHT
#define PICKER_ORIGIN_Y SAVE_AREA_ORIGIN_Y-SAVE_AREA_MARGIN_TOP-PICKER_HEIGHT
#define BAR_SEL_ORIGIN_Y PICKER_HEIGHT/2.0-VALUE_HEIGHT/2.0
static const NSInteger SCROLLVIEW_MOMENTS_TAG = 0;


//Custom UIButton
@implementation MGPickerButton

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTitleColor:BAR_SEL_COLOR forState:UIControlStateNormal];
        [self setTitleColor:SELECTED_TEXT_COLOR forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:18.0]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat outerMargin = 5.0f;
    CGRect outerRect = CGRectInset(self.bounds, outerMargin, outerMargin);
    CGFloat radius = 6.0;
    
    CGMutablePathRef outerPath = CGPathCreateMutable();
    CGPathMoveToPoint(outerPath, NULL, CGRectGetMidX(outerRect), CGRectGetMinY(outerRect));
    CGPathAddArcToPoint(outerPath, NULL, CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), radius);
    CGPathAddArcToPoint(outerPath, NULL, CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), radius);
    CGPathAddArcToPoint(outerPath, NULL, CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), radius);
    CGPathAddArcToPoint(outerPath, NULL, CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), radius);
    CGPathCloseSubpath(outerPath);
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, (self.state != UIControlStateHighlighted) ? BAR_SEL_COLOR.CGColor : SELECTED_TEXT_COLOR.CGColor);
    CGContextAddPath(context, outerPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
}

@end


//Custom scrollView
@interface MGPickerScrollView ()

@property (nonatomic, strong) NSArray *arrValues;
@property (nonatomic, strong) UIFont *cellFont;

@end


@implementation MGPickerScrollView

//Constants
const float LBL_BORDER_OFFSET = 8.0;

//Configure the tableView
- (id)initWithFrame:(CGRect)frame andValues:(NSArray *)arrayValues
      withTextAlign:(NSTextAlignment)align andTextSize:(float)txtSize {
    
    if(self = [super initWithFrame:frame]) {
        [self setScrollEnabled:YES];
        [self setShowsVerticalScrollIndicator:NO];
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setContentInset:UIEdgeInsetsMake(BAR_SEL_ORIGIN_Y, 0.0, BAR_SEL_ORIGIN_Y, 0.0)];
        
        _cellFont = [UIFont fontWithName:FONT_NAME size:txtSize];
        
        if(arrayValues)
            _arrValues = [arrayValues copy];
    }
    return self;
}


//Dehighlight the last cell
- (void)dehighlightLastCell {
    NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_tagLastSelected inSection:0], nil];
    [self setTagLastSelected:-1];
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
}

//Highlight a cell
- (void)highlightCellWithIndexPathRow:(NSUInteger)indexPathRow {
    [self setTagLastSelected:indexPathRow];
    NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_tagLastSelected inSection:0], nil];
    [self beginUpdates];
    [self reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
}

@end


//Custom Data Picker
@interface MGConferenceDatePicker ()

@property (nonatomic, strong) NSArray *arrMoments;
@property (nonatomic, strong) NSArray *arrHours;
@property (nonatomic, strong) NSArray *arrMinutes;
@property (nonatomic, strong) NSArray *arrMeridians;
@property (nonatomic, strong) NSArray *arrTimes;

@property (nonatomic, strong) MGPickerScrollView *svMoments;
@property (nonatomic, strong) MGPickerScrollView *svHours;
@property (nonatomic, strong) MGPickerScrollView *svMins;
@property (nonatomic, strong) MGPickerScrollView *svMeridians;

@property (nonatomic, strong) UILabel *lblDayMonth;
@property (nonatomic, strong) UILabel *lblWeekDay;
@property (nonatomic, strong) UIButton *btPrev;
@property (nonatomic, strong) UIButton *btNext;
@property (nonatomic, strong) MGPickerButton *saveButton;

@end


@implementation MGConferenceDatePicker

-(void)drawRect:(CGRect)rect {
    [self initialize];
    [self buildControl];
}

- (void)initialize {
    //Set the height of picker if isn't an iPhone 5 or 5s
    [self checkScreenSize];
    
    //Create array Moments and create the dictionary MOMENT -> TIME
    _arrMoments = @[@"Now",
                    @"Morning",
                    @"Lunchtime",
                    @"Afternoon",
                    @"Evening",
                    @"Dinnertime",
                    @"Night"];
    
    _arrTimes = @[NOW,
                  @"10:00 AM",
                  @"1:00 PM",
                  @"4:30 PM",
                  @"7:00 PM",
                  @"8:30 PM",
                  @"1:00 AM",
                  ];
    
    //Create array Meridians
    _arrMeridians = @[@"AM", @"PM"];
    
    //Create array Hours
    NSMutableArray *arrHours = [[NSMutableArray alloc] initWithCapacity:12];
    for(int i=1; i<=12; i++) {
        [arrHours addObject:[NSString stringWithFormat:@"%@%d",(i<10) ? @"0":@"", i]];
    }
    _arrHours = [NSArray arrayWithArray:arrHours];
    
    //Create array Minutes
    NSMutableArray *arrMinutes = [[NSMutableArray alloc] initWithCapacity:60];
    for(int i=0; i<60; i++) {
        [arrMinutes addObject:[NSString stringWithFormat:@"%@%d",(i<10) ? @"0":@"", i]];
    }
    _arrMinutes = [NSArray arrayWithArray:arrMinutes];
    
    //Set the acutal date
    _selectedDate = [NSDate date];
}


- (void)buildControl {
    //Create a view as base of the picker
    UIView *pickerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, PICKER_ORIGIN_Y, self.frame.size.width, PICKER_HEIGHT)];
    [pickerView setBackgroundColor:self.backgroundColor];
    
    //Create bar selector
    UIView *barSel = [[UIView alloc] initWithFrame:CGRectMake(0.0, BAR_SEL_ORIGIN_Y, self.frame.size.width, VALUE_HEIGHT)];
    [barSel setBackgroundColor:BAR_SEL_COLOR];
    
    
    //Create the first column (moments) of the picker
    _svMoments = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, SV_MOMENTS_WIDTH, PICKER_HEIGHT) andValues:_arrMoments withTextAlign:NSTextAlignmentRight andTextSize:14.0];
    _svMoments.tag = 0;
    [_svMoments setDelegate:self];
    [_svMoments setDataSource:self];
    
    //Create the second column (hours) of the picker
    _svHours = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(SV_MOMENTS_WIDTH, 0.0, SV_HOURS_WIDTH, PICKER_HEIGHT) andValues:_arrHours withTextAlign:NSTextAlignmentCenter  andTextSize:25.0];
    _svHours.tag = 1;
    [_svHours setDelegate:self];
    [_svHours setDataSource:self];
    
    //Create the third column (minutes) of the picker
    _svMins = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(_svHours.frame.origin.x+SV_HOURS_WIDTH, 0.0, SV_MINUTES_WIDTH, PICKER_HEIGHT) andValues:_arrMinutes withTextAlign:NSTextAlignmentCenter andTextSize:25.0];
    _svMins.tag = 2;
    [_svMins setDelegate:self];
    [_svMins setDataSource:self];
    
    //Create the fourth column (meridians) of the picker
    _svMeridians = [[MGPickerScrollView alloc] initWithFrame:CGRectMake(_svMins.frame.origin.x+SV_MINUTES_WIDTH, 0.0, SV_MERIDIANS_WIDTH, PICKER_HEIGHT) andValues:_arrMeridians withTextAlign:NSTextAlignmentLeft andTextSize:14.0];
    _svMeridians.tag = 3;
    [_svMeridians setDelegate:self];
    [_svMeridians setDataSource:self];
    
    
    //Create separators lines
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(SV_MOMENTS_WIDTH-1.0, 0.0, 2.0, PICKER_HEIGHT)];
    [line setBackgroundColor:LINE_COLOR];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(_svHours.frame.origin.x+SV_HOURS_WIDTH-1.0, 0.0, 2.0, PICKER_HEIGHT)];
    [line2 setBackgroundColor:LINE_COLOR];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(_svMins.frame.origin.x+SV_MINUTES_WIDTH-1.0, 0.0, 2.0, PICKER_HEIGHT)];
    [line3 setBackgroundColor:LINE_COLOR];
    
    
    //Layer gradient
    CAGradientLayer *gradientLayerTop = [CAGradientLayer layer];
    gradientLayerTop.frame = CGRectMake(0.0, 0.0, pickerView.frame.size.width, PICKER_HEIGHT/2.0);
    gradientLayerTop.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, (id)self.backgroundColor.CGColor, nil];
    gradientLayerTop.startPoint = CGPointMake(0.0f, 0.7f);
    gradientLayerTop.endPoint = CGPointMake(0.0f, 0.0f);
    
    CAGradientLayer *gradientLayerBottom = [CAGradientLayer layer];
    gradientLayerBottom.frame = CGRectMake(0.0, PICKER_HEIGHT/2.0, pickerView.frame.size.width, PICKER_HEIGHT/2.0);
    gradientLayerBottom.colors = gradientLayerTop.colors;
    gradientLayerBottom.startPoint = CGPointMake(0.0f, 0.3f);
    gradientLayerBottom.endPoint = CGPointMake(0.0f, 1.0f);
    
    
    //Create save area
    UIView *saveArea = [[UIView alloc] initWithFrame:CGRectMake(0.0, SAVE_AREA_ORIGIN_Y, self.frame.size.width, SAVE_AREA_HEIGHT)];
    [saveArea setBackgroundColor:SAVE_AREA_COLOR];
    
    
    //Create save button
    _saveButton = [[MGPickerButton alloc] initWithFrame:CGRectMake(10.0, 10.0, self.frame.size.width-20.0, SAVE_AREA_HEIGHT-20.0)];
    [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //Create week day
    _lblWeekDay = [[UILabel alloc] initWithFrame:CGRectMake(60.0, PICKER_ORIGIN_Y-60.0, 200.0, 44.0)];
    //[_lblWeekDay setBackgroundColor:[UIColor redColor]];
    [_lblWeekDay setText:@"Wednesday"];
    [_lblWeekDay setTextAlignment:NSTextAlignmentCenter];
    [_lblWeekDay setFont:[UIFont fontWithName:FONT_NAME size:25.0]];
    [_lblWeekDay setTextColor:BAR_SEL_COLOR];
    [self addSubview:_lblWeekDay];
    
    //Create field day and month
    _lblDayMonth = [[UILabel alloc] initWithFrame:CGRectMake(60.0, _lblWeekDay.frame.origin.y-30.0, 200.0, 30.0)];
    //[_lblDayMonth setBackgroundColor:[UIColor redColor]];
    [_lblDayMonth setText:@"23 December 2013"];
    [_lblDayMonth setTextAlignment:NSTextAlignmentCenter];
    [_lblDayMonth setFont:[UIFont fontWithName:FONT_NAME size:16.0]];
    [_lblDayMonth setTextColor:TEXT_COLOR];
    [self addSubview:_lblDayMonth];
    
    //Create arrow next/previous
    _btPrev = [[UIButton alloc] initWithFrame:CGRectMake(40.0, _lblWeekDay.frame.origin.y+_lblWeekDay.frame.size.height/2-15.0, 30.0, 30.0)];
    [_btPrev setImage:[UIImage imageNamed:@"left_date_arrow_blue"] forState:UIControlStateNormal];
    _btPrev.contentMode = UIViewContentModeCenter;
    [_btPrev setTitleColor:BAR_SEL_COLOR forState:UIControlStateNormal];
    [_btPrev addTarget:self action:@selector(switchToDayPrev) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btPrev];
    
    _btNext = [[UIButton alloc] initWithFrame:CGRectMake(250.0, _lblWeekDay.frame.origin.y+_lblWeekDay.frame.size.height/2-15.0, 30.0, 30.0)];
    [_btNext setImage:[UIImage imageNamed:@"right_date_arrow_blue"] forState:UIControlStateNormal];
    _btNext.contentMode = UIViewContentModeCenter;
    [_btNext setTitleColor:BAR_SEL_COLOR forState:UIControlStateNormal];
    [_btNext addTarget:self action:@selector(switchToDayNext) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btNext];
    
    
    //Add pickerView
    [self addSubview:pickerView];
    
    //Add separator lines
    [pickerView addSubview:line];
    [pickerView addSubview:line2];
    [pickerView addSubview:line3];
    
    //Add the bar selector
    [pickerView addSubview:barSel];
    
    //Add scrollViews
    [pickerView addSubview:_svMoments];
    [pickerView addSubview:_svHours];
    [pickerView addSubview:_svMins];
    [pickerView addSubview:_svMeridians];
    
    //Add gradients
    [pickerView.layer addSublayer:gradientLayerTop];
    [pickerView.layer addSublayer:gradientLayerBottom];
    
    //Add Savearea
    [self addSubview:saveArea];
    
    //Add button save
    [saveArea addSubview:_saveButton];
    
    //Set the time to now
    [self setTime:NOW];
    [self switchToDay:0];
    [_btPrev setEnabled:NO];
}



#pragma mark - Other methods

//Save button pressed
- (void)saveButtonPressed:(id)sender {
    //Create date
    NSDate *date = [self createDateWithFormat:@"dd-MM-yyyy hh:mm:ss a" andDateString:@"%@ %@:%@:00 %@"];
    
    //Send the date to the delegate
    if([_delegate respondsToSelector:@selector(conferenceDatePicker:saveDate:)])
        [_delegate conferenceDatePicker:self saveDate:date];
}

//Center the value in the bar selector
- (void)centerValueForScrollView:(MGPickerScrollView *)scrollView {
    
    //Takes the actual offset
    float offset = scrollView.contentOffset.y;
    
    //Removes the contentInset and calculates the prcise value to center the nearest cell
    offset += scrollView.contentInset.top;
    int mod = (int)offset%(int)VALUE_HEIGHT;
    float newValue = (mod >= VALUE_HEIGHT/2.0) ? offset+(VALUE_HEIGHT-mod) : offset-mod;
    
    //Calculates the indexPath of the cell and set it in the object as property
    NSInteger indexPathRow = (int)(newValue/VALUE_HEIGHT);
    
    //Center the cell
    [self centerCellWithIndexPathRow:indexPathRow forScrollView:scrollView];
}

//Center phisically the cell
- (void)centerCellWithIndexPathRow:(NSUInteger)indexPathRow forScrollView:(MGPickerScrollView *)scrollView {
    
    if(indexPathRow >= [scrollView.arrValues count]) {
        indexPathRow = [scrollView.arrValues count]-1;
    }
    
    float newOffset = indexPathRow*VALUE_HEIGHT;
    
    //Re-add the contentInset and set the new offset
    newOffset -= BAR_SEL_ORIGIN_Y;
    [scrollView setContentOffset:CGPointMake(0.0, newOffset) animated:YES];
    
    //Highlight the cell
    [scrollView highlightCellWithIndexPathRow:indexPathRow];
    
    //Automatic setting of the time
    if(scrollView == _svMoments) {
        [self setTime:_arrTimes[indexPathRow]];
    }
    
    [_saveButton setEnabled:YES];
}

//Return a date from a string
- (NSDate *)createDateWithFormat:(NSString *)format andDateString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:locale];
    formatter.dateFormat = format;
    return [formatter dateFromString:
            [NSString stringWithFormat:dateString,
             [self stringFromDate:_selectedDate withFormat:@"dd-MM-yyyy"],
             _arrHours[_svHours.tagLastSelected],
             _arrMinutes[_svMins.tagLastSelected],
             _arrMeridians[_svMeridians.tagLastSelected]]];
}


//Return a string from a date
- (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:locale];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}

//Set the time automatically
- (void)setTime:(NSString *)time {
    //Get the string
    NSString *strTime;
    if([time isEqualToString:NOW])
        strTime = [self stringFromDate:[NSDate date] withFormat:@"hh:mm a"];
    else
        strTime = (NSString *)time;
    
    //Split
    NSArray *comp = [strTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" :"]];
    
    //Set the tableViews
    [_svHours dehighlightLastCell];
    [_svMins dehighlightLastCell];
    [_svMeridians dehighlightLastCell];
    
    //Center the other fields
    [self centerCellWithIndexPathRow:([comp[0] intValue]%12)-1 forScrollView:_svHours];
    [self centerCellWithIndexPathRow:[comp[1] intValue] forScrollView:_svMins];
    [self centerCellWithIndexPathRow:[_arrMeridians indexOfObject:comp[2]] forScrollView:_svMeridians];
}

//Switch to the previous or next day
- (void)switchToDay:(NSInteger)dayOffset {
    //Calculate and save the new date
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [NSDateComponents new];
    
    //Set the offset
    [offsetComponents setDay:dayOffset];
    
    NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:_selectedDate options:0];
    _selectedDate = newDate;
    
    //Show new date
    [_lblWeekDay setText:[self stringFromDate:_selectedDate withFormat:@"EEEE"]];
    [_lblDayMonth setText:[self stringFromDate:_selectedDate withFormat:@"dd LLLL yyyy"]];
}

- (void)switchToDayPrev {
    //Check if the again previous day is a past day and in this case i disable the button
    //Calculate the new date
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [NSDateComponents new];
    
    //Set the offset
    [offsetComponents setDay:-2];
    NSDate *newDate = [gregorian dateByAddingComponents:offsetComponents toDate:_selectedDate options:0];
    
    //If newDate is in the past
    if([newDate compare:[NSDate date]] == NSOrderedAscending) {
        //Disable button previus day
        [_btPrev setEnabled:NO];
    }
    
    [self switchToDay:-1];
}

- (void)switchToDayNext {
    if(![_btPrev isEnabled]) [_btPrev setEnabled:YES];
    
    [self switchToDay:1];
}

//Check the screen size
- (void)checkScreenSize {
    if(IS_WIDESCREEN) {
        PICKER_HEIGHT = 300.0;
    } else {
        PICKER_HEIGHT = 212.0;
    }
}

- (void)setSelectedDate:(NSDate *)date {
    _selectedDate = date;
    [self switchToDay:0];
    
    NSString *strTime = [self stringFromDate:date withFormat:@"hh:mm a"];
    [self setTime:strTime];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![scrollView isDragging]) {
        [self centerValueForScrollView:(MGPickerScrollView *)scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self centerValueForScrollView:(MGPickerScrollView *)scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [_saveButton setEnabled:NO];
    
    MGPickerScrollView *sv = (MGPickerScrollView *)scrollView;
    
    [sv dehighlightLastCell];
}

#pragma - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MGPickerScrollView *sv = (MGPickerScrollView *)tableView;
    return [sv.arrValues count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"reusableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    MGPickerScrollView *sv = (MGPickerScrollView *)tableView;
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setFont:sv.cellFont];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    [cell.textLabel setTextColor:(indexPath.row == sv.tagLastSelected) ? SELECTED_TEXT_COLOR : TEXT_COLOR];
    [cell.textLabel setText:sv.arrValues[indexPath.row]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return VALUE_HEIGHT;
}

@end
