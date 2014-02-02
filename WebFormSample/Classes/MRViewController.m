#import "MRViewController.h"
#import "MRWebViewController.h"

static NSString *const kMRHabraURLString = @"http://habrahabr.ru";

static CGFloat const kMRTextFieldWidth = 200;
static CGFloat const kMRTextFieldHeight = 31;
static CGFloat const kMRButtonSearchWidth = 80;
static CGFloat const kMRVerticalOffset = 100;
static CGFloat const kMRSpacing = 4;

@interface MRViewController () <UITextFieldDelegate>

@property (nonatomic, weak, readonly) UITextField *textField;
@property (nonatomic, weak, readonly) UIButton *buttonSearch;

@property (nonatomic, weak, readonly) MRWebViewController *webViewController;
@property (nonatomic, weak, readonly) UIActivityIndicatorView *indicatorView;
@end

@implementation MRViewController {
}

- (void)dealloc {
    [self.webViewController removeObserver:self forKeyPath:@"hasForm"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self createForm];
    [self createWebViewController];
    [self createActivityIndicator];

    [self createResetButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)createResetButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Заново", nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(reset)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)createWebViewController {
    MRWebViewController *controller = [[MRWebViewController alloc] initWithURLString:kMRHabraURLString];
    [self addChildViewController:controller];

    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];

    [controller didMoveToParentViewController:self];

    __weak typeof(self) weakSelf = self;
    controller.completionBlock = ^(MRWebViewStatus status) {
        [weakSelf handleWebViewControllerStatus:status];
    };

    _webViewController = controller;
    [self.webViewController addObserver:self forKeyPath:@"hasForm" options:0 context:nil];
    [self.webViewController reload];
}

- (void)createForm {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, kMRTextFieldWidth, kMRTextFieldHeight)];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:textField];
    _textField = textField;

    UIButton *buttonSearch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonSearch.frame = CGRectMake(0, 0, kMRButtonSearchWidth, kMRTextFieldHeight);
    [buttonSearch setTitle:NSLocalizedString(@"Искать", nil) forState:UIControlStateNormal];
    [buttonSearch addTarget:self action:@selector(didTouchButtonSearch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonSearch];
    _buttonSearch = buttonSearch;
}

- (void)createActivityIndicator {
    UIView *holderView = [[UIView alloc] initWithFrame:self.view.bounds];
    holderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    holderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    holderView.hidden = YES;

    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    indicatorView.hidesWhenStopped = YES;
    indicatorView.center = holderView.center;
    [holderView addSubview:indicatorView];
    _indicatorView = indicatorView;

    [self.view addSubview:holderView];
}

- (void)showIndicator:(BOOL)show {
    self.indicatorView.superview.hidden = !show;
    if (show) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect buttonSearchFrame = self.buttonSearch.frame;
    CGRect textFieldFrame = self.textField.frame;

    textFieldFrame.origin.x = (self.view.bounds.size.width - (textFieldFrame.size.width + kMRSpacing + buttonSearchFrame.size.width)) / 2;
    textFieldFrame.origin.y = kMRVerticalOffset;
    self.textField.frame = textFieldFrame;

    buttonSearchFrame.origin.x = CGRectGetMaxX(textFieldFrame) + kMRSpacing;
    buttonSearchFrame.origin.y = textFieldFrame.origin.y;
    self.buttonSearch.frame = buttonSearchFrame;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self search];
    return NO;
}

- (void)didTouchButtonSearch:(UIButton *)button {
    [self search];
}

- (void)handleWebViewControllerStatus:(MRWebViewStatus)status {
    [self showIndicator:NO];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webViewController && [keyPath isEqualToString:@"hasForm"]) {
        if (self.indicatorView.isAnimating) {
            [self doFillForm];
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)search {
    if (!self.textField.text.length) {
        return;
    }

    [self.textField resignFirstResponder];

    [self showIndicator:YES];
    if (self.webViewController.hasForm) {
        [self doFillForm];
    }
}

- (void)doFillForm {
    if (self.textField.text.length) {
        [self.webViewController searchWithString:self.textField.text];
    }
}

- (void)reset {
    [self.webViewController reload];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
@end