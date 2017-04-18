//
//  ProfileViewController.m
//  repgateProvider
//
//  Created by Helminen Sami on 3/3/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "ProfileViewController.h"
#import "VHBoomMenuButton.h"
#import "CreateRequestViewController.h"
#import "CreateMessageViewController.h"
#import "LoginViewController.h"
#import "NZCircularImageView.h"
#import "UIImage+Convenience.h"
#import "ScheduleViewController.h"

@interface ProfileViewController () <VHBoomDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate,UIAlertViewDelegate>
{
    UserInfo *userInfo;
    UIImage *postImage;
}

@property (weak, nonatomic) IBOutlet VHBoomMenuButton *btnMenu;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet RoundButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnSelImage;
@property (weak, nonatomic) IBOutlet NZCircularImageView *imgAvatar;
@property (weak, nonatomic) IBOutlet UITextField *txtAreaInterest;
@property (weak, nonatomic) IBOutlet UITextField *txtTelephone;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtCompany;
@property (weak, nonatomic) IBOutlet UILabel *txtCodeRole;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupMenu];
    
    userInfo = [[ShardDataManager sharedDataManager] getUserInfo];
    
    if (userInfo != nil)
    {
        if (![userInfo.logoUrl isEqualToString:@""]) {
            [self.imgAvatar setImageWithResizeURL:userInfo.logoUrl];
        }
        _txtName.text = userInfo.displayName;
        
        NSString *roleName = [Common sharedManager].roleArray[[userInfo.role integerValue]];
        _txtCodeRole.text = [NSString stringWithFormat:@"%@, %@", userInfo.userCode, roleName];
        
        _txtEmail.text = userInfo.email;
        if (![userInfo.officeAddr isEqual:[NSNull null]])
            _txtAddress.text = userInfo.officeAddr;
        if (![userInfo.phone isEqual:[NSNull null]])
            _txtTelephone.text = userInfo.phone;
        if (![userInfo.company isEqual:[NSNull null]])
            _txtCompany.text = userInfo.company;
    }
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

- (void)setupMenu {
    [self.btnMenu init];
    
    self.btnMenu.buttonEnum = VHButtonHam;
    self.btnMenu.piecePlaceEnum = VHPiecePlace_HAM_4;
    self.btnMenu.buttonPlaceEnum = VHButtonPlace_HAM_4;
    self.btnMenu.hamWidth = 0.1;
    self.btnMenu.hamHeight = 0.1;
    self.btnMenu.noBackground = YES;
    self.btnMenu.boomDelegate = self;
    
    [self.btnMenu addHamButtonBuilderBlock:^(VHHamButtonBuilder *builder) {
        builder.imageNormal = @"menu_icon_messege";
        builder.titleContent = @"Create Message";
        builder.titleNormalColor = [UIColor whiteColor];
        builder.buttonNormalColor = UIColorFromRGB(0x2196F3);
    }];
    [self.btnMenu addHamButtonBuilderBlock:^(VHHamButtonBuilder *builder) {
        builder.imageNormal = @"menu_icon_messege";
        builder.titleContent = @"Create Request";
        builder.titleNormalColor = [UIColor whiteColor];
        builder.buttonNormalColor = UIColorFromRGB(0x2196F3);
    }];
    [self.btnMenu addHamButtonBuilderBlock:^(VHHamButtonBuilder *builder) {
        builder.imageNormal = @"menu_icon_messege";
        builder.titleContent = @"Schedule";
        builder.titleNormalColor = [UIColor whiteColor];
        builder.buttonNormalColor = UIColorFromRGB(0x2196F3);
    }];
    [self.btnMenu addHamButtonBuilderBlock:^(VHHamButtonBuilder *builder) {
        builder.imageNormal = @"menu_icon_messege";
        builder.titleContent = @"Logout";
        builder.titleNormalColor = [UIColor whiteColor];
        builder.buttonNormalColor = [UIColor darkGrayColor];
    }];
}

// #pragma mark - Boom Menu delegate
- (void)onBoomClicked:(int)index {
    switch (index) {
        case 0:
        {
            CreateMessageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateMessageVcID"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            CreateRequestViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateRequestVcID"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:
        {
            ScheduleViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduleVcID"];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] ;
            alertView.alertViewStyle = UIAlertActionStyleDefault;
            [alertView show];
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //    UITextField * alertTextField = [alertView textFieldAtIndex:0];
    if (buttonIndex == 1) {
        [[ShardDataManager sharedDataManager] saveUserInfo:nil];
        [AppConfig setEmail:@""];
        [AppConfig setPassword:@""];
        [AppConfig setRememberFlag:[NSNumber numberWithInt:0]];
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginVcID"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//Rest API
- (void)fileUploadToServer {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSData *img = UIImagePNGRepresentation(postImage);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userInfo.ID forKey:@"userId"];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:(BASE_URL @"uploadAvatar") parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:img name:@"file" fileName:@"image.png" mimeType:@"image/png"];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"responseObject: %@", responseObject);
        ResponseData *result = [[ResponseData alloc] initWithDictionary:responseObject];
        
        if ([result.success boolValue] == YES) {
            NSLog(@"responseObject: %@", responseObject);
            NSDictionary *dic = responseObject[@"data"];
            NSString *url = dic[@"url"];
            [self.imgAvatar setImageWithResizeURL:url];
            
        } else {
            NSDictionary *dic = responseObject[@"error"];
            NSString *err = dic[@"err_msg"];
            [Common showAlert:@"Error" Message:err ButtonName:@"OK"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //here is place for code executed in error case
        [Common showAlert:@"Error" Message:network_msg_error ButtonName:@"OK"];
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
}

- (IBAction)onClickSave:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userInfo.ID forKey:@"userId"];
    [params setObject:_txtName.text forKey:@"displayName"];
    [params setObject:_txtTelephone.text forKey:@"phone"];
    [params setObject:_txtAddress.text forKey:@"officeAddr"];
    [params setObject:@"" forKey:@"education"];
    [params setObject:@"" forKey:@"certifications"];
    [params setObject:@"" forKey:@"award"];
    [params setObject:@"allow" forKey:@"block_allow_message"];
    [params setObject:@"allow" forKey:@"block_allow_request"];
    [params setObject:_txtCompany.text forKey:@"company"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST: (BASE_URL @"updateProfile") parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"responseObject: %@", responseObject);
        ResponseData *result = [[ResponseData alloc] initWithDictionary:responseObject];
        
        if ([result.success boolValue] == YES) {
            NSLog(@"responseObject: %@", responseObject);
            UserInfo *info = [[UserInfo alloc] initWithDictionary:responseObject[@"data"]];
            [[ShardDataManager sharedDataManager] saveUserInfo:info];
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

- (IBAction)onClickSelImage:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take A Photo", @"Select from Gallery", nil];
    
    [actionSheet showInView:self.view];
}

#pragma actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 2 ) {
        UIImagePickerController *pickercontroller = [[UIImagePickerController alloc] init];
        [pickercontroller setDelegate:self];
        [pickercontroller setAllowsEditing:YES];
        
        if (buttonIndex == 0) { // take photo
            [pickercontroller setSourceType:UIImagePickerControllerSourceTypeCamera];
        } else if (buttonIndex == 1) { // select from library
            [pickercontroller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self presentViewController:pickercontroller animated:YES completion:nil];
        }];
    }
}

#pragma image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    postImage = [info valueForKey:UIImagePickerControllerEditedImage];
    postImage = [postImage getCroppedImage:IMAGE_SIZE_NORMAL height:IMAGE_SIZE_NORMAL];
    if (postImage != nil) {
        [self fileUploadToServer];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
