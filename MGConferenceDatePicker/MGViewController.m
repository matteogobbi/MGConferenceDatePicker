//
//  MGViewController.m
//  MGConferenceDatePicker
//
//  Created by Matteo Gobbi on 08/02/14.
//  Copyright (c) 2014 Matteo Gobbi. All rights reserved.
//

#import "MGViewController.h"

@implementation MGViewController

-(void)viewDidAppear:(BOOL)animated
{
    //New view controller
    UIViewController *pickerViewController = [[UIViewController alloc] init];
    
    //Init the datePicker view and set self as delegate
    MGConferenceDatePicker *datePicker = [[MGConferenceDatePicker alloc] initWithFrame:self.view.bounds];
    [datePicker setDelegate:self];
    
    //OPTIONAL: Choose the background color
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    
    //Set the data picker as view of the new view controller
    [pickerViewController setView:datePicker];
    
    //Present the view controller
    [self presentViewController:pickerViewController animated:YES completion:nil];
}

//Delegate
-(void)conferenceDatePicker:(MGConferenceDatePicker *)datePicker saveDate:(NSDate *)date {
    NSLog(@"%@",[date description]);
}

@end
