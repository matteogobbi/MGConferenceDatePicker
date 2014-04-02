MGConferenceDatePicker
===============

MGConferenceDatePicker is an object wich extend a UIView furnishing a very nice type of data picker.

<img src="http://i57.tinypic.com/2iln5ev.png" alt="MGConferenceDatePicker Screenshot" width=400px />

## Info

This code must be used under ARC. 
If your code doesn't use ARC you can [mark this source with the compiler flag](http://www.codeography.com/2011/10/10/making-arc-and-non-arc-play-nice.html) `-fobjc-arc` 

## Example Usage

In the package is included the project to test the object.
This is an easy example to init the control from code:

``` objective-c
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
```

Or you are also able to set the view directly in the NIB or in the XIB file and simply just set the delegate from code.

See the example's project.


## Contact

Matteo Gobbi

- http://www.matteogobbi.it
- http://github.com/matteogobbi
- http://twitter.com/matteo_gobbi
- https://angel.co/matteo-gobbi
- http://www.linkedin.com/profile/view?id=24211474

## License

MGConferenceDatePicker is available under the MIT license.
