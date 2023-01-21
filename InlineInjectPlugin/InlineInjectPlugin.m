//
//  InlineInjectPlugin.m
//  InlineInjectPlugin
//
//  Created by 秋城落叶 on 2023/1/16.
//
//

#import "InlineInjectPlugin.h"
#import <objc/runtime.h>
#import <mach-o/dyld.h>
#import <SwiftUI/SwiftUI.h>
#import "rd_route.h"

@implementation InlineInjectPlugin

NSString *ids(NSString *txt) {
    return [@"======= " stringByAppendingString:txt];
}

- (BOOL)isAppActivated {
    return 0x1;
}

- (BOOL)hasLoggedInUser {
    return 0x1;
}

static IMP originalFun = NULL;
//声明类内部变量

//变量参数定义 搞半天他妈的函数参数变量是这么定义的
//updateUIForCustomer:licenseValidationResult:
- (void)updateUIForCustomer:(id)arg1 licenseValidationResult:(id)arg2 {
    //拿到IMP指针先定义函数结构
    void (*updateUIForCustomer)(id, SEL, id, id) = (void *) originalFun;//首先强制转换为函数
    updateUIForCustomer(self, @selector(updateUIForCustomer:licenseValidationResult:), arg1, arg2);//开始函数调用成功
    NSLog(@"======= QiuChenly licenseValidationResult called");
    NSLog(@"res = %@", arg1);
    NSLog(@"res = %@", arg2);//用%@打印一切数据对象。顺便还能展示指针的数据类型是什么
    //引入SwiftUI库直接拿到指针所属对象
    NSTextField *(*customerInfoValueLabel)(id, SEL) = (void *) class_getMethodImplementation(NSClassFromString(@"MPAActivationInfoViewController"), NSSelectorFromString(@"customerInfoValueLabel"));
    NSTextField *(*dateInfoValueLabel)(id, SEL) = (void *) class_getMethodImplementation(NSClassFromString(@"MPAActivationInfoViewController"), NSSelectorFromString(@"dateInfoValueLabel"));//声明方法结构和实现体
    NSTextField *customerInfoValueLabels = customerInfoValueLabel(self, NSSelectorFromString(@"customerInfoValueLabel"));
    NSTextField *dateInfoValueLabels = dateInfoValueLabel(self, NSSelectorFromString(@"dateInfoValueLabel"));//传入self和SEL调用函数
    NSLog(@"NSTextField = %@", customerInfoValueLabels);
    [customerInfoValueLabels setStringValue:@"QiuChenly@52pojie.cn/forum.php?mod=viewthread&tid=1705872"];//直接调用函数方法设置字符串
    [dateInfoValueLabels setStringValue:@"永不过期 K'ed by 秋城落叶 仅供学习交流 禁止转卖/传播/牟利"];
}

BOOL (*sub_10036BC40_org)(int) = NULL;

//定义一个swift函数用于替换 可选是否static静态
static BOOL sub_10036BC40_hook(int a1) {
    BOOL ret = sub_10036BC40_org(0);//调用原函数 但是不知道为什么参数传递进去就闪退 内存指向了一个不可读区域
    NSLog(@"======= QiuChenly load sub_10036BC40_hook called original return value is %d, args1 = %d", ret, a1);
    return 0x1;
}

