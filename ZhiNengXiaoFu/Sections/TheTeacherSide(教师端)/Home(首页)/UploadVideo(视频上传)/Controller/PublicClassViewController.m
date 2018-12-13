//
//  PublicClassViewController.m
//  ZhiNengXiaoFu
//
//  Created by duxiu on 2018/7/30.
//  Copyright © 2018年 henanduxiu. All rights reserved.
//

#import "PublicClassViewController.h"
#import "PublicClassCell.h"
#import "PublicClassModel.h"
#import "VideoSettingsViewController.h"
#import "TeacherZaiXianDetailsViewController.h"

@interface PublicClassViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray   *publicClassArr;
@property (nonatomic, strong) UICollectionView *publicClassCollectionView;
@property (nonatomic, strong) UIImageView      *zanwushuju;
@property (nonatomic, assign) NSInteger        page;
@property (nonatomic, strong) NSString         *videoID;

@end

@implementation PublicClassViewController

- (NSMutableArray *)publicClassArr {
    if (!_publicClassArr) {
        _publicClassArr = [NSMutableArray array];
    }
    return _publicClassArr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.page = 1;
    [self makePublicClassViewControllerUI];
    self.zanwushuju = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 105 / 2, 200, 105, 111)];
    self.zanwushuju.image = [UIImage imageNamed:@"暂无数据家长端"];
    self.zanwushuju.alpha = 0;
    [self.publicClassCollectionView addSubview:self.zanwushuju];
    //下拉刷新
    self.publicClassCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];
    //自动更改透明度
    self.publicClassCollectionView.mj_header.automaticallyChangeAlpha = YES;
    //进入刷新状态
    [self.publicClassCollectionView.mj_header beginRefreshing];
    //上拉刷新
    self.publicClassCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTopic)];
}

- (void)viewDidLoad {  //公开课
    [super viewDidLoad];

}

- (void)loadNewTopic {
    self.page = 1;
    [self.publicClassArr removeAllObjects];
    [self getDataFromMyPublishListURL:self.page];
}

- (void)loadMoreTopic {
    self.page += 1;
    [self getDataFromMyPublishListURL:self.page];
}

- (void)getDataFromMyPublishListURL:(NSInteger)page {
    NSDictionary *dic = @{@"key":[UserManager key],@"is_charge":@"0",@"page":[NSString stringWithFormat:@"%ld",page]};
    [[HttpRequestManager sharedSingleton] POST:myPublishListURL parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        //结束头部刷新
        [self.publicClassCollectionView.mj_header endRefreshing];
        //结束尾部刷新
        [self.publicClassCollectionView.mj_footer endRefreshing];
        if ([[responseObject objectForKey:@"status"] integerValue] == 200) {
            NSMutableArray *arr = [PublicClassModel mj_objectArrayWithKeyValuesArray:[responseObject objectForKey:@"data"]];
            for (PublicClassModel *model in arr) {
                [self.publicClassArr addObject:model];
            }
            if (self.publicClassArr.count == 0) {
                self.zanwushuju.alpha = 1;
            } else {
                self.zanwushuju.alpha = 0;
                [self.publicClassCollectionView reloadData];
            }
        } else {
            if ([[responseObject objectForKey:@"status"] integerValue] == 401 || [[responseObject objectForKey:@"status"] integerValue] == 402) {
                [UserManager logoOut];
            } else {
                
            }
            [WProgressHUD showErrorAnimatedText:[responseObject objectForKey:@"msg"]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (void)makePublicClassViewControllerUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.publicClassCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - APP_NAVH - 40) collectionViewLayout:layout];
    self.publicClassCollectionView.backgroundColor = backColor;
    self.publicClassCollectionView.delegate = self;
    self.publicClassCollectionView.dataSource = self;
    [self.view addSubview:self.publicClassCollectionView];
    [self.publicClassCollectionView registerClass:[PublicClassCell class] forCellWithReuseIdentifier:PublicClassCell_CollectionView];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.publicClassArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *gridcell = nil;
    PublicClassCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PublicClassCell_CollectionView forIndexPath:indexPath];
    if (self.publicClassArr.count != 0) {
        PublicClassModel *model = [self.publicClassArr objectAtIndex:indexPath.row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:model.img] placeholderImage:nil];
        cell.contentLabel.text = model.title;
        self.videoID = model.ID;
        [cell.playBtn addTarget:self action:@selector(playBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.setUpBtn addTarget:self action:@selector(setUpBtn:) forControlEvents:UIControlEventTouchUpInside];
        gridcell = cell;
    }
    return gridcell;
}

- (void)playBtn : (UIButton *)sender {
    NSLog(@"点击播放按钮");
    TeacherZaiXianDetailsViewController *teacherZaiXianDetailsVC = [[TeacherZaiXianDetailsViewController alloc] init]; teacherZaiXianDetailsVC.teacherZaiXianDetailsId = self.videoID;
    [self.navigationController pushViewController:teacherZaiXianDetailsVC animated:YES];
}

- (void)setUpBtn : (UIButton *)sender {
    NSLog(@"点击设置");
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeZero;
    itemSize = CGSizeMake(APP_WIDTH, APP_HEIGHT * 0.3 + 50);
    return itemSize;
}

                                                                                                                                                                                                                                                                                                                                  
//点击响应方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.publicClassArr.count != 0) {
        PublicClassModel *model = [self.publicClassArr objectAtIndex:indexPath.row];
        TeacherZaiXianDetailsViewController *teacherZaiXianDetailsVC = [[TeacherZaiXianDetailsViewController alloc] init];
        if (model.ID == nil) {
            [WProgressHUD showErrorAnimatedText:@"数据不正确,请重试"];
        } else {
            teacherZaiXianDetailsVC.teacherZaiXianDetailsId = model.ID;
            [self.navigationController pushViewController:teacherZaiXianDetailsVC animated:YES];
        }
    }
}

@end
