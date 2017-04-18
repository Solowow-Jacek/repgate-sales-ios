//
//  ProviderDetailViewController.h
//  repgateSales
//
//  Created by Helminen Sami on 3/26/17.
//  Copyright © 2017 developer. All rights reserved.
//

#import "RootViewController.h"
#import "Common.h"
#import "ClientInfo.h"

@interface ProviderDetailViewController : RootViewController

@property (nonatomic, strong) ClientInfo *providerInfo;

@end
