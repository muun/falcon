#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CNIOHTTPParser.h"
#import "c_nio_http_parser.h"

FOUNDATION_EXPORT double CNIOHTTPParserVersionNumber;
FOUNDATION_EXPORT const unsigned char CNIOHTTPParserVersionString[];

