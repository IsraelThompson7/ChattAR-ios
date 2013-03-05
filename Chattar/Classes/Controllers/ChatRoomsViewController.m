//
//  ChatRoomsViewController.m
//  Chattar
//
//  Created by kirill on 2/20/13.
//
//

#import "ChatRoomsViewController.h"
#import "ChatRoom.h"
#import "DataManager.h"


@interface ChatRoomsViewController ()

@end

@implementation ChatRoomsViewController
@synthesize dialogsController;
@synthesize loadingIndicator = _loadingIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Chat Rooms", @"Chat Rooms");
        self.tabBarItem.image = [UIImage imageNamed:@"dialogsTab.png"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doReceiveChatRooms) name:kDataIsReadyForDisplaying object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doNeedDisplayChatRoomsController) name:kNeedToDisplayChatRoomController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doCreateNewRoom) name:kNewChatRoomCreated object:nil];
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_newConversationTextField setDelegate:self];
    
    UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                      NSLocalizedString(@"Pick your chat",nil),
                                                                                      NSLocalizedString(@"My Dialogs",nil),
                                                                                      nil]];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setFrame:CGRectMake(20, 7, 280, 30)];
    [segmentedControl addTarget:self action:@selector(segmentValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
    [segmentedControl release];
    
    [segmentedControl setSelectedSegmentIndex:0];
    
    MessagesViewController* messagesVC = [[MessagesViewController alloc] initWithNibName:@"MessagesViewController" bundle:nil];
    
    dialogsController = [[UINavigationController alloc] initWithRootViewController:messagesVC];
    [messagesVC release];
    dialogsController.navigationBarHidden = YES;
    
    [dialogsController setDelegate:self];
    
    expandedSections = [[NSMutableIndexSet alloc] init];
}

-(void)viewWillAppear:(BOOL)animated{
    if ([DataManager shared].qbChatRooms.count == 0 && [DataManager shared].roomsWithAdditionalInfo.count == 0) {
        [[BackgroundWorker instance] requestAdditionalChatRoomsInfo];
        [self addSpinner];
        
        // additional request for checkins
        if ([DataManager shared].allCheckins.count == 0) {
            [[BackgroundWorker instance] retrieveCachedFBCheckinsAndRequestNewCheckins];
        }        
    }
    else
        [_roomsTableView reloadData];
    
    [self.roomsTableView deselectRowAtIndexPath:[self.roomsTableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_roomsTableView release];
    [_newConversationTextField release];
    [dialogsController release];
    [_loadingIndicator release];
    [expandedSections release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setRoomsTableView:nil];
    [self setNewConversationTextField:nil];
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}
- (IBAction)startButtonTap:(UIButton *)sender {
    NSString* roomName = _newConversationTextField.text;
    if ([Helper isStringCorrect:roomName]) {
        [[BackgroundWorker instance] createChatRoom:roomName];
    }
}

#pragma mark -
#pragma mark Interface based methods

-(void)showChatController{
    ChatRoomsStorage* dataStorage = [[[ChatRoomsStorage alloc] init] autorelease];

    ChatViewController* chatViewController = [[[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil] autorelease];
    [chatViewController setDataStorage:dataStorage];
    
    chatViewController.controllerReuseIdentifier = [[NSString alloc] initWithString:chatRoomsViewControllerIdentifier];
    chatViewController.title = NSLocalizedString([DataManager shared].currentChatRoom.roomName, nil);
    [self.navigationController pushViewController:chatViewController animated:NO];

}

- (BOOL)canCollapseSection:(NSInteger)section
{
    if (section == nearbySection) {
        return ([DataManager shared].nearbyRooms.count > 2);
    }
    else if (section == trendingSection){
        return ([DataManager shared].trendingRooms.count > 2);
    }
    
    return NO;
}

-(void)addSpinner{
    if (!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    if (![self.view viewWithTag:INDICATOR_TAG]) {
        [self.view addSubview:_loadingIndicator];
        [_loadingIndicator startAnimating];
    }
    
    _loadingIndicator.center = self.view.center;
    [self.view bringSubviewToFront:_loadingIndicator];
    
    [_loadingIndicator setTag:INDICATOR_TAG];
}

-(UIView*)createHeaderForSection:(NSInteger)section{
    UILabel* header = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    [header setBackgroundColor:[UIColor clearColor]];
    [header setTextColor:[UIColor whiteColor]];
    CGSize titleViewSize;
    
    switch (section) {
        case mainChatSection:{
            [header setText:@"Main"];
        }
            break;
        case trendingSection:{
            [header setText:@"Trending"];
        }
            break;
            
        case nearbySection:{
            [header setText:@"Nearby"];
        }
            break;
            
        default:
            break;
    }
    
    titleViewSize = [header.text sizeWithFont:header.font];
    [header setFrame:CGRectMake(10, 5, titleViewSize.width, titleViewSize.height)];
    UIView* sectionTitleView = [[[UIView alloc] initWithFrame:CGRectMake(20, 0, titleViewSize.width + 20, 30)] autorelease];
    
    
    [sectionTitleView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"headerBGColor"]]];
    [sectionTitleView.layer setCornerRadius:8];

    [sectionTitleView addSubview:header];
    
    UIImageView* viewForHeaderInSection = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.roomsTableView.bounds.size.width, 30)] autorelease];
    [viewForHeaderInSection addSubview:sectionTitleView];
    
    UILabel* seeAllText = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    [seeAllText setBackgroundColor:[UIColor clearColor]];
    CGSize seeAllTextSize = [@"See All" sizeWithFont:seeAllText.font];
    
    [seeAllText setFrame:CGRectMake(_roomsTableView.bounds.size.width-95, 5, seeAllTextSize.width, seeAllTextSize.height)];
    [seeAllText setTextColor:[UIColor grayColor]];
    [seeAllText setText:@"See All"];
    [viewForHeaderInSection addSubview:seeAllText];
    
    UIButton* seeAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [seeAllButton setFrame:CGRectMake(_roomsTableView.bounds.size.width-40, 5, 20, 20)];
    [seeAllButton setImage:[UIImage imageNamed:@"seeAllButton.png"] forState:UIControlStateNormal];
    
    if (section == nearbySection) {
        [seeAllButton setTag:NEARBY_SECTION_INDEX];
    }
    else if (section == trendingSection){
        [seeAllButton setTag:TRENDING_SECTION_INDEX];
    }
    
    [seeAllButton addTarget:self action:@selector(expandSection:) forControlEvents:UIControlEventTouchDown];
    [viewForHeaderInSection addSubview:seeAllButton];
    [viewForHeaderInSection bringSubviewToFront:seeAllButton];
    [viewForHeaderInSection setUserInteractionEnabled:YES];
    
    return viewForHeaderInSection;
}

