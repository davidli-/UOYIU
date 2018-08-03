//
//  UOTableViewController.m
//  UOYIU
//
//  Created by Macmafia on 2018/4/25.
//  Copyright © 2018年 Macmafia. All rights reserved.
//

#import "UOTableViewController.h"
#import "ViewController.h"
#import "UORefreshControl.h"

@interface UOTableViewController ()
{
    NSInteger rows;
}
@property (strong, nonatomic) IBOutlet UITableView *mTableView;
@property (nonatomic, strong) UORefreshControl *mRefreshCotrol;

@end

@implementation UOTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    rows = 10;
    self.title = @"UOYIU";
    if (@available(iOS 11.0, *)) {
        self.tableView.separatorInsetReference = UITableViewSeparatorInsetFromAutomaticInsets;
        //self.navigationController.navigationBar.prefersLargeTitles = YES;
        //self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    UIBarButtonItem *bt = [[UIBarButtonItem alloc] initWithTitle:@">1<"
                                                           style:UIBarButtonItemStylePlain
                                                          target:nil
                                                          action:nil];
    self.navigationItem.backBarButtonItem = bt;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mRefreshCotrol createRefreshHeader];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -Getter Setter
- (UORefreshControl *)mRefreshCotrol
{
    if (!_mRefreshCotrol) {
        _mRefreshCotrol = [[UORefreshControl alloc] initWithTableview:_mTableView];
    }
    return _mRefreshCotrol;
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ViewController *viewControler = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:viewControler animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//下面这俩回调如果实现了的话 上面的editActionsForRowAtIndexPath就不会再执行
-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *normalRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                  title:@"normal"
                                                                                handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"+++++油花");
        completionHandler (NO);
    }];
    normalRowAction.backgroundColor = [UIColor blueColor];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[normalRowAction]];
    
    return config;
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                                  title:@"delete"
                                                                                handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        rows --;
        completionHandler (YES);
    }];
    deleteRowAction.backgroundColor = [UIColor blueColor];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    
    return config;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        rows --;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        NSLog(@"++++insert style");
    }else{
        NSLog(@"++++none style");
    }
}

@end