void CleanMyMacHook() {
    //返回值 (*函数名)(参数类型列表)
    intptr_t sub_10036BC40 = _dyld_get_image_vmaddr_slide(0) + 0x10036BC40;//获取第0个镜像基地址 加上偏移地址
    rd_route((void *) sub_10036BC40, sub_10036BC40_hook, (void **) &sub_10036BC40_org);
    NSLog(@"======= QiuChenly load sub_10036BC40 success ======= %p - %p", &sub_10036BC40, &sub_10036BC40_hook);

    NSLog(@"======= QiuChenly load hasLoggedInUser =======");
    Method ohasLoggedInUser = class_getInstanceMethod(NSClassFromString(@"CMMacPawAccountActivationManager"), NSSelectorFromString(@"hasLoggedInUser"));
    Method nhasLoggedInUser = class_getInstanceMethod([InlineInjectPlugin class], @selector(hasLoggedInUser));
    method_exchangeImplementations(ohasLoggedInUser, nhasLoggedInUser);//常规交换函数实现

    NSLog(@"======= QiuChenly load MPAActivationInfoViewController =======");
    Method oMPAActivationInfoViewController = class_getInstanceMethod(NSClassFromString(@"MPAActivationInfoViewController"), NSSelectorFromString(@"updateUIForCustomer:licenseValidationResult:"));
    IMP nMPAActivationInfoViewController = class_getMethodImplementation([InlineInjectPlugin class], @selector(updateUIForCustomer:licenseValidationResult:));
    //IMP函数实现和Selector的极限拉扯
    originalFun = method_setImplementation(oMPAActivationInfoViewController, nMPAActivationInfoViewController);//设置新的IMP实现到系统中
}


// iShot Hook
int (*sub_100064A3E_org)(int, int, double) = NULL;

int sub_100064A3E_hook(int arg1, int arg2, int arg3) {
    /*
     * 一些NSUserDefaults的设置
        NSUserDefaults *mUser = [[NSUserDefaults alloc] initWithSuiteName:@"4K6FWZU8C4.group.cn.better365"];
        NSUserDefaults *mStandardUserDefaults = [NSUserDefaults standardUserDefaults];

        id AppStoreiShotInstallTime = [mUser objectForKey:@"AppStoreiShotInstallTime"];
        [mUser setInteger:(NSInteger) [[NSDate date] timeIntervalSinceNow] forKey:@"AppStoreiShotInstallTime"];

        [mStandardUserDefaults setObject:@"U2FsdGVkX1/xOkB3LRmIhtcVRq/r4CC3bSPryVRx9cE=" forKey:@"receipt"];
        [mStandardUserDefaults removeObjectForKey:@"InstallTimeInfo"];
        [mStandardUserDefaults synchronize];
        NSString *receipt = [mStandardUserDefaults objectForKey:@"receipt"];
     */

    NSLog(@"======= sub_100064A3E_hook called %p %p %p", arg1, arg2, arg3);
    //home 0x1000ED93C 获取函数偏移指针 然后转为c结构直接调用此函数 NSMainApplication主函数
    int (*sub_0x1000ED93C)(int, int) =(void *) _dyld_get_image_vmaddr_slide(0) + 0x1000ED93C;
    int *_0x1001473E9 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x1001473E9;
    int *_0x100149020 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x100149020;
    *_0x100149020 = 1;
    //获取偏移指针 准备向其写入标志位
    *_0x1001473E9 = 0; //不想通过指针设置的话可以用C函数 memset(flag, 0x0, sizeof(int));
//    NSLog(ids(@"flag %d"), *_0x1001473E9);
//    return sub_100064A3E_org(arg1, arg2, arg3); 跳过不执行原函数
    int retz = sub_0x1000ED93C(arg1, arg2); //直接启动主窗口函数
    return retz;
}


void iShot() {
    intptr_t sub_100064A3E = _dyld_get_image_vmaddr_slide(0) + 0x100064A3E;//获取第0个镜像基地址 加上偏移地址

    intptr_t sub_100050DE3 = _dyld_get_image_vmaddr_slide(0) + 0x100050DE3;//AES密码调用方
    id (*aesKey)() = (void *) sub_100050DE3;//直接获取对应地址的函数地址 直接转换成函数结构调用
    NSLog(@"======= AESKey is %@", aesKey());

    rd_route((void *) sub_100064A3E, sub_100064A3E_hook, (void **) &sub_100064A3E_org);
    NSLog(@"======= QiuChenly load sub_100064A3E success ======= %p - %p", &sub_100064A3E, &sub_100064A3E_hook);
}

// End of iShot Hook


