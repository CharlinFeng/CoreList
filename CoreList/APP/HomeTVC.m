//
//  HomeTVC.m
//  CoreLTVC
//
//  Created by 沐汐 on 15-3-10.
//  Copyright (c) 2015年 沐汐. All rights reserved.
//

#import "HomeTVC.h"
#import "HomeModel.h"
#import "ShopListTVC.h"
#import "TGListCVC.h"

@interface HomeTVC ()


@property (nonatomic,strong) NSArray *dataList;


@end




@implementation HomeTVC

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    HomeModel *m1=[HomeModel modelWithName:@"tableView" VCClass:[ShopListTVC class]];
    HomeModel *m2=[HomeModel modelWithName:@"collectionView" VCClass:[TGListCVC class]];
    
    self.dataList=@[m1,m2];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *rid=@"rid";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:rid];
    
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rid];
    }
    
    cell.textLabel.text=[self.dataList[indexPath.row] name];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIViewController *vc=[[[self.dataList[indexPath.row] VCClass] alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}



@end
