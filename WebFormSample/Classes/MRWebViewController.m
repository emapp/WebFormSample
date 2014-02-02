#import "MRWebViewController.h"
#import "MRScriptsFactory.h"

@interface MRWebViewController () <UIWebViewDelegate>
@property (nonatomic, weak, readonly) UIWebView *webView;

@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, assign) BOOL hasForm;

@property (nonatomic, assign, getter = isScriptExecuting) BOOL scriptExecuting;
@end

@implementation MRWebViewController {
}

- (void)dealloc {
    [self.webView stopLoading];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    if (self) {
        _request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createWebView];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.alpha = 0.0;
}

- (void)createWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = UIColor.whiteColor;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    [self.view addSubview:webView];
    _webView = webView;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.hasForm) {
        NSLog(@"Installing jQuery at %@", webView.request.URL.absoluteString);
        [self.webView stringByEvaluatingJavaScriptFromString:[MRScriptsFactory jqueryScript]];
        self.hasForm = YES;
    } else if (self.isScriptExecuting) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 1.0;
        }];
        self.scriptExecuting = NO;
        [self fireBlockWithStatus:MRWebViewStatusSuccess];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self fireBlockWithStatus:MRWebViewStatusNetworkError];
}

- (void)reload {
    self.hasForm = NO;
    self.view.alpha = 0.0;
    [self.webView stopLoading];
    [self.webView loadRequest:self.request];

}

- (BOOL)searchWithString:(NSString *)searchString {
    BOOL result = NO;
    if (self.hasForm) {
        self.scriptExecuting = YES;

        NSString *actualString = [searchString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        NSString *script = [NSString stringWithFormat:[MRScriptsFactory fillFormScript], actualString];

        NSString *scriptResult = [self.webView stringByEvaluatingJavaScriptFromString:script];

        __autoreleasing NSError *error = nil;
        id object = [NSJSONSerialization JSONObjectWithData:[scriptResult dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

        result = (!error && [object isKindOfClass:[NSDictionary class]] && [object[@"success"] boolValue]);

        self.scriptExecuting = result;
    }

    return result;
}

- (void)fireBlockWithStatus:(MRWebViewStatus)status {
    if (self.completionBlock) {
        self.completionBlock(status);
    }
}
@end