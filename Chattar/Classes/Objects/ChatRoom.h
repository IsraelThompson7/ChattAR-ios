//
//  ChatRoom.h
//  Chattar
//
//  Created by kirill on 2/20/13.
//
//

#import <Foundation/Foundation.h>

@interface ChatRoom : NSObject
@property (nonatomic,retain) NSString* roomName;
@property (nonatomic, assign) CLLocationCoordinate2D ownerLocation;
@property (nonatomic,retain) NSString* roomID;
@property (nonatomic, retain) NSDate* createdAt;
@property (nonatomic, assign) double roomRating;
@property (nonatomic, assign) double distanceFromUser;
@property (nonatomic, retain) NSMutableArray* roomUsers;
@property (nonatomic, retain) NSMutableArray* messagesHistory;
@property (nonatomic, retain) NSMutableArray* usersPictures;
@property (nonatomic, retain) NSMutableArray* messagesAsUserAnnotationForDisplaying;
@property (nonatomic, assign) BOOL isSendingMessage;

+(ChatRoom*)createRoomWithAdditionalInfoWithName:(NSString*)_roomName coordinates:(CLLocationCoordinate2D)coordinates;
@end
