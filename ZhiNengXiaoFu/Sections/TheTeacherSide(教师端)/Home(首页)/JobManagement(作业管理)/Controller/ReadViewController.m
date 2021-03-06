//
//  ReadViewController.m
//  ZhiNengXiaoFu
//
//  Created by 独秀科技 on 2018/12/25.
//  Copyright © 2018 henanduxiu. All rights reserved.
//

#import "ReadViewController.h"
#import "TotalNumberCell.h"
#import "TotalNumberModel.h"

@interface ReadViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray   *readArr;
@property (nonatomic, strong) UICollectionView *readCollectionView;
@property (nonatomic, strong) UIImageView      *zanwushuju;

@end

@implementation ReadViewController

- (NSMutableArray *)readArr {
    if (!_readArr) {
        _readArr = [NSMutableArray array];
    }
    return _readArr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    //下拉刷新
//    self.readCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTopic)];
//    //自动更改透明度
//    self.readCollectionView.mj_header.automaticallyChangeAlpha = YES;
//    //进入刷新状态
//    [self.readCollectionView.mj_header beginRefreshing];
}

- (void)loadNewTopic {
    [self.readArr removeAllObjects];
    NSDictionary *dic = @{@"key":[UserManager key],@"id":self.ID,@"class_id":self.class_id,@"is_read":@"1",@"type":self.type};
    [self getReadURLData:dic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.type);
    [self.readArr removeAllObjects];
    NSDictionary *dic = @{@"key":[UserManager key],@"id":self.ID,@"class_id":self.class_id,@"is_read":@"1",@"type":self.type};
    [self getReadURLData:dic];
    self.zanwushuju = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 105 / 2, 200, 105, 111)];
    self.zanwushuju.image = [UIImage imageNamed:@"暂无数据家长端"];
    self.zanwushuju.alpha = 0;
    [self.view addSubview:self.zanwushuju];
    [self makeTotalNumberViewControllerUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    //结束头部刷新
    [self.readCollectionView.mj_header endRefreshing];
}



- (void)getReadURLData:(NSDictionary *)dic {
    
    [[HttpRequestManager sharedSingleton] POST:GetReadURL parameters:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"status"] integerValue] == 200) {
            self.readArr = [TotalNumberModel mj_objectArrayWithKeyValuesArray:[[responseObject objectForKey:@"data"] objectForKey:@"list"]];
            if (self.readArr.count == 0) {
                self.zanwushuju.alpha = 1;
            } else {
                self.zanwushuju.alpha = 0;
                [self.readCollectionView reloadData];
            }
            [self.readCollectionView reloadData];
        } else {
            if ([[responseObject objectForKey:@"status"] integerValue] == 401 || [[responseObject objectForKey:@"status"] integerValue] == 402) {
                [UserManager logoOut];
            } else {
                
            }
            [WProgressHUD showErrorAnimatedText:[responseObject objectForKey:@"msg"]];
        }
        //结束头部刷新
        [self.readCollectionView.mj_header endRefreshing];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)makeTotalNumberViewControllerUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.readCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - APP_NAVH - APP_TABH - 50) collectionViewLayout:layout];
    self.readCollectionView.backgroundColor = backColor;
    self.readCollectionView.delegate = self;
    self.readCollectionView.dataSource = self;
    [self.view addSubview:self.readCollectionView];
    [self.readCollectionView registerClass:[TotalNumberCell class] forCellWithReuseIdentifier:TotalNumberCell_CollectionView];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.readArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *gridcell = nil;
    TotalNumberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TotalNumberCell_CollectionView forIndexPath:indexPath];
    if (self.readArr.count != 0) {
        TotalNumberModel *model = [self.readArr objectAtIndex:indexPath.row];
        if (model.head_img == nil || [model.head_img isEqualToString:@""]) {
            cell.headImgView.image = [UIImage imageNamed:@"user"];
        } else {
            [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:model.head_img] placeholderImage:[UIImage imageNamed:@"user"]];
        }
        cell.nameLabel.text = model.name;
        if (model.is_leave == 1) { //1请假
            cell.nameLabel.textColor = RGB(253, 129, 149);
        } else if (model.is_leave == 2) { //2逃学
            cell.nameLabel.textColor = RGB(253, 129, 149);
        } else if (model.is_leave == 3) { //3签到
            cell.nameLabel.textColor = titlColor;
        }
        gridcell = cell;
    }
    return gridcell;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize itemSize = CGSizeZero;
    itemSize = CGSizeMake((APP_WIDTH - 45) / 3, APP_HEIGHT * 0.15);
    return itemSize;
}


//点击响应方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.readArr.count != 0) {
        
    }
}

@end
