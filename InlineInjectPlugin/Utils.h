#ifdef __cplusplus
	extern "C" {
#endif

#include <objc/runtime.h>
#import <mach-o/dyld.h>
#import <SwiftUI/SwiftUI.h>
#import "rd_route.h"

intptr_t getImageAddress(intptr_t functionAddress);

intptr_t getImageAddressByIndex(uint32_t imageIndex, intptr_t functionAddress);

BOOL hookPtr(uint32_t imageIndex, intptr_t addr, void *replaceMethod, void **retOriginalFunctionAddress);

BOOL hookPtrZ(intptr_t addr, void *replaceMethod, void **retOriginalFunctionAddress);

BOOL hookPtrA(intptr_t addr, void *replaceMethod);

void switchMethod(Method original, Method new);

Method getMethod(Class _Nullable cls, SEL _Nonnull name);

Method getMethodStr(NSString *cls, NSString *name);

Method getMethodByCls(Class _Nullable cls, SEL _Nonnull name);

Method getMethodStrByCls(NSString *cls, NSString *name);

id getInstanceIvar(id self, const char *ivarName);

uint32_t getImageVMAddrSlideIndex(char* ModuleName);

IMP setMethod(Method m, IMP imp);
IMP getMethodImplementation(Class cls, SEL name);
Method getMethod(Class _Nullable cls, SEL _Nonnull name);

BOOL checkSelfInject(char *name);
BOOL checkAppVersion(char *checkVersion);
BOOL checkAppCFBundleVersion(char *checkVersion);
void initBaseEnv();
int ret0(void);
int ret1(void);

@interface Utils : NSObject


- (int)ret0;

- (int)ret1;
@end