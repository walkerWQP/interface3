//
//  TotalTabBarController.m
//  ZhiNengXiaoFu
//
//  Created by mac on 2018/7/20.
//  Copyright © 2018年 henanduxiu. All rights reserved.
//

#import "TotalTabBarController.h"
//家长端
#import "HomePageJViewController.h"
#import "ClassHomeViewController.h"
#import "QianDaoViewController.h"
#import "MineViewController.h"
#import "ChooseHomeViewController.h"
//教师端
#import "HomeTViewController.h"
#import "TheClassInformationViewController.h"
#import "SignClassViewController.h"
#import "MyViewController.h"

#import "MainNavigationController.h"

@interface TotalTabBarController ()

@end

@implementation TotalTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"chooseLoginState"] isEqualToString:@"2"]) {
        [[UITabBar appearance] setTintColor:THEMECOLOR];
    } else {
        [[UITabBar appearance] setTintColor:THEMECOLOR];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTabBarThree:) name:@"changeTabBarThree" object:nil];
    [[UITabBar appearance] setTintColor:tabBarColor];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"chooseLoginState"] isEqualToString:@"2"]) {
        
        [self setupChildViewController:@"首页" viewController:[HomeTViewController new] image:@"首页图标" selectedImage:@"首页图标拷贝"];
        [self setupChildViewController:@"班级信息" viewController:[TheClassInformationViewController new] image:@"班级管理" selectedImage:@"班级管理1"];
        [self setupChildViewController:@"到校情况" viewController:[SignClassViewController new] image:@"到校情况2" selectedImage:@"到校情况"];
        [self setupChildViewController:@"我的" viewController:[MyViewController new] image:@"我的拷贝" selectedImage:@"我的"];
        
    } else {

        [self setupChildViewController:@"首页" viewController:[HomePageJViewController new] image:@"首页未选" selectedImage:@"首页选中"];
        [self setupChildViewController:@"班级信息" viewController:[TheClassInformationViewController new] image:@"班级未选" selectedImage:@"班级选中"];
        [self setupChildViewController:@"进出安全" viewController:[QianDaoViewController new] image:@"进出未选" selectedImage:@"进出选中"];
        [self setupChildViewController:@"我的" viewController:[MineViewController new] image:@"我的未选" selectedImage:@"我的选中"];
        
    }

}

- (void)changeTabBarThree:(NSNotification *)notify {
    self.selectedViewController = [self.viewControllers objectAtIndex:2];
    UINavigationController *nav= (UINavigationController*)self.viewControllers[2];
    [nav popToRootViewControllerAnimated:NO];
}

- (void)setupChildViewController:(NSString *)title viewController:(UIViewController *)controller image:(NSString *)image selectedImage:(NSString *)selectedImage {
    UITabBarItem *item = [[UITabBarItem alloc]init];
    item.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.title = title;
    controller.tabBarItem = item;
    MainNavigationController *navController = [[MainNavigationController alloc]initWithRootViewController:controller];
    [self addChildViewController:navController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
