//
//  RIWS.h
//  RIWSFramework
//
//  Created by Sunilkarthick Sivabalan on 20/12/16.
//  Copyright © 2016 IndMex Aviation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


@protocol RIWSDelegate <NSObject>
-(void)RunwayIncrusionOccurredAtRunway:(NSString *)runwayName RunwayID:(NSString*)runwayID isTargetOnRunway:(BOOL)onRunway;
-(void)RunwayIncrusionRemovededFromRunway:(NSString *)runwayName RunwayID:(NSString*)runwayID;
@end

@interface RIWS : NSObject
{
    CLLocationCoordinate2D pLeftCoordinate,pMiddleCoordinate, pRightCoordinate, pmidLeftCoordinate, pmidMiddleCoordinate, pmidRightCoordinate;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (nonatomic, assign) double speed;
@property (nonatomic, assign) double heading;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, retain) NSString* lastPolygonName;
@property (nonatomic, retain) NSString* currentPolygonName;
@property (nonatomic, retain) NSString* currentPolygonGuid;
@property (nonatomic, strong) AVAudioPlayer *currentaudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *riwsaudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *holdshortaudioPlayer;
@property (nonatomic, assign) BOOL isHazardArea;
@property (nonatomic, assign) BOOL onRunway;
@property (nonatomic, assign) BOOL lastOnRunway;
@property (nonatomic, retain) NSMutableArray *polygons;
@property (nonatomic, weak) id <RIWSDelegate> delegate;

//Stomp declarations

@property (nonatomic, retain) NSString *stompServer;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL isSSL;
@property (nonatomic, retain) NSString *publishingTopic;
@property (nonatomic, assign) BOOL isConnected;

+(RIWS*)sharedManager;
-(BOOL)addPolygons:(NSString*)Polygon forPolygonGUID:(NSString*)polygonGuid PolygonName:(NSString*)polygonName isforceReplace:(BOOL)isReplace;
-(BOOL)removeAllPolygons;
-(BOOL)removePolygon:(NSString*)polygonGuid;
-(void)initializes;
- (void)checkPointinPolygonLatitude:(double)latitude Longitude:(double)longitude Speed:(double)speedKPH Heading:(double)heading;
-(void)playAudio:(BOOL)isRunway;

//Stomp usages
-(void)initStompwithServer:(NSString*)t_server Port:(int)t_port Login:(NSString*)t_login Password:(NSString*)t_password withSSL:(BOOL)t_ssl forPublishingat:(NSString*)t_publishTopic;
-(void)initSTOMP;

@end
