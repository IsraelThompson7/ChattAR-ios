//
//  ChatViewController.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/27/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewTouch.h"
#import "AsyncImageView.h"
#import "CustomButtonWithQuote.h"
#import "WebViewController.h"
#import "MessagesViewController.h"
#import "CustomSwitch.h"
#import "CommonViewController.h"
#import "BackgroundWorker.h"

#import "Storage.h"
#import "ChatPointsStorage.h"
#import "ChatRoomsStorage.h"
#import "AsyncImageView.h"

#define tableIsUpdating 1011


@interface ChatViewController : CommonViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, QBActionStatusDelegate, UIScrollViewDelegate, FBServiceResultDelegate, UIWebViewDelegate,FBDataDelegate,ChatControllerDelegate, DataDelegate>{
    UIImage *messageBGImage;
    UIImage *messageBGImage2;
    UIImage *distanceImage;
    UIImage *distanceImage2;
    
    ViewTouch *backView;
	int page;

	BOOL isLoadingMoreMessages;
       
    BOOL isDataRetrieved;
    BOOL isPanelDisplayed;
    
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UITextField *messageField;
@property (nonatomic, retain) IBOutlet UITableView *messagesTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *sendMessageActivityIndicator;

@property (nonatomic, retain) NSString* quoteMark;
@property (nonatomic, retain) AsyncImageView* quotePhotoTop;

@property (nonatomic, assign) CustomSwitch *allFriendsSwitch;

@property (nonatomic, retain) Storage* dataStorage;

@property (nonatomic, retain) NSString* controllerReuseIdentifier;

- (IBAction)sendMessageDidPress:(id)sender;

- (void)refresh;

- (void)addQuote;

@end
