//
//  DKMainViewController.m
//  LiveBlur
//
//  Created by Dmitry Klimkin on 16/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKMainViewController.h"
#import "DKLiveBlurView.h"

#define kDKTableViewMainBackgroundImageFileName @"background.jpg"
#define kDKTableViewDefaultCellHeight 50.0f
#define kDKTableViewDefaultContentInset 400.0f

@interface DKMainViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation DKMainViewController

@synthesize tableView = _tableView;
@synthesize items = _items;

- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray new];
        
        NSArray *countryCodes = [NSLocale ISOCountryCodes];
        
        for (NSString *countryCode in countryCodes)
        {
            NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
            NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
            
            [_items addObject: country];
        }
    }
    return _items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Blur", nil);
    self.navigationItem.title = self.title;
    self.navigationController.navigationBar.translucent = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = kDKTableViewDefaultCellHeight;
    
    DKLiveBlurView *backgroundView = [[DKLiveBlurView alloc] initWithFrame: self.view.bounds];
    
    backgroundView.originalImage = [UIImage imageNamed:@"bg1.jpg"];
    backgroundView.scrollView = self.tableView;
    backgroundView.isGlassEffectOn = YES;
    
    self.tableView.backgroundView = backgroundView;
    self.tableView.contentInset = UIEdgeInsetsMake(kDKTableViewDefaultContentInset, 0, 0, 0);
    
    [self.view addSubview: self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.items[indexPath.row];
    
    return cell;
}

@end
