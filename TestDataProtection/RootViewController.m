//
//  RootViewController.m
//  TestDataProtection
//
//  Created by Joshua Vickery on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize fileProtectionValue, fileContents;

- (void) resetFileInfo {
    self.fileProtectionValue = @"not yet read...";
    self.fileContents = @"not yet read...";
}

- (void)refresh {
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    [spinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:spinner] autorelease];

    [self resetFileInfo];
    [self.tableView reloadData];
    
    [self performSelector:@selector(doReload) withObject:nil afterDelay:20];
    
}

- (NSString *)filePath {
    NSString *documentsDirectory;
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0)  {
        documentsDirectory = [paths objectAtIndex:0];
    }
    return [documentsDirectory stringByAppendingPathComponent:@"protected_file"];
}

- (void) createFile {
    [[NSFileManager defaultManager] createFileAtPath:[self filePath]
                                            contents:[@"super secret file contents" dataUsingEncoding:NSUTF8StringEncoding]
                                          attributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                                                 forKey:NSFileProtectionKey]];
    

    [self.tableView reloadData];
}

- (void)doReload {
    
    NSLog(@"protected data available: %@",[[UIApplication sharedApplication] isProtectedDataAvailable] ? @"yes" : @"no");
    
    self.fileProtectionValue = [[[NSFileManager defaultManager] attributesOfItemAtPath:[self filePath]
                                                                                 error:NULL] valueForKey:NSFileProtectionKey];
    
    NSError *error;
    
    self.fileContents = [NSString stringWithContentsOfFile:[self filePath]
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    
    NSLog(@"file contents: %@\nerror: %@", self.fileContents, error);

    [self.tableView reloadData];

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                              target:self 
                                              action:@selector(refresh)] 
                                             autorelease];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                              target:self 
                                              action:@selector(refresh)] 
                                             autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                              target:self 
                                              action:@selector(createFile)] 
                                             autorelease];

    [self resetFileInfo];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self filePath]] ? 1 : 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 220;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.numberOfLines = 5;
    }

    cell.textLabel.text = [NSString stringWithFormat:@"file protection value: %@\n\nfile contents: %@", self.fileProtectionValue, self.fileContents];

    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self filePath]
                                                   error:NULL];
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)dealloc
{
    [fileProtectionValue release];
    [fileContents release];
    [super dealloc];
}

@end
