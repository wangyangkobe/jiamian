//
//  BannerViewController.m
//  JiaMian
//
//  Created by wanyang on 14-8-24.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "BannerViewController.h"
#import "CategoryCell.h"

@interface BannerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
{
    NSMutableArray* bannerArr;
    NSMutableArray* categroyArr;
    
    NSTimer* timer;
    UICollectionReusableView* headerView;
}
@property (retain, nonatomic) UIPageControl* pageControl;
@property (retain, nonatomic) UILabel* bannerTitleLabel;
@property (retain, nonatomic) UIView* scView1;
@end

#define kScrollViewTag 6001
#define kPageControllTag 6002
#define kCategoryCellIdentifier @"CategoryCell"
@implementation BannerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(handleScrollByTime) userInfo:nil repeats:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [timer invalidate];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //改变状态栏颜色
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarView.backgroundColor=UIColorFromRGB(0x293645);
    [self.view addSubview:statusBarView];
    
    //透明View
    UIView* scView=[[UIView alloc]initWithFrame:CGRectMake(0, 112, 320, 38)];
    scView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.collectionView addSubview:scView];
    
    //显示View
    _scView1=[[UIView alloc]initWithFrame:CGRectMake(0, 112, 320, 38)];
    _scView1.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self.collectionView addSubview:_scView1];
    
    // Do any additional setup after loading the view.
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    bannerArr = [NSMutableArray array];
    categroyArr = [NSMutableArray array];
    [self fetchDataFromServer:nil];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = UIColorFromRGB(0x344c62);
    self.collectionView.backgroundView = bgView;
    
    UINib* nib = [UINib nibWithNibName:NSStringFromClass([CategoryCell class])
                                bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kCategoryCellIdentifier];
    
    //tabbar不透明
    if (IOS_NEWER_OR_EQUAL_TO_7)
        self.tabBarController.tabBar.translucent = NO;
    //tabar整个的图片
    UIImage *image = [UIImage imageNamed:@"button.png"];
    [self.tabBarController.tabBar setBackgroundImage:image];
    
    //tabar选中后的图片
    self.tabBarController.tabBar.selectedImageTintColor=[UIColor whiteColor];
    //self.tabBarController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"gointolist.png.jpg"];
    
}
- (void)handleScrollByTime
{
    UIScrollView* scrollV = (UIScrollView*)[headerView viewWithTag:kScrollViewTag];
    NSInteger newPage = (self.pageControl.currentPage + 1) % bannerArr.count;
    [self.pageControl setCurrentPage:newPage];
    [scrollV setContentOffset:CGPointMake(320 * newPage, 0) animated:YES];
    [self.bannerTitleLabel setText:[self bannerTitleLabelText:self.pageControl]];
}
- (void)fetchDataFromServer:(UIRefreshControl*)object
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* banners = [[NetWorkConnect sharedInstance] getBannersByCount:5];
        NSArray* categories = [[NetWorkConnect sharedInstance] getCategoriesByCount:5 orderId:0];
        if (banners.count > 0) {
            [bannerArr removeAllObjects];
            [bannerArr addObjectsFromArray:banners];
        }
        if (categories.count > 0) {
            [categroyArr removeAllObjects];
            [categroyArr addObjectsFromArray:categories];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
    
    if (object && object.isRefreshing) {
        [object endRefreshing];
    }
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = floorf(scrollView.contentOffset.x / 320);
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(handleScrollByTime) userInfo:nil repeats:YES];
    
    [self.bannerTitleLabel setText:[self bannerTitleLabelText:self.pageControl]];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [timer invalidate];
    timer  = nil;
}
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return categroyArr.count;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCategoryCellIdentifier
                                                                   forIndexPath:indexPath];
    CategoryModel* category = [categroyArr objectAtIndex:indexPath.row];
    [cell.titleLabel setText:category.title];
    [cell.descriptionLabel setText:category.description];
    [cell.bgImageView setImageWithURL:[NSURL URLWithString:category.background_url] placeholderImage:nil];
    return cell;
}
#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryModel* category = [categroyArr objectAtIndex:indexPath.row];
    if (101 == category.category_type) //圈内八卦
    {
        BOOL isLogIn = [USER_DEFAULT boolForKey:kUserLogIn];
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        if ( NO == isLogIn )
        {
            RegAndLoginViewController* logInVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LogInVCIdentifier"];
            [self presentViewController:logInVC animated:YES completion:nil];
        }
        else
        {
            HomePageViewController* homeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"HomePageVcIdentifier"];
            homeVC.hidesBottomBarWhenPushed = YES;
            homeVC.categoryId = category.category_id;
            [self.navigationController pushViewController:homeVC animated:YES];
        }
    }
}
- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ( [kind isEqualToString:UICollectionElementKindSectionHeader] )
    {
        headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                        withReuseIdentifier:@"BannerHeaderIdentifier"
                                                               forIndexPath:indexPath];
        [_scView1 addSubview:self.bannerTitleLabel];
        [_scView1 addSubview:self.pageControl];
        
        UIScrollView* scrollV = (UIScrollView*)[headerView viewWithTag:kScrollViewTag];
        NSInteger banerCount = [bannerArr count];
        CGSize scrollVSize =scrollV.bounds.size;
        [scrollV setContentSize:CGSizeMake(scrollVSize.width * banerCount, scrollVSize.height)];
        [scrollV setDelegate:self];
        
        for (int i = 0; i < banerCount; i++)
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(scrollVSize.width * i, 6,
                                                                                   scrollVSize.width, 144)];
            BannerModel* banner = (BannerModel*)[bannerArr objectAtIndex:i];
            [imageView setImageWithURL:[NSURL URLWithString:banner.background_url] placeholderImage:nil];
            [scrollV addSubview:imageView];
        }
        return headerView;
    }
    return nil;
}
- (UIPageControl*)pageControl
{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(260, 19, 40, 10)];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0x0a91d7);
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        
    }
    _pageControl.numberOfPages = bannerArr.count;
    return _pageControl;
}
- (UILabel*)bannerTitleLabel {
    if (_bannerTitleLabel == nil) {
        _bannerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, 250, 20)];
        [_bannerTitleLabel setTextColor:[UIColor whiteColor]];
        [_bannerTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_bannerTitleLabel setFont:[UIFont systemFontOfSize:14]];
        
        
    }
    return _bannerTitleLabel;
}
- (NSString*)bannerTitleLabelText:(UIPageControl*)pageControl {
    BannerModel* banner = [bannerArr objectAtIndex:pageControl.currentPage];
    return banner.title;
}
#pragma mark UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 6.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 6.0f;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(6, 6, 6, 6);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(151.0f, 151.0f);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(320, 151);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
