/*
 COPYRIGHT 2011 ESRI
 
 TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
 Unpublished material - all rights reserved under the
 Copyright Laws of the United States and applicable international
 laws, treaties, and conventions.
 
 For additional information, contact:
 Environmental Systems Research Institute, Inc.
 Attn: Contracts and Legal Services Department
 380 New York Street
 Redlands, California, 92373
 USA
 
 email: contracts@esri.com
 */

#import <Foundation/Foundation.h>
@protocol AGSPortalDelegate;
@protocol AGSPortalModelObject;
@class AGSPortalItem;
@class AGSPortalQueryParams;
@class AGSPortalUser;
@class AGSPortalGroup;
@class AGSPortalInfo;
@class AGSPortalQueryResultSet;
@protocol AGSSecuredResource;


/** @file AGSPortal.h */ //Required for Globals API doc

/** @brief An Object representing a Portal for ArcGIS
 
 AGSPortal is an object that represents a view for a user (anonymous or not) into an organization or 
 portal. www.ArcGIS.com is an example of a portal. A portal may contain sandboxed areas that are accessible only to an organization that owns them. 
 
 AGSPortal is the main class and the entry point into the API to work with portals and organizations. It implements all the operations to 
 interface with the backend REST API. It has a delegate @c AGSPortalDelegate that is informed when each 
 operation completes successfully or encounters an error. 
 
 @b Concepts:
 
 - Portals  allow users and  organizations to publish and share content over the web. 
 
 - A Portal has  Users (@c AGSPortalUser), Groups (@c AGSPortalGroup) and Content (@c AGSPortalItem).
 
 - A Portal may have users who are unaffiliated with an organization or users who are part of an 
 organization.
 
 - Users sign in to the portal and  create and share content which is organized into Items. The system 
 supports different types of items including web maps, map services (that can be used as layers in web 
 maps), applications (that are built around web maps) and data files (that can be uploaded and 
 downloaded).
 
 - Users can choose to keep content Private or to share it with other users via Groups or make content 
 Public and accessible to everyone.
 
 - Users can create and join Groups. Users can share items with Groups. This makes the items visible to 
 and accessible by the other members of the Group.
 
 - A Portal may contain multiple Organizations.
 
 - A user of the Portal (and of the REST API) sees the view off the Portal that applies to their 
 organization.  This view includes users, groups and items that belong to the organization and have been 
 shared with them. This view may also include users, groups and items that are external to the 
 organization and have been shared with the user.
 
 - An organization has users in different roles including administrators, publishers and  information 
 workers.
 
 - Administrators can add  users to  their organizations and have access to all content within the 
 organization.
 
 - All users can create web maps based  on mashing up services that they have access to and can register 
 services running on external servers.
 
 - Publishers within an organization can in addition create hosted services based on data files that they 
 upload.
 
 @see AGSPortalDelegate
 
 @since 2.2
 */
@interface AGSPortal : NSObject <AGSSecuredResource>

/** The URL of the portal.
 @since 2.2
 */
@property (nonatomic, retain, readonly) NSURL *URL;

/** The credential of the user for authenticated access. Can be nil, in which case it requests for anonymous access to the portal.
 @since 2.2
 */
@property (nonatomic, copy, readonly) AGSCredential *credential;

/** The delegate for the portal operations. 
 @since 2.2
 */
@property (nonatomic, assign, readwrite) id<AGSPortalDelegate> delegate;

/** Returned upon successful initialization of the portal. Contains details of the portal/organization as seen by the current user, anonymous or logged in. 
 @since 2.2
 */
@property (nonatomic, retain, readonly) AGSPortalInfo *portalInfo;

/** Represents the registered user of the portal/organization and is returned upon successful initialization of the portal with a credential. 
 @since 2.2
 */
@property (nonatomic, retain, readonly) AGSPortalUser *user;


