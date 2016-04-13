//
//  DetailViewController.m
//  IBIntegrationTest
//
//  Created by Tobias Lensing on 8/4/12.
//  Copyright (C) 2016 Tobias Lensing. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

- (void)dealloc
{
    [_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item


- (void)configureView
{
    ICScene *scene = [ICScene scene];
    ICButton *testButton = [ICButton buttonWithSize:icSizeMake(120, 21)];
    testButton.label.text = @"Test";
    testButton.position = kmVec3Make(10, 10, 0);
    [scene addChild:testButton];
    [self runWithScene:scene];
}

// FIXME: retina display support, order of initialization, move this to ICHostViewControllerIOS
// and use setUpScene?!
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Issue #3: wire view to host view controller when created via nib
    ((ICGLView *)self.view).hostViewController = self;
    
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
