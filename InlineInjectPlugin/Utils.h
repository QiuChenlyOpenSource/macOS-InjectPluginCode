#ifdef __cplusplus
	extern "C" {
#endif

#include <objc/runtime.h>
#import <mach-o/dyld.h>
#import <SwiftUI/SwiftUI.h>
#import "rd_route.h"

int bypass1(void);

BOOL hookPtr(uint32_t imageIndex, intptr_t addr, void *replaceMethod, void **retOriginalFunctionAddress);

BOOL hookPtrZ(intptr_t addr, void *replaceMethod, void **retOriginalFunctionAddress);

BOOL hookPtrA(intptr_t addr, void *replaceMethod);

void switchMethod(Method original, Method new);

Method getMethod(Class _Nullable cls, SEL _Nonnull name);

Method getMethodStr(NSString *cls, NSString *name);

Method getMethodByCls(Class _Nullable cls, SEL _Nonnull name);

Method getMethodStrByCls(NSString *cls, NSString *name);

uint32_t getImageVMAddrSlideIndex(char* ModuleName);

IMP setMethod(Method m, IMP imp);
IMP getMethodImplementation(Class cls, SEL name);
Method getMethod(Class _Nullable cls, SEL _Nonnull name);

BOOL checkSelfInject(char *name);
BOOL checkAppVersion(char *checkVersion);
BOOL checkAppCFBundleVersion(char *checkVersion);
void initBaseEnv();


@interface Utils : NSObject


@end