/** Instantiates the AGSPortal and initiates a connection to the portal. It will fetch the portal properties and 
 user properties asynchronously and invoke the loaded/failed methods on @c AGSPortalDelegate. It is recommended you assign a delegate to ensure that the portal loaded properly.
 
 @param url The url for the portal. Eg, www.arcgis.com
 @param cred The credential of the user. Can be Nil if anonymous access is desired. 
 @since 2.2
 */
-(id)initWithURL:(NSURL *)url credential:(AGSCredential*)cred;

/** If the portal fails to load, you can resubmit it with a different URL and/or credential.
 This method will do nothing if the portal is already loaded.
 @param url The url for the portal. 
 @param cred The credential of the user. Can be Nil if anonymous access is desired. 
 @since 2.2
 */
-(void)resubmitWithURL:(NSURL*)url credential:(AGSCredential*)cred;

/** Kicks off an operation that finds items with query. Corresponding methods on the @c AGSPortalDelegate are invoked when the operation completes successfully or if an error is encountered.
 @param queryParams The query parameters to find items.  
 @since 2.2
 */
-(NSOperation*)findItemsWithQueryParams:(AGSPortalQueryParams*)queryParams;

/** Kicks off an operation that finds groups with query. Corresponding methods on the @c AGSPortalDelegate are invoked when the operation completes successfully or if an error is encountered.
 @param queryParams The query parameters to find groups.  
 @since 2.2
 */
-(NSOperation*)findGroupsWithQueryParams:(AGSPortalQueryParams*)queryParams;

@end




/** @brief A delegate of @c AGSPortal
 
 A protocol which must be adopted by a class wishing to serve as a delegate for AGSPortal. AGSPortal 
 informs the delegate when operations complete successfully or encounter an error.
 
 All of the methods of this protocol are optional.
 
 @since 2.2
 */
@protocol AGSPortalDelegate <NSObject>
@optional

/** Tells the delegate that the portal was loaded successfully.
 @param portal The portal that was loaded. 
 @since 2.2
 */
-(void)portalDidLoad:(AGSPortal*)portal;

/** Tells the delegate that an error was encountered while tyring to load the portal.
 @param portal 	The portal that failed to load.
 @param error Information about the cause of the failure. 
 @since 2.2
 */
-(void)portal:(AGSPortal*)portal didFailToLoadWithError:(NSError*)error;

/** Tells the delegate that the query to find items completed successfully. 
 @param portal The portal on which the query was made.
 @param op The operation that performed the query.
 @param resultSet The @c AGSPortalQueryResultSet containing the results as an array of @c AGSPortalItem
 @since 2.2
 */
-(void)portal:(AGSPortal*)portal operation:(NSOperation*)op didFindItems:(AGSPortalQueryResultSet*)resultSet;

/** Tells the delegate that an error was encountered while tyring to query items. 
 @param portal The portal on which the query was made.
 @param op The operation that performed the query. 
 @param queryParams The query parameters
 @param error Information about the cause of the failure.
 @since 2.2
 */
-(void)portal:(AGSPortal*)portal operation:(NSOperation*)op didFailToFindItemsForQueryParams:(AGSPortalQueryParams*)queryParams withError:(NSError*)error;

/** Tells the delegate that the query to find groups completed successfully. 
 @param portal The portal on which the query was made.
 @param op The operation that performed the query.
 @param resultSet The @c AGSPortalQueryResultSet containing the results as an array of @c AGSPortalGroup
 @since 2.2
 */
-(void)portal:(AGSPortal*)portal operation:(NSOperation*)op didFindGroups:(AGSPortalQueryResultSet*)resultSet;

/** Tells the delegate that an error was encountered while tyring to query groups. 
 @param portal The portal on which the query was made.
 @param op The operation that performed the query. 
 @param queryParams The query parameters
 @param error Information about the cause of the failure.
 @since 2.2
 */
-(void)portal:(AGSPortal*)portal operation:(NSOperation*)op didFailToFindGroupsForQueryParams:(AGSPortalQueryParams*)queryParams withError:(NSError*)error;

@end











