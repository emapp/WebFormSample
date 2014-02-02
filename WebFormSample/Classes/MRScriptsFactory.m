#import "MRScriptsFactory.h"

static NSString *const kMRScriptsBundleName = @"MRResources.bundle";

@implementation MRScriptsFactory

+ (NSString *)loadScriptWithName:(NSString *)scriptFileName {
    NSString *path = [NSBundle.mainBundle pathForResource:[kMRScriptsBundleName stringByAppendingPathComponent:scriptFileName] ofType:nil];
    return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)jqueryScript {
    return [self loadScriptWithName:@"jquery-2.0.3.min.js"];
}

+ (NSString *)fillFormScript {
    return [self loadScriptWithName:@"fill-form.js"];
}

@end