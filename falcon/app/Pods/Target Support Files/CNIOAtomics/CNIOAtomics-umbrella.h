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

#import "CNIOAtomics.h"
#import "cpp_magic.h"

FOUNDATION_EXPORT double CNIOAtomicsVersionNumber;
FOUNDATION_EXPORT const unsigned char CNIOAtomicsVersionString[];

