//
//  SignUpViewController.m
//  repgateSales
//
//  Created by Helminen Sami on 3/26/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "SignUpViewController.h"
#import "HTAutocompleteTextField.h"
#import "HTAutocompleteManager.h"
#import "MainViewController.h"
#import "LoginViewController.h"

@interface SignUpViewController ()
{
    NSString *deviceToken;
}

@property (weak, nonatomic) IBOutlet HTAutocompleteTextField *txtName;
@property (weak, nonatomic) IBOutlet HTAutocompleteTextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet RoundButton *btnSignUp;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    deviceToken = [AppConfig getDeviceToken];
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
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onClickLogo:(id)sender {
//    MainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainVcID"];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onClickSignUp:(id)sender {
    if ([_txtName.text isEqualToString:@""]) {
        [Common showAlert:@"Error" Message:@"Please input user name." ButtonName:@"OK"];
        return;
    }
    if ([_txtName.text isEqualToString:@""]) {
        [Common showAlert:@"Error" Message:@"Please input email address." ButtonName:@"OK"];
        return;
    }
    if ([_txtName.text isEqualToString:@""]) {
        [Common showAlert:@"Error" Message:@"Please input password." ButtonName:@"OK"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // fetch repos from web service
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_txtEmail.text forKey:@"email"];
    [params setObject:_txtPassword.text forKey:@"password"];
    [params setObject:deviceToken forKey:@"deviceId"];
    [params setObject:[NSString stringWithFormat:@"%d", USER_DEVICE_TYPE_IOS] forKey:@"deviceType"];
    [params setObject:[NSString stringWithFormat:@"%d", USER_ROLE_SALES_REP] forKey:@"role"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"API_URL: %@", (BASE_URL @"signup"));
    
    [manager POST: (BASE_URL @"signup") parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"responseObject: %@", responseObject);
        ResponseData *result = [[ResponseData alloc] initWithDictionary:responseObject];
        
        if ([result.success boolValue] == YES) {
            NSLog(@"responseObject: %@", responseObject);
            
            LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVcID"];
            [self.navigationController pushViewController:vc animated:YES];
            
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
}

@end
