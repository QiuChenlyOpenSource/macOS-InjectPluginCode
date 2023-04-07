#import <objc/runtime.h>
#import <mach-o/dyld.h>
#import <AppKit/AppKit.h>
#import "rd_route.h"

/**
 * 一个返回值为1的空函数
 * @return 1
 */
int bypass1(void) {
    return 1;
}

/**
 * 根据提供的地址hook掉对应位置的函数
 * @param imageIndex App镜像序号
 * @param addr IDA中的函数偏移指针地址
 * @param replaceMethod 将被替换的函数
 * @param retOriginalFunctionAddress 如果有需要 此处返回被hook的原函数实现\n
 * 像这样声明将被保存的原函数:int (*functionName)(char *functionArgs);\n
 * 参数提供:(void **) &functionName
 * @return 成功或者失败 0/1
 */
BOOL hookPtr(uint32_t imageIndex, intptr_t addr, void *replaceMethod, void **retOriginalFunctionAddress) {
    NSLog(@"==== 正在Hook Ptr %p", (void *) addr);
    intptr_t originalAddress = _dyld_get_image_vmaddr_slide(imageIndex) + addr;
    return rd_route((void *) originalAddress, replaceMethod, retOriginalFunctionAddress) == KERN_SUCCESS;
}

BOOL hookPtrZ(intptr_t addr, void *replaceMethod, void **retOriginalFunctionAddress) {
    return hookPtr(0, addr, replaceMethod, retOriginalFunctionAddress);
}

BOOL hookPtrA(intptr_t addr, void *replaceMethod) {
    return hookPtrZ(addr, replaceMethod, NULL);
}

/**
 * 交换函数IMP实现
 * @param original 原始函数
 * @param new 伪造函数
 */
void switchMethod(Method original, Method new) {
    method_exchangeImplementations(original, new);
}

/**
 * 获取函数IMP
 * @param cls
 * @param name
 * @return
 */
Method getMethod(Class _Nullable cls, SEL _Nonnull name) {
    return class_getInstanceMethod(cls, name);
}

/**
 * 获取函数IMP 字符串方式
 * @param cls ObjectC 类名
 * @param name ObjectC 函数名
 * @return
 */
Method getMethodStr(NSString *cls, NSString *name) {
    return getMethod(NSClassFromString(cls), NSSelectorFromString(name));
}


Method getMethodByCls(Class _Nullable cls, SEL _Nonnull name) {
    return class_getClassMethod(cls, name);
}

Method getMethodStrByCls(NSString *cls, NSString *name) {
    return getMethodByCls(NSClassFromString(cls), NSSelectorFromString(name));
}

/**
 * 给定一个字符串 检查是否存在于app的framework中并返回index
 */
uint32_t getImageVMAddrSlideIndex(char *ModuleName) {
    int32_t size = _dyld_image_count();
    for (int i =0; i<size; i++) {
        const char* Name = _dyld_get_image_name(i);
        NSString *nName = [NSString stringWithCString:Name encoding:NSUTF8StringEncoding];
        NSString *nModuleName = [NSString stringWithCString:ModuleName encoding:NSUTF8StringEncoding];
        if([nName rangeOfString:nModuleName].location != NSNotFound){
            NSLog(@"找到模块 %s 序号是 %i",ModuleName,i);
            return i;
        }
    }
    return 0;
}
