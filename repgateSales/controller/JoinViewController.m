//
//  JoinViewController.m
//  repgateSales
//
//  Created by Helminen Sami on 3/26/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "JoinViewController.h"
#import "MainViewController.h"

@interface JoinViewController ()
{
    UserInfo *userInfo;
}

@property (weak, nonatomic) IBOutlet UITextField *txtJoinCode;
@property (weak, nonatomic) IBOutlet RoundButton *btnJoin;
@end

@implementation JoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    userInfo = [[ShardDataManager sharedDataManager] getUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onClickJoin:(id)sender {
    if (![_txtJoinCode.text isEqualToString:@""]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // fetch repos from web service
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:userInfo.ID forKey:@"userId"];
        [params setObject:_txtJoinCode.text forKey:@"peerCode"];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        NSLog(@"API_URL: %@", (BASE_URL @"join2user"));
        
        [manager POST: (BASE_URL @"join2user") parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSLog(@"responseObject: %@", responseObject);
            ResponseData *result = [[ResponseData alloc] initWithDictionary:responseObject];
            
            if ([result.success boolValue] == YES) {
                NSLog(@"responseObject: %@", responseObject);
                
                [self onBack:nil];
                
            } else {
                NSDictionary *dic = responseObject[@"error"];
                NSString *err = dic[@"err_msg"];
                [Common showAlert:@"Error" Message:err ButtonName:@"OK"];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //here is place for code executed in error case
            [Common showAlert:@"Error" Message:network_msg_error ButtonName:@"OK"];
            NSLog(@"Error: %@", [error localizedDescription]);
        }];
    } else {
        [Common showAlert:@"Error" Message:@"Please input doctor code." ButtonName:@"OK"];
    }
}
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickLogo:(id)sender {
    MainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainVcID"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
