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

@property (nonatomic, strong) NSMutableArray *mDataArr;
@property (strong, nonatomic) IBOutlet UITableView *mTableView;
@property (nonatomic, strong) UORefreshControl *mRefreshCotrol;

@end

@implementation UOTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initDataArr];
    [self initNaviItem];
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

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    
    return cell;
}

#pragma mark -Tableview Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing) {
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    ViewController *viewControler = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:viewControler animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark -Tableview Edit
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        return UITableViewCellEditingStyleNone;
    }else if (1 <= indexPath.row && indexPath.row <= 3){
        return UITableViewCellEditingStyleInsert;
    }else if (4 <= indexPath.row && indexPath.row <= 7){
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark -TableviewCell Move Delegate
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"++move from index:%lu to index:%lu",sourceIndexPath.item,destinationIndexPath.item);
}

#pragma mark -Tableview Actions
//下面这俩回调如果实现了的话 上面的editActionsForRowAtIndexPath就不会再执行
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *normalRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal
                                                                                  title:@"操作1"
                                                                                handler:^(UIContextualAction *action,UIView *sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSLog(@"+++++右滑响应");
        completionHandler (NO);
    }];
    normalRowAction.backgroundColor = [UIColor blueColor];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[normalRowAction]];
    
    return config;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
                                                                                  title:@"delete"
                                                                                handler:^(UIContextualAction *action, UIView * sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [_mDataArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSLog(@"+++++左滑响应");
        completionHandler (YES);
    }];
    deleteRowAction.backgroundColor = [UIColor blueColor];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    
    return config;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_mDataArr removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSLog(@"++++delete style");
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [_mDataArr addObject:@(indexPath.row)];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        NSLog(@"++++insert style");
    }else{
        NSLog(@"++++none style");
    }
}


#pragma mark -BUSINESS
- (void)initDataArr{
    _mDataArr = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [_mDataArr addObject:@(i)];
    }
}

- (void)initNaviItem{
    UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [bt2 setTitle:@"编辑" forState:UIControlStateNormal];
    [bt2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [bt2 sizeToFit];
    [bt2 addTarget:self action:@selector(onEdit:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bt2];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
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

- (void)onEdit:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing) {
        [sender setTitle:@"完成" forState:UIControlStateNormal];
    }else{
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
    }
}
@end