-(void)segmentValueDidChanged:(UISegmentedControl*)sender{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self showChats];
            break;
            
        case 1:
            [self showDialogs];
            break;
            
        default:
            break;
    }
}

-(void)expandSection:(UIButton*)sender{
    NSInteger currentSection = -1;
                    // determine section
    if (sender.tag == NEARBY_SECTION_INDEX) {
        currentSection = nearbySection;
    }

    else if (sender.tag == TRENDING_SECTION_INDEX){
        currentSection = trendingSection;
    }
    
    if ([self canCollapseSection:currentSection]) {
        BOOL currentlyExpanded = [expandedSections containsIndex:currentSection];
        
        NSInteger rows;
        
        NSMutableArray *tmpArray = [NSMutableArray array];
        
        if (currentlyExpanded){
            rows = [self tableView:_roomsTableView numberOfRowsInSection:currentSection];
            [expandedSections removeIndex:currentSection];
        }
        
        else{
            [expandedSections addIndex:currentSection];
            rows = [self tableView:_roomsTableView numberOfRowsInSection:currentSection];
        }
        
        for (int i = NUMBER_OF_ROWS_BY_DEFAULT; i < rows; i++){
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i
                                                           inSection:currentSection];
            [tmpArray addObject:tmpIndexPath];
        }
        
        if (currentlyExpanded) {
            [_roomsTableView deleteRowsAtIndexPaths:tmpArray withRowAnimation:UITableViewRowAnimationTop];
        }
        else{
            [_roomsTableView insertRowsAtIndexPaths:tmpArray withRowAnimation:UITableViewRowAnimationTop];
        }
        
    }
}

-(void)showChats{
    if ([dialogsController.view superview]) {
        [dialogsController.view removeFromSuperview];
    }
    
}

