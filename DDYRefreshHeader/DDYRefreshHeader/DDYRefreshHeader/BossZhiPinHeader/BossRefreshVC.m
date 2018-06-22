#import "BossRefreshVC.h"
#import "BossRefreshHeader.h"

@interface BossRefreshVC ()

@end

@implementation BossRefreshVC

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak __typeof__ (self)weakSelf = self;
    self.tableView.mj_header = [BossRefreshHeader headerWithRefreshingBlock:^{
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
    cell.textLabel.text = [NSString stringWithFormat:@"老版Boss下拉刷新"];
    return cell;
}

@end
