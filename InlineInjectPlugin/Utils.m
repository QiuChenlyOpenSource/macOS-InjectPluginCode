#import <objc/runtime.h>
#import <mach-o/dyld.h>
#import <AppKit/AppKit.h>
#import "rd_route.h"
#import "Utils.h"


@implementation Utils

/**
 * 一个返回值为0的空函数
 * 使用方法 ret0/1
 * @return 0
 */
int ret0(void) {
    NSLog(@"==== 返回值0.");
    return 0;
}

/**
 * 一个返回值为1的空函数
 * 使用方法 ret0/1
 * @return 1
 */
int ret1(void) {
    NSLog(@"==== 返回值1.");
    return 1;
}

/**
 * 一个返回值为0的空函数\n
 * 使用方法 \@selector(ret0/1)
 * @return 0
 */
- (int)ret0 {
    NSLog(@"正在Hook返回值为 0");
    return 0;
}

/**
 * 一个返回值为1的空函数
 * @return 1
 */
- (int)ret1 {
    NSLog(@"正在Hook返回值为 1");
    return 1;
}

/**
 * 获取指定镜像的函数偏移地址在物理内存中的实际地址
 * @param imageIndex 镜像序号  0 为 app 自身
 * @param functionAddress 欲拦截的函数地址
 * @return 函数物理内存地址
 */
intptr_t getImageAddressByIndex(uint32_t imageIndex, intptr_t functionAddress) {
    intptr_t addrA = _dyld_get_image_vmaddr_slide(imageIndex);
    const char *Name = _dyld_get_image_name(imageIndex);
    intptr_t originalAddress = addrA + functionAddress;
    NSLog(@"==== 模块序号:%i,模块名称: %s,获取到模块偏移: %p, 最终地址为%p", imageIndex, Name, addrA, originalAddress);
    return originalAddress;
}

/**
 * 获取 App 自身偏移地址函数的内存地址
 * @param functionAddress 函数地址
 * @return 返回函数内存地址
 */
intptr_t getImageAddress(intptr_t functionAddress) {
    return getImageAddressByIndex(0,functionAddress);
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
    intptr_t originalAddress = getImageAddressByIndex(imageIndex, addr);
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
 * 设置函数的IMP指针并返回原始函数的IMP指针
 * @param m
 * @param imp
 * @return
 */
IMP setMethod(Method m, IMP imp) {
    return method_setImplementation(m, imp);
}

/**
 * 获取实例方法函数的IMP指针
 * @param cls
 * @param name
 * @return
 */
IMP getMethodImplementation(Class cls, SEL name) {
    return class_getMethodImplementation(cls, name);
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

/**
 * 获取类方法函数IMP
 * @param cls
 * @param name
 * @return
 */
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
    for (uint32_t i = 0; i < size; i++) {
        const char *Name = _dyld_get_image_name(i);
        NSString *nName = [NSString stringWithCString:Name encoding:NSUTF8StringEncoding];
        NSString *nModuleName = [NSString stringWithCString:ModuleName encoding:NSUTF8StringEncoding];
        if ([nName rangeOfString:nModuleName].location != NSNotFound) {
            NSLog(@"==== 找到模块 %s 序号是 %i", ModuleName, i);
            return i;
        }
    }
    return 0;
}

/**
 * App的唯一ID 用来过滤指定的App
 */
const char *myAppBundleName = "";
/**
 * app的版本号
 */
const char *myAppBundleVersionCode = "";
/**
 * 更精确的版本号 一般情况下不用到
 */
const char *myAppCFBundleVersion = "";


/**
 * 检查这个app包名是否和提供的name一致
 * @param name
 * @return
 */
BOOL checkSelfInject(char *name) {
    BOOL result = strcmp(myAppBundleName, name) == 0;
    NSString *info = result ? @"需要注入" : @"不需要注入";//%s似乎对字符串打印有错误的缓冲显示 需要用NSString做中转
    NSLog(@"==== 当前App是 %s 输入的App名称是 %s, 是否需要注入? %@.", myAppBundleName, name, info);
    return result;//相等则执行
}

/**
 * 检查app版本号是否和提供的版本号一致
 * @param checkVersion
 * @return
 */
BOOL checkAppVersion(char *checkVersion) {
    NSLog(@"==== 正在检查App版本.当前版本 %s, 代码中的预设版本为 %s", myAppBundleVersionCode, checkVersion);
    return strcmp(myAppBundleVersionCode, checkVersion) == 0;
}

/**
 * 检查app更精确的版本号
 * @param checkVersion
 * @return
 */
BOOL checkAppCFBundleVersion(char *checkVersion) {
    NSLog(@"==== 正在检查App版本.当前版本 %s, 代码中的预设版本为 %s", myAppCFBundleVersion, checkVersion);
    return strcmp(myAppCFBundleVersion, checkVersion) == 0;
}

/**
 * 初始化基本代码和环境
 */
void initBaseEnv() {
    NSBundle *app = [NSBundle mainBundle];
    NSString *appName = [app bundleIdentifier];
    NSString *appVersion = [app objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appCFBundleVersion = [app objectForInfoDictionaryKey:@"CFBundleVersion"];
//    const char *app = appName.UTF8String;
//    myAppBundleName = malloc(strlen(app));
//    memcpy(myAppBundleName, app, strlen(app));
    myAppBundleName = [appName UTF8String];
    myAppBundleVersionCode = [appVersion UTF8String];
    myAppCFBundleVersion = [appCFBundleVersion UTF8String];
//    myAppBundleName = [appName cStringUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"==== AppName is [%s],Version is [%s], myAppCFBundleVersion is [%s].", myAppBundleName, myAppBundleVersionCode, myAppCFBundleVersion);
}

/**
 * 自动加载主函数
 */
+ (void)load {
    initBaseEnv();
}

@end