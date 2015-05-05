

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"

@interface MKStoreManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
	NSMutableArray *purchasableObjects;
	MKStoreObserver *storeObserver;
}

@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) MKStoreObserver *storeObserver;
@property (nonatomic, retain) SKProductsRequest *productsRequest;

- (void) requestProductData;

- (void) buyFeatureRubies350; // expose product buying functions, do not expose
- (void) buyFeatureRubiesPRO;
- (void) buyFeatureRubies750;
- (void) buyFeatureRubies2000;
- (void) buyFeatureRubies4500;
- (void) buyFeatureRubies10000;

// do not call this directly. This is like a private method
- (void) buyFeature:(NSString*) featureId;

- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) provideContent: (NSString*) productIdentifier;

+ (MKStoreManager*)sharedManager;

+ (BOOL) feature350Purchased;
+ (BOOL) featurePROPurchased;
+ (BOOL) feature750Purchased;
+ (BOOL) feature2000Purchased;
+ (BOOL) feature4500Purchased;
+ (BOOL) feature10000Purchased;

+(void) loadPurchases;
+(void) updatePurchases;

//+(void) makePaidVersion;
//+(void) make10Persion;

-(void)restore;

@end
