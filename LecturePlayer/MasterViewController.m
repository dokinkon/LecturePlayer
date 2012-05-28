//
//  MasterViewController.m
//  LecturePlayer
//
//  Created by chao-chih lin on 12/5/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
    
    NSArray* lectureGroups_;
    
    NSMutableDictionary* lectures_;
}

- (void)readLectureList;

- (NSString *)makeFilePathWithLecture:(NSString *)lectureName andBst:(NSString *)bstName; 

@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [_objects release];
    [super dealloc];
}

- (NSString *)makeFilePathWithLecture:(NSString *)lectureName andBst:(NSString *)bstName
{
    NSString* lecturesPath = [[NSBundle mainBundle] pathForResource:@"Lectures" ofType:@""];
    return [lecturesPath stringByAppendingFormat:@"/%@/%@", lectureName, bstName];
}

- (void)readLectureList
{
    NSString* lecturesPath = [[NSBundle mainBundle] pathForResource:@"Lectures" ofType:@""];
    assert(lecturesPath);
    NSArray* bstDirectories = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:lecturesPath error:nil];
    
    lectures_ = [[NSMutableDictionary alloc] init];
    
    for (id bstDirectory in bstDirectories)
    {
        NSString* bstDirectoryPath = [lecturesPath stringByAppendingString:[NSString stringWithFormat:@"/%@", bstDirectory]];
        //NSLog(<#NSString *format, ...#>)
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bstDirectoryPath error:nil];
        NSLog(@"%@", contents);
        NSMutableArray* bstFiles = [NSMutableArray array];
        for (id fileName in contents)
        {
            if ([fileName hasSuffix:@"bst"])
            {
                [bstFiles addObject:fileName];
            }
        }
        [lectures_ setObject:bstFiles forKey:bstDirectory];
    }
    
    NSLog(@"%@", lectures_);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self readLectureList];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger c = [lectures_ count];
    return c;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* allKeys = [lectures_ allKeys];
    NSString* key = [allKeys objectAtIndex:section];
    NSArray* bstFiles = [lectures_ objectForKey:key];
    return [bstFiles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray* allKeys = [lectures_ allKeys];
    return [allKeys objectAtIndex:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger section = indexPath.section;
    NSArray* allKeys = [lectures_ allKeys];
    NSString* key = [allKeys objectAtIndex:section];
    NSArray* bstFileNames = [lectures_ objectForKey:key];
    //NSDate *object = [_objects objectAtIndex:indexPath.row];
    cell.textLabel.text = [bstFileNames objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSArray* allKeys = [lectures_ allKeys];
    NSString* lectureName = [allKeys objectAtIndex:section];
    NSArray* bstNames = [lectures_ objectForKey:lectureName];
    NSString* bstName = [bstNames objectAtIndex:indexPath.row];
    self.detailViewController.bstFilePath = [self makeFilePathWithLecture:lectureName andBst:bstName];

    //NSDate *object = [_objects objectAtIndex:indexPath.row];
    //self.detailViewController.detailItem = object;
}

@end
