#ifdef __cplusplus
	extern "C" {
#endif

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
