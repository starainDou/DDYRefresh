#import "ViewController.h"
#import "MJRefresh.h"
#import "BossHeaderView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak __typeof__ (self)weakSelf = self;
    self.tableView.mj_header = [BossHeaderView headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             __strong __typeof__ (weakSelf)strongSelf = weakSelf;
            [strongSelf.tableView.mj_header endRefreshing];
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    cell.backgroundColor = [UIColor colorWithRed:230./255. green:230./255. blue:230./255. alpha:1];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", @"下拉刷新"];
    return cell;
}

@end
