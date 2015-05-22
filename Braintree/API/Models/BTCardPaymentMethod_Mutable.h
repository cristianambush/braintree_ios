#import "BTCardPaymentMethod.h"

@interface BTCardPaymentMethod ()

@property (nonatomic, readwrite, assign) BTCardType type;
@property (nonatomic, readwrite, copy) NSString *typeString;
@property (nonatomic, readwrite, copy) NSString *lastTwo;
@property (nonatomic, readwrite, strong) BTThreeDSecureInfo *threeDSecureInfo;

@end
