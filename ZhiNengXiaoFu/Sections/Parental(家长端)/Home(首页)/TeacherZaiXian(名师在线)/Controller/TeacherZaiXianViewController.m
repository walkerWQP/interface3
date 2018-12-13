//
//  TeacherZaiXianViewController.m
//  ZhiNengXiaoFu
//
//  Created by mac on 2018/7/30.
//  Copyright © 2018年 henanduxiu. All rights reserved.
//

#import "TeacherZaiXianViewController.h"
#import "TeacherListNCell.h"
#import "TeacherZaiXianDetailsViewController.h"
#import "TeacherZaiXianModel.h"
#import "PrefixHeader.pch"

@interface TeacherZaiXianViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView    *TeacherZaiXianTableView;
@property (nonatomic, strong) NSMutableArray *TeacherZaiXianAry;
@property (nonatomic, assign) NSInteger      page;
@property (nonatomic, strong) UIImageView    *zanwushuju;

@end

@implementation TeacherZaiXianViewController

- (NSMutableArray *)TeacherZaiXianAry {
    if (!_TeacherZaiXianAry) {
        self.TeacherZaiXianAry = [@[]mutableCopy];
    }
    return _TeacherZaiXianAry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"名师在线";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.view.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        self.TeacherZaiXianTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.TeacherZaiXianTableView];
    self.TeacherZaiXianTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.TeacherZaiXianTableView registerNib:[UINib nibWithNibName:@"TeacherListNCell" bundle:nil] forCellReuseIdentifier:@"TeacherListNCellId"];

    self.zanwushuju = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 105 / 2, 300, 105, 111)];
    self.zanwushuju.image = [UIImage imageNamed:@"暂无数据家长端"];
    self.zanwushuju.alpha = 0;
    [self.view addSubview:self.zanwushuju];
    self.glt_scrollView = self.TeacherZaiXianTableView;

    //下拉刷新
    self.TeacherZaiXianTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];
    //自动更改透明度
    self.TeacherZaiXianTableView.mj_header.automaticallyChangeAlpha = YES;
    //进入刷新状态
    [self.TeacherZaiXianTableView.mj_header beginRefreshing];
    //上拉刷新
    self.TeacherZaiXianTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
}


- (void)loadNewTopic {
    self.page = 1;
    [self.TeacherZaiXianAry removeAllObjects];
    [self setNetWork:self.page];
}

- (void)loadMoreTopic {
    self.page += 1;
    [self setNetWork:self.page];
}

- (void)setNetWork:(NSInteger)page {
    NSDictionary *dic = @{@"key":[UserManager key], @"page":[NSString stringWithFormat:@"%ld",page], @"t_id":[NSString stringWithFormat:@"%ld", [SingletonHelper manager].teacherZaiXianId]};
    [[HttpRequestManager sharedSingleton] POST:indexOnlineVideoListByType parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        //结束头部刷新
        [self.TeacherZaiXianTableView.mj_header endRefreshing];
        //结束尾部刷新
        [self.TeacherZaiXianTableView.mj_footer endRefreshing];
        if ([[responseObject objectForKey:@"status"] integerValue] == 200) {
            NSMutableArray *arr = [TeacherZaiXianModel mj_objectArrayWithKeyValuesArray:[responseObject objectForKey:@"data"]];
            for (TeacherZaiXianModel *model in arr) {
                [self.TeacherZaiXianAry addObject:model];
            }
            if (self.TeacherZaiXianAry.count == 0) {
                self.zanwushuju.alpha = 1;
            } else {
                self.zanwushuju.alpha = 0;
            }
            [self.TeacherZaiXianTableView reloadData];
        } else {
            if ([[responseObject objectForKey:@"status"] integerValue] == 401 || [[responseObject objectForKey:@"status"] integerValue] == 402) {
                [UserManager logoOut];
            } else {
                
            }
            [WProgressHUD showErrorAnimatedText:[responseObject objectForKey:@"msg"]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@", error);
    }];
}



- (UITableView *)TeacherZaiXianTableView {
    if (!_TeacherZaiXianTableView) {
          CGFloat H = kIPhoneX ? (self.view.bounds.size.height - 64 - 24 - 34) : self.view.bounds.size.height - 64;
        self.TeacherZaiXianTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, H) style:UITableViewStylePlain];
        self.TeacherZaiXianTableView.backgroundColor = backColor;
        self.TeacherZaiXianTableView.delegate = self;
        self.TeacherZaiXianTableView.dataSource = self;
    }
    return _TeacherZaiXianTableView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

