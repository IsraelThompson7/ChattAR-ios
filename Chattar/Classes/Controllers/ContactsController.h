//
//  ContactsController.h
//  ChattAR for Facebook
//
//  Created by QuickBlox developers on 3/10/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBServiceResultDelegate.h"
#import "ViewTouch.h"
#import "MessagesViewController.h"

typedef enum
{
    CADefaultStyle = 0,
    CAMessagesStyle
}CAStyle;






@interface ContactsController : UIViewController <UITableViewDataSource, UITableViewDelegate, FBServiceResultDelegate, UISearchBarDelegate>
{
    
    // friends by sections
	NSMutableArray		*favoriteFriends;
	NSMutableArray		*onlineFriends;
	NSMutableArray		*offlineFriends;
	
	// back view fro hide keyboard
    ViewTouch			*backView;
	
	// search data
    NSMutableArray		*searchArray;
  
    
    CAStyle              controllerStyle;
    id <MessagesNavigationDelegate> delegate;
    
    BOOL isInitialized;
}

@property (retain, nonatomic) IBOutlet UITableView				*friendListTableView;
@property (retain, nonatomic) IBOutlet UISearchBar				*searchField;
@property (assign ,nonatomic)          CAStyle                  controllerStyle;
@property (assign, nonatomic)          id <MessagesNavigationDelegate> delegate;


@end
