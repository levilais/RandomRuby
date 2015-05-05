

#import "MKStoreManager.h"
#import "AppDelegate.h"
#import "Global.h"

@implementation MKStoreManager

@synthesize purchasableObjects;
@synthesize storeObserver;

// all your features should be managed one and only by StoreManager

static NSString *feature350Id   = @"RubiesD350";
static NSString *featurePROId   = @"ProAndRubiesD500";
static NSString *feature750Id   = @"RubiesD750";
static NSString *feature2000Id  = @"RubiesD2000";
static NSString *feature4500Id  = @"RubiesD4500";
static NSString *feature10000Id = @"RubiesD10000";

BOOL feature350Purchased    = NO;
BOOL featurePROPurchased    = NO;
BOOL feature750Purchased    = NO;
BOOL feature2000Purchased   = NO;
BOOL feature4500Purchased   = NO;
BOOL feature10000Purchased  = NO;

static MKStoreManager* _sharedStoreManager; // self

- (void)dealloc
{
	//[super dealloc];
}

+ (BOOL) feature350Purchased {
	return feature350Purchased;
}

+ (BOOL) featurePROPurchased {
	return featurePROPurchased;
}

+ (BOOL) feature750Purchased {
	return feature750Purchased;
}

+ (BOOL) feature2000Purchased {
	return feature2000Purchased;
}

+ (BOOL) feature4500Purchased {
	return feature4500Purchased;
}

+ (BOOL) feature10000Purchased {
	return feature10000Purchased;
}

+ (MKStoreManager*)sharedManager
{
	NSLog(@"pass sharedManager");
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];			
			[_sharedStoreManager requestProductData];
			
			[MKStoreManager loadPurchases];
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    
    return _sharedStoreManager;
}

#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (_sharedStoreManager == nil)
        {
            _sharedStoreManager = [super allocWithZone:zone];
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }

    return nil; //on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

//- (id)retain
//{	
//    return self;	
//}

//- (unsigned)retainCount
//{
//    return UINT_MAX;  //denotes an object that cannot be released
//}

//- (void)release
//{
//    //do nothing
//}

//- (id)autorelease
//{
//    return self;	
//}


- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects: feature350Id, featurePROId, feature750Id, feature2000Id, feature4500Id, feature10000Id, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[purchasableObjects addObjectsFromArray:response.products];
	// populate your UI Controls here
	for (int i = 0; i < [purchasableObjects count]; i++)
	{
		
		SKProduct *product = [purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle], [[product price] doubleValue], [product productIdentifier]);
	}
	
	//[request autorelease];
}

- (void) buyFeature:(NSString*) featureId
{
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Random Ruby" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		//[alert release];
	}
}

- (void) buyFeatureRubies350
{
	[self buyFeature:feature350Id];
}

- (void) buyFeatureRubiesPRO
{
	[self buyFeature:featurePROId];
}

- (void) buyFeatureRubies750
{
	[self buyFeature:feature750Id];
}

- (void) buyFeatureRubies2000
{
	[self buyFeature:feature2000Id];
}

- (void) buyFeatureRubies4500
{
	[self buyFeature:feature4500Id];
}

- (void) buyFeatureRubies10000
{
	[self buyFeature:feature10000Id];
}


- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	//[alert release];
}

-(void) provideContent: (NSString*) productIdentifier
{
	if([productIdentifier isEqualToString:feature350Id])
    {
		feature350Purchased = YES;
        g_GameInfo.rubyCounts += 350;
        saveGameInfo();
        
        trackFlurryForBuyRubies(@"You purchased 350 rubies.");
    }
    if([productIdentifier isEqualToString:featurePROId])
    {
		featurePROPurchased = YES;
        if (!g_bRestore) {
            g_GameInfo.rubyCounts += 500;
            trackFlurryForBuyRubies(@"You purchased Random Ruby PRO and 500 rubies.");
        }
        g_GameInfo.proVersion = true;
        saveGameInfo();
    }
    if([productIdentifier isEqualToString:feature750Id])
    {
		feature750Purchased = YES;
        g_GameInfo.rubyCounts += 750;
        saveGameInfo();
        
        trackFlurryForBuyRubies(@"You purchased 750 rubies.");
    }
    if([productIdentifier isEqualToString:feature2000Id])
    {
		feature2000Purchased = YES;
        g_GameInfo.rubyCounts += 2000;
        saveGameInfo();
        
        trackFlurryForBuyRubies(@"You purchased 2,000 rubies.");
    }
	
    if([productIdentifier isEqualToString:feature4500Id])
    {
		feature4500Purchased = YES;
        g_GameInfo.rubyCounts += 4500;
        saveGameInfo();
        
        trackFlurryForBuyRubies(@"You purchased 4,500 rubies.");
    }
	
    if([productIdentifier isEqualToString:feature10000Id])
    {
		feature10000Purchased = YES;
        g_GameInfo.rubyCounts += 10000;
        saveGameInfo();
        
        trackFlurryForBuyRubies(@"You purchased 10,000 rubies.");
    }
	
	[MKStoreManager updatePurchases];
    
    // Update interface
    if (g_StoreViewer != nil) {
        [g_StoreViewer refreshRubyCount];
    }
    if (g_InfoViewer != nil) {
        [g_InfoViewer refreshRubyCount];
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"In-App Upgrade" message:@"Successfully Purchased" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    //[alert release];
}

+(void) loadPurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];	
	feature350Purchased = [userDefaults boolForKey:feature350Id];
	featurePROPurchased = [userDefaults boolForKey:featurePROId];
    feature750Purchased = [userDefaults boolForKey:feature750Id];
    feature2000Purchased = [userDefaults boolForKey:feature2000Id];
    feature4500Purchased = [userDefaults boolForKey:feature4500Id];
    feature10000Purchased = [userDefaults boolForKey:feature10000Id];
}

+(void) updatePurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setBool:feature350Purchased forKey:feature350Id];
    [userDefaults setBool:featurePROPurchased forKey:featurePROId];
    [userDefaults setBool:feature750Purchased forKey:feature750Id];
    [userDefaults setBool:feature2000Purchased forKey:feature2000Id];
    [userDefaults setBool:feature4500Purchased forKey:feature4500Id];
    [userDefaults setBool:feature10000Purchased forKey:feature10000Id];
}

-(void)restore
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    g_bRestore = true;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
}

@end