//有时候tableview的底部视图也会出现此现象对应的修改就好了
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.TeacherZaiXianAry.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        TeacherListNCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TeacherListNCellId" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       if (self.TeacherZaiXianAry.count != 0) {
            TeacherZaiXianModel *model = [self.TeacherZaiXianAry objectAtIndex:indexPath.row];
            [cell.TeacherListNImg sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:[UIImage imageNamed:@"缩略图"]];
           cell.TeacherListNImg.contentMode = UIViewContentModeScaleAspectFill;
           cell.TeacherListNImg.clipsToBounds = YES;
            cell.TeacherListNTitleLabel.text = model.title;
            if (model.view > 9999) {
                CGFloat num = model.view / 10000;
                cell.TeacherListNBoFangCi.text = [NSString stringWithFormat:@"%.1f万次播放", num];
            } else {
                cell.TeacherListNBoFangCi.text = [NSString stringWithFormat:@"%ld次播放", model.view];
            }
            cell.TeacherListNFenLeiLabel.text = [NSString stringWithFormat:@"所属分类:%@", model.t_name];
            
            if (model.label.count == 0) {
                cell.TeacherListNOneView.alpha = 0;
                cell.TeacherListNTwoView.alpha = 0;
                cell.TeacherListNThreeView.alpha = 0;
                
                cell.TeacherListNOneLabel.alpha = 0;
                cell.TeacherListNTwoLabel.alpha = 0;
                cell.TeacherListNThreeLabel.alpha = 0;
            } else if (model.label.count == 1) {
                cell.TeacherListNOneView.alpha = 1;
                cell.TeacherListNTwoView.alpha = 0;
                cell.TeacherListNThreeView.alpha = 0;
                
                cell.TeacherListNOneLabel.alpha = 1;
                cell.TeacherListNTwoLabel.alpha = 0;
                cell.TeacherListNThreeLabel.alpha = 0;
                cell.TeacherListNOneLabel.text = [model.label objectAtIndex:0];
                
            } else if (model.label.count == 2) {
                cell.TeacherListNOneView.alpha = 1;
                cell.TeacherListNTwoView.alpha = 1;
                cell.TeacherListNThreeView.alpha = 0;
                
                cell.TeacherListNOneLabel.alpha = 1;
                cell.TeacherListNTwoLabel.alpha = 1;
                cell.TeacherListNThreeLabel.alpha = 0;
                cell.TeacherListNOneLabel.text = [model.label objectAtIndex:0];
                cell.TeacherListNTwoLabel.text = [model.label objectAtIndex:1];
            } else if (model.label.count == 3) {
                cell.TeacherListNOneView.alpha = 1;
                cell.TeacherListNTwoView.alpha = 1;
                cell.TeacherListNThreeView.alpha = 1;
                
                cell.TeacherListNOneLabel.alpha = 1;
                cell.TeacherListNTwoLabel.alpha = 1;
                cell.TeacherListNThreeLabel.alpha = 1;
                cell.TeacherListNOneLabel.text = [model.label objectAtIndex:0];
                cell.TeacherListNTwoLabel.text = [model.label objectAtIndex:1];
                cell.TeacherListNThreeLabel.text = [model.label objectAtIndex:2];
            }
       }
        return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125 - 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        if (self.TeacherZaiXianAry.count != 0) {
            TeacherZaiXianDetailsViewController * teacherZaiXianDetailsVC = [[TeacherZaiXianDetailsViewController alloc] init];
            TeacherZaiXianModel *model = [self.TeacherZaiXianAry objectAtIndex:indexPath.row];
            teacherZaiXianDetailsVC.teacherZaiXianDetailsId = model.ID;
            [self.navigationController pushViewController:teacherZaiXianDetailsVC animated:YES];
        }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