// AutoSwitchInput
int switchMain(int arg1, int arg2) {
    int (*sub_0x10001C520)(int, int) =(void *) _dyld_get_image_vmaddr_slide(0) + 0x10001C520;
    int *_0x10002D039 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x10002D039;
    int *_0x10002D038 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x10002D038;
    *_0x10002D038 = 1;
    *_0x10002D039 = 0;
    int retz = sub_0x10001C520(arg1, arg2);
    return retz;
}

void AutoSwitchInput() {
    intptr_t start = _dyld_get_image_vmaddr_slide(0) + 0x10000BE02;
    rd_route((void *) start, switchMain, (void **) &sub_100064A3E_org);
}
// end AutoSwitch Input

// SuperRightKey
int SuperRightKeyMain(int arg1, int arg2) {
    int (*sub_0x100025FF0)(int, int) =(void *) _dyld_get_image_vmaddr_slide(0) + 0x100025FF0;
    int *_0x10003BAA8 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x10003BAA8;
    int *_0x10003BDD8 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x10003BDD8;
    *_0x10003BDD8 = 1;
    *_0x10003BAA8 = 0;
    int retz = sub_0x100025FF0(arg1, arg2);
    return retz;
}

void SuperRightKey() {
    intptr_t start = _dyld_get_image_vmaddr_slide(0) + 0x100004587;
    rd_route((void *) start, SuperRightKeyMain, (void **) &sub_100064A3E_org);
}
// end SuperRightKey


// start Ulysses


- (int)UserActivation {
    NSLog(@"======= QiuChenly Ulysses activation called");
    return 0x4;
}

- (BOOL)activationIsExpired {
    NSLog(@"======= QiuChenly Ulysses activationIsExpired called");
    return 0x0;
}

- (void)updateActivationState {
    void (*updateActivationStateOriginal)(id, SEL) = (void *) originalFun;
    updateActivationStateOriginal(self, @selector(updateActivationState));
    NSLog(@"======= QiuChenly Ulysses updateActivationState called");
    void (*setActivationInfo)(id, SEL, id) = (void *) class_getMethodImplementation(
            NSClassFromString(@"ULStorePreferencesModel"),
            NSSelectorFromString(@"setActivationInfo:")
    );
    void (*setActivationDetail)(id, SEL, id) = (void *) class_getMethodImplementation(
            NSClassFromString(@"ULStorePreferencesModel"),
            NSSelectorFromString(@"setActivationDetail:")
    );
    setActivationInfo(self,
            NSSelectorFromString(@"setActivationInfo:"),
            @"您使用的是 Ulysses 的 *永久授权* 版本。"
    );
    setActivationDetail(self,
            NSSelectorFromString(@"setActivationDetail:"),
            @"已授权给: 秋城落叶"
    );
}

void Ulysses() {
    Method activation = class_getInstanceMethod(NSClassFromString(@"ULStoreController"), NSSelectorFromString(@"activation"));
    Method nActivation = class_getInstanceMethod([InlineInjectPlugin class], @selector(UserActivation));
    method_exchangeImplementations(activation, nActivation);

    Method activationIsExpired = class_getInstanceMethod(NSClassFromString(@"ULStoreController"), NSSelectorFromString(@"activationIsExpired"));
    Method nactivationIsExpired = class_getInstanceMethod([InlineInjectPlugin class], @selector(activationIsExpired));
    method_exchangeImplementations(activationIsExpired, nactivationIsExpired);

    //设置界面数据
    Method updateActivationState = class_getInstanceMethod(NSClassFromString(@"ULStorePreferencesModel"), NSSelectorFromString(@"updateActivationState"));
    IMP nUpdateActivationState = class_getMethodImplementation([InlineInjectPlugin class], @selector(updateActivationState));
    originalFun = method_setImplementation(updateActivationState, nUpdateActivationState);
}

// end Ulysses

+ (void)load {
//    iShot();
//    AutoSwitchInput();
//    SuperRightKey();
//    CleanMyMacHook();
    Ulysses();
}

@end
