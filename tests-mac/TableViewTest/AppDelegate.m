//  
//  Copyright (C) 2013 Tobias Lensing, Marcus Tillmanns
//  http://icedcoffee-framework.org
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize hostViewController = _hostViewController;
@synthesize tableData = _tableData;

- (id)init
{
    if ((self = [super init])) {
        self.tableData = [NSArray arrayWithObjects:[NSString stringWithString:@"Iced Latte"],
                                                   [NSString stringWithString:@"Frozen Mocca"],
                                                   [NSString stringWithString:@"Frappuccino Deluxe"], nil];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSInteger)numberOfRowsInTableView:(ICTableView *)tableView
{
    return [self.tableData count];
}

- (ICTableViewCell *)tableView:(ICTableView *)tableView cellForRowAtIndex:(NSInteger)rowIndex
{
    ICTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [ICTableViewCell cellWithIdentifier:@"cell"];
    }
    cell.label.text = [self.tableData objectAtIndex:rowIndex];
    return cell;
}

- (void)setUpScene
{
    ICScene *scene = [ICScene scene];
    ICTableView *tableView = [ICTableView viewWithSize:icSizeMake(300, 400)];
    tableView.dataSource = self;
    [scene addChild:tableView];
    
    [self.hostViewController runWithScene:scene];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.hostViewController = [ICHostViewController platformSpecificHostViewController];
    [(ICHostViewControllerMac *)self.hostViewController setAcceptsMouseMovedEvents:YES];
    
    ICGLView *glView = [[ICGLView alloc] initWithFrame:self.window.frame
                                          shareContext:nil
                                    hostViewController:self.hostViewController];
    
    self.window.contentView = glView;
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window makeFirstResponder:self.window.contentView];
    
    [self setUpScene];
}

@end
