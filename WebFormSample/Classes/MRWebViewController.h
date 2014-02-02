#import <Foundation/Foundation.h>


typedef enum {
    MRWebViewStatusNetworkError,
    MRWebViewStatusSuccess,
} MRWebViewStatus;

@interface MRWebViewController : UIViewController

@property (nonatomic, copy) void (^completionBlock)(MRWebViewStatus status);
@property (nonatomic, assign, readonly) BOOL hasForm;
- (instancetype)initWithURLString:(NSString *)urlString;

- (void)reload;
- (BOOL)searchWithString:(NSString *)searchString;

@end