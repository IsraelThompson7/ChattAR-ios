//
//  ChatRoomsViewController.h
//  Chattar
//
//  Created by kirill on 2/20/13.
//
//

#import <UIKit/UIKit.h>
#import "BackgroundWorker.h"
#import "CustomTabBarController.h"
#import "Helper.h"
#import "MessagesViewController.h"
#import "ChatRoomsStorage.h"
#import "Storage.h"
#import "ChatViewController.h"

#define NUMBER_OF_ROWS_BY_DEFAULT 2
#define NEARBY_SECTION_INDEX 1 
#define TRENDING_SECTION_INDEX 2
@interface ChatRoomsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UINavigationControllerDelegate>{
    NSMutableIndexSet* expandedSections;
}

@property (retain, nonatomic) IBOutlet UITableView *roomsTableView;
@property (retain, nonatomic) IBOutlet UITextField *newConversationTextField;
- (IBAction)startButtonTap:(UIButton *)sender;

@property (nonatomic, retain) UINavigationController* dialogsController;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end
enum TableSections {
    mainChatSection = 0,
    trendingSection = 1,
    nearbySection = 2
};