-(void)showDialogs{
    if ([dialogsController.view superview] == nil) {
        [self.view addSubview:dialogsController.view];
    }
    
}

#pragma mark -
#pragma mark UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([self canCollapseSection:section])
    {
        if ([expandedSections containsIndex:section])
        {
            if (section == nearbySection) {
                return [DataManager shared].nearbyRooms.count;
            }
            else if (section == trendingSection){
                return [DataManager shared].trendingRooms.count;
            }
        }
        
        return NUMBER_OF_ROWS_BY_DEFAULT; 
    }
    
    return (section == mainChatSection) ? 1 : NUMBER_OF_ROWS_BY_DEFAULT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    switch (indexPath.section) {
        case trendingSection:{
            if (indexPath.row < [DataManager shared].trendingRooms.count) {
                ChatRoom* room = [[DataManager shared].trendingRooms objectAtIndex:indexPath.row];
                NSString* cellText = [NSString stringWithFormat:@"%@",room.roomName];
                UIImageView* accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"occupantsCounter.png"]] autorelease];
                UILabel* counter = [[[UILabel alloc] initWithFrame:CGRectMake(20, -1, 20, 20)] autorelease];
                [counter setText:[NSString stringWithFormat:@"%d",room.roomUsers.count]];
                [counter setBackgroundColor:[UIColor clearColor]];
                [accessoryView addSubview:counter];
                [cell setAccessoryView:accessoryView];
                [cell.textLabel setText:cellText];
                
            }
            break;
        }
        case nearbySection:{
            if (indexPath.row < [DataManager shared].nearbyRooms.count) {
                ChatRoom* room = [[DataManager shared].nearbyRooms objectAtIndex:indexPath.row];
                NSString* cellText = [NSString stringWithFormat:@"%d miles",(int)room.distanceFromUser];
                UIImageView* accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"occupantsCounter.png"]] autorelease];
                UILabel* counter = [[[UILabel alloc] initWithFrame:CGRectMake(20, -1, 20, 20)] autorelease];
                [counter setBackgroundColor:[UIColor clearColor]];
                [counter setText:[NSString stringWithFormat:@"%d",room.roomUsers.count]];
                [accessoryView addSubview:counter];
                [cell setAccessoryView:accessoryView];
                [cell.textLabel setText:cellText];
            }
            break;
        }
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self createHeaderForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

    UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    ChatRoom* selectedChatRoomWithAdditionalInfo = [[DataManager shared] findRoomWithAdditionalInfo:selectedCell.textLabel.text];
    QBChatRoom* selectedChatRoom = [[DataManager shared] findQBRoomWithName:selectedCell.textLabel.text];
    
//    int index = 0;
//    
//    switch (indexPath.section) {
//        case trendingSection:
//            indexPath.
//            break;
//        
//        case nearbySection:
//            break;
//            
//        default:
//            break;
//    }
//    
    
    if (selectedChatRoomWithAdditionalInfo) {
        
        if (![DataManager shared].currentChatRoom) {
            [DataManager shared].currentChatRoom = [[ChatRoom alloc] init];
            [DataManager shared].currentChatRoom.isSendingMessage = NO;
        }
        
        // save current chat room
        [DataManager shared].currentChatRoom = selectedChatRoomWithAdditionalInfo;
    }

    
    if (![selectedChatRoom isJoined]) {
        if (selectedChatRoom) {
            [[BackgroundWorker instance] joinRoom:selectedChatRoom];
        }
    }
    else{
        [self doNeedDisplayChatRoomsController];
    }
    
}

#pragma mark -
#pragma mark Notifications Reactions

-(void)doCreateNewRoom{
    [self showChatController];
}

-(void)doReceiveChatRooms{
    [(UIActivityIndicatorView*)([self.view viewWithTag:INDICATOR_TAG]) removeFromSuperview];
    
    [_roomsTableView reloadData];
}

-(void)doNeedDisplayChatRoomsController{
    [self showChatController];
}

#pragma mark -
#pragma mark UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_newConversationTextField resignFirstResponder];
    return YES;
}

#pragma mark - 
#pragma mark UINavigationControllerDelegate methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [viewController viewWillAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [viewController viewDidAppear:animated];
}

@end
