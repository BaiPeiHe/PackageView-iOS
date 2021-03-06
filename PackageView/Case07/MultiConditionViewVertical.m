//
//  MultiConditionViewVertical.m
//  PackageView
//
//  Created by 白鹤 on 16/9/8.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#define ITEM_HEIGHT 30
#define ITEM_WIDTH 60

#define BOTTOM_HEIGHT 10

#define VIEW_WIDTH self.frame.size.width

#import "MultiConditionViewVertical.h"
#import "ItemCollectionViewCell.h"
#import "NSString+Extension.h"
#import "UIButton+Extension.h"

@interface MultiConditionViewVertical ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/**
 *  条件视图
 */
@property (nonatomic, strong)UIView *conditionView;

/**
 *  底部视图
 */
@property (nonatomic, strong)UIButton *bottom;



/**
 *  分区数
 */
@property (nonatomic, assign)NSInteger section;
/**
 *  被点击的 Cell 的位置
 */
@property (nonatomic, strong)NSMutableArray *clickedCell;

/**
 *  每一个的标题
 */
@property (nonatomic, strong)NSMutableArray *itemsTitle;

/**
 *  协议
 */
@property (nonatomic, assign)id<MultiConditionViewDelegate>delegate;
@end

@implementation MultiConditionViewVertical


- (instancetype)initWithFrame:(CGRect)frame Delegate:(id<MultiConditionViewDelegate>)delegate{
    
    self = [super initWithFrame:frame];
    
    if(self){
        self.delegate = delegate;
        
        [self createData];
        
        [self createView];
    }
    return self;
}

- (void)createData{
    
    
    self.section = [self.delegate numberOfSectionsInMultiConditionView:self];
    if(self.section == 0){
        return;
    }
    self.itemsTitle = [NSMutableArray array];
    self.clickedCell = [NSMutableArray array];
    
    for(NSInteger section = 0; section < self.section; section++){
        
        NSMutableArray *itemArr = [NSMutableArray array];
        
        NSInteger itemCount = [self.delegate multiConditionView:self numberOfItemsInSections:section];
        
        for(NSInteger item = 0; item < itemCount; item++){
            
            NSString *title = [self.delegate multiConditionView:self titlleForItemAtSection:section Item:item];
            
            [itemArr addObject:title];
        }
        
        [self.clickedCell addObject:@"0"];
        
        [self.itemsTitle addObject:itemArr];
    }
}

- (void)createView{
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, ITEM_HEIGHT * self.section + BOTTOM_HEIGHT);
    
    // 条件视图
    self.conditionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, ITEM_HEIGHT * self.section)];
    [self addSubview:self.conditionView];
    
    for(NSInteger i = 0; i < self.section; i++){
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(20, 15);
        // 间距
        flowLayout.minimumLineSpacing = 2;
        flowLayout.minimumInteritemSpacing = 2;
        // 边框
        flowLayout.sectionInset = UIEdgeInsetsMake(2, 2, 2, 2);
        // 滑动方向为水平
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, i * ITEM_HEIGHT, VIEW_WIDTH, ITEM_HEIGHT) collectionViewLayout:flowLayout];
        [self.conditionView addSubview:collectionView];
        // 平行
        collectionView.showsHorizontalScrollIndicator = NO;
        
        collectionView.backgroundColor = [UIColor clearColor];
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        collectionView.tag = i + 1000;
        
        [collectionView registerClass:[ItemCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ItemCollectionViewCell class])];
        
        // 分割线
        UIView *slipe = [[UIView alloc] initWithFrame:CGRectMake(0, (i + 1) * ITEM_HEIGHT, VIEW_WIDTH, 1)];
        slipe.backgroundColor = [UIColor colorWithRed:243 / 255.0 green:243 / 255.0 blue:243 / 255.0 alpha:1];
        [self.conditionView addSubview:slipe];
    }
    
    // 底部
    self.bottom = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bottom.frame = CGRectMake(0, ITEM_HEIGHT * self.section, 50, BOTTOM_HEIGHT);
    self.bottom.center = CGPointMake(self.frame.size.width / 2, self.bottom.center.y);
    
    [self.bottom addTarget:self action:@selector(bottomAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.bottom];
    
    [self.bottom setHitEdgeInsets:UIEdgeInsetsMake(-20, -10, -20, -10)];
    
    self.bottom.backgroundColor = [UIColor brownColor];
}

#pragma mark UICollectionView 的协议方法

// Section 个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

// Item 个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSArray *rowArr = self.itemsTitle[section];
    
    return rowArr.count;
    
}

// 创建 Cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ItemCollectionViewCell class]) forIndexPath:indexPath];
    
    NSArray *rowArr = self.itemsTitle[indexPath.section];
    NSString *title = rowArr[indexPath.row];
    
    cell.title = title;
    
    // 当前 Cell 的状态,被点击 或 未被点击
    NSInteger section = collectionView.tag - 1000;
    NSInteger clickedCellRow = [self.clickedCell[section] integerValue];
    [cell setCellStatue:(clickedCellRow == indexPath.row)];
    
    return cell;
}

// Item 的 Size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableArray *rowsArr = self.itemsTitle[indexPath.section];
    
    NSString *title = rowsArr[indexPath.row];
    
    NSLog(@"%@",title);
    
    return [title sizeWithFont:[UIFont systemFontOfSize:20] maxSize:CGSizeMake(MAXFLOAT, ITEM_HEIGHT)];
}

// 点击方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = collectionView.tag - 1000;
    
    
    NSInteger clickedCellRow = [self.clickedCell[section] integerValue];
    
    if(clickedCellRow != indexPath.row){
        
        NSIndexPath *preIndexPath = [NSIndexPath indexPathForRow:clickedCellRow inSection:indexPath.section];
        ItemCollectionViewCell *preCell = (ItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:preIndexPath];
        
        ItemCollectionViewCell *nowCell = (ItemCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        [preCell setCellStatue:NO];
        [nowCell setCellStatue:YES];
        
        self.clickedCell[section] = [NSString stringWithFormat:@"%ld",indexPath.row];
    }
    [self.delegate multiConditionView:self didSelectItemAtSection:section Item:indexPath.row];
}


- (void)bottomAction:(UIButton *)sender{
    
    NSLog(@"点击");
    
    if(!sender.selected){
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, BOTTOM_HEIGHT);
            
            self.conditionView.alpha = 0;
            
            sender.frame = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
            sender.center = CGPointMake(self.frame.size.width / 2, self.bottom.center.y);
            
        } completion:^(BOOL finished) {
            
//            [self hidenConditionView:YES];
            
        }];
    }
    else{
        
//        [self hidenConditionView:NO];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, BOTTOM_HEIGHT + ITEM_HEIGHT * self.section);
            
            self.conditionView.alpha = 1;
            
            sender.frame = CGRectMake(0, ITEM_HEIGHT * self.section, 50, BOTTOM_HEIGHT);
            sender.center = CGPointMake(self.frame.size.width / 2, self.bottom.center.y);
        }];
        
    }
    sender.selected = !sender.selected;
}



- (void)reloadConditionView{
    
    
}


- (void)hidenConditionView:(BOOL)isHiden{
    
    if(isHiden){
        
        self.conditionView.hidden = YES;
        
        for (UIView *subView in self.conditionView.subviews) {
            
            subView.hidden = YES;
            
        }
    }
    else{
        self.conditionView.hidden = NO;
        
        for (UIView *subView in self.conditionView.subviews) {
            
            subView.hidden = NO;
            
        }
    }
}



@end
