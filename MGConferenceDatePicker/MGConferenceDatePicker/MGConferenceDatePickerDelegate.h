//
//  MGConferenceDatePickerDelegate.h
//  MGConferenceDatePicker
//
//  Created by Matteo Gobbi on 20/03/14.
//  Copyright (c) 2014 Matteo Gobbi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGConferenceDatePicker;

//Protocol to return the date
@protocol MGConferenceDatePickerDelegate <NSObject>

@optional
- (void)conferenceDatePicker:(MGConferenceDatePicker *)datePicker saveDate:(NSDate *)date;

@end
