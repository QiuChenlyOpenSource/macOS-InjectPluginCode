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
#import <dlfcn.h>
#import "rd_route.h"

@implementation InlineInjectPlugin

const char *myAppBundleName = "";
const char *myAppBundleVersionCode = "";

BOOL checkSelfInject(char *name) {
    NSLog(@"==== app is %s input is %s result is %i", myAppBundleName, name, strcmp(myAppBundleName, name) == 0);
    return strcmp(myAppBundleName, name) == 0;//相等则执行
}

BOOL checkAppVersion(char *checkVersion) {
    return strcmp(myAppBundleVersionCode, checkVersion) == 0;
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
    [customerInfoValueLabels setStringValue:@"K'ed by 秋城落叶@52pojie.cn/home.php?uid=653608"];//直接调用函数方法设置字符串
    [dateInfoValueLabels setStringValue:@"永不过期 仅供交流学习 禁止传播/牟利"];

//    [customerInfoValueLabels setStringValue:@"K'ed By 秋城落叶 MacApp.org.cn全网首发"];//直接调用函数方法设置字符串
//    [dateInfoValueLabels setStringValue:@"永不过期 仅供学习交流 禁止牟利/转载"];
}

BOOL (*sub_10036BC40_org)(int) = NULL;

//定义一个swift函数用于替换 可选是否static静态
static BOOL sub_10036BC40_hook(int a1) {
    BOOL ret = sub_10036BC40_org(0);//调用原函数 但是不知道为什么参数传递进去就闪退 内存指向了一个不可读区域
    NSLog(@"======= QiuChenly load sub_10036BC40_hook called original return value is %d, args1 = %d", ret, a1);
    return 0x1;
}

void CleanMyMacHook() {
    if (!checkSelfInject("com.macpaw.CleanMyMac4")) return;
//    if (!checkSelfInject("com.macpaw.zh.CleanMyMac4")) return;
    //返回值 (*函数名)(参数类型列表)
    //中文版4.12.3基址 0x10036BC40
    //国际版4.12.4基址 0x1003B4A00
    //4.12.5 0x1003B4A20
    //4.13.0b1 0x0x1003B45C0
    //4.13.0b2 0x0x1003B45C0
    intptr_t sub_10036BC40 = _dyld_get_image_vmaddr_slide(0) + 0x1003B45C0;//获取第0个镜像基地址 加上偏移地址
    rd_route((void *) sub_10036BC40, sub_10036BC40_hook, (void **) &sub_10036BC40_org);
    NSLog(@"======= QiuChenly load sub_10036BC40 success ======= %p - %p", &sub_10036BC40, &sub_10036BC40_hook);

//    NSLog(@"======= QiuChenly load hasLoggedInUser =======");
//    Method ohasLoggedInUser = class_getInstanceMethod(NSClassFromString(@"CMMacPawAccountActivationManager"), NSSelectorFromString(@"hasLoggedInUser"));
//    Method nhasLoggedInUser = class_getInstanceMethod([InlineInjectPlugin class], @selector(hasLoggedInUser));
//    method_exchangeImplementations(ohasLoggedInUser, nhasLoggedInUser);//常规交换函数实现

    NSLog(@"======= QiuChenly load MPAActivationInfoViewController =======");
    Method oMPAActivationInfoViewController = class_getInstanceMethod(NSClassFromString(@"MPAActivationInfoViewController"), NSSelectorFromString(@"updateUIForCustomer:licenseValidationResult:"));
    IMP nMPAActivationInfoViewController = class_getMethodImplementation([InlineInjectPlugin class], @selector(updateUIForCustomer:licenseValidationResult:));
    //IMP函数实现和Selector的极限拉扯
    originalFun = method_setImplementation(oMPAActivationInfoViewController, nMPAActivationInfoViewController);//设置新的IMP实现到系统中
}


// iShot Hook
int (*sub_100064A0E_org)(int, int, double) = NULL;

int sub_100064A0E_hook(int arg1, int arg2, int arg3) {
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

    NSLog(@"======= sub_100064A0E_hook called %p %p %p", arg1, arg2, arg3);
    //home 0x1000ED93C 获取函数偏移指针 然后转为c结构直接调用此函数 NSMainApplication主函数
    int (*sub_0x1000ED93C)(int, int) =(void *) _dyld_get_image_vmaddr_slide(0) + 0x1000EDB9C;
    int *_0x1001473F9 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x1001470D9;
//    int *_0x100149020 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x100149020;
//    *_0x100149020 = 1; //一旦写入这个标志位就会引发异常 原因不明
    //获取偏移指针 准备向其写入标志位
    *_0x1001473F9 = 0; //不想通过指针设置的话可以用C函数 memset(flag, 0x0, sizeof(int));
//    NSLog(ids(@"flag %d"), *_0x1001473E9);
//    return sub_100064A3E_org(arg1, arg2, arg3); 跳过不执行原函数
    int retz = sub_0x1000ED93C(arg1, arg2); //直接启动主窗口函数
    return retz;
}

- (void)mawakeFromNib {
    void (*mawakeFromNib)(id, SEL) = (void *) originalFun;
    mawakeFromNib(self, NSSelectorFromString(@"awakeFromNib"));

    NSButton *(*buyButton)(id, SEL) = (void *) class_getMethodImplementation(NSClassFromString(@"AppPrefsWindowController"), NSSelectorFromString(@"buyButton"));
    NSTextField *(*version)(id, SEL) = (void *) class_getMethodImplementation(NSClassFromString(@"AppPrefsWindowController"), NSSelectorFromString(@"version"));//声明方法结构和实现体
    NSButton *buyButtons = buyButton(self, NSSelectorFromString(@"buyButton"));
    NSTextField *versions = version(self, NSSelectorFromString(@"version"));//传入self和SEL调用函数
//    [buyButtons setHidden:1];
    [buyButtons setTitle:@"授权给: 秋城落叶"];
    [buyButtons setAction:NULL];
    NSString *v = [versions stringValue];
    [versions setStringValue:[v stringByAppendingString:@" Pro"]];
}

void iShot() {
    if (!checkSelfInject("cn.better365.ishot")) return;
    intptr_t sub_100064A0E = _dyld_get_image_vmaddr_slide(0) + 0x10006598E;//获取第0个镜像基地址 加上偏移地址

    //    intptr_t sub_100050DE3 = _dyld_get_image_vmaddr_slide(0) + 0x100050DE3;//AES密码调用方
    //    id (*aesKey)() = (void *) sub_100050DE3;//直接获取对应地址的函数地址 直接转换成函数结构调用
    //    NSLog(@"======= AESKey is %@", aesKey());

    rd_route((void *) sub_100064A0E, sub_100064A0E_hook, (void **) &sub_100064A0E_org);
    NSLog(@"======= QiuChenly load sub_100064A3E success ======= %p - %p", &sub_100064A0E, &sub_100064A0E_hook);

    Method awakeFromNib = class_getInstanceMethod(NSClassFromString(@"AppPrefsWindowController"), NSSelectorFromString(@"awakeFromNib"));
    IMP nMPAActivationInfoViewController = class_getMethodImplementation([InlineInjectPlugin class], @selector(mawakeFromNib));
    //IMP函数实现和Selector的极限拉扯
    originalFun = method_setImplementation(awakeFromNib, nMPAActivationInfoViewController);//设置新的IMP实现到系统中
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
    if (!checkSelfInject("com.better365.autoinput")) return;
    intptr_t start = _dyld_get_image_vmaddr_slide(0) + 0x10000BE02;
    rd_route((void *) start, switchMain, (void **) &sub_100064A0E_org);
}
// end AutoSwitch Input

// SuperRightKey
int SuperRightKeyMain(int arg1, int arg2) {
    int (*sub_0x100025FF0)(int, int) =(void *) _dyld_get_image_vmaddr_slide(0) + 0x10002992E;
    int *_0x10003BAA8 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x100040320;
    int *_0x10003BDD8 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x100040668;
    *_0x10003BDD8 = 1;
    *_0x10003BAA8 = 0;
    int retz = sub_0x100025FF0(arg1, arg2);
    return retz;
}

void SuperRightKey() {
    if (!checkSelfInject("cn.better365.iRightMouse")) return;
    intptr_t start = _dyld_get_image_vmaddr_slide(0) + 0x1000053F2;
    rd_route((void *) start, SuperRightKeyMain, (void **) &sub_100064A0E_org);
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
    if (!checkSelfInject("com.ulyssesapp.mac")) return;
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


// Macs Fan Control

int (*_0x69d90_native)(char *arg1);

int _0x69d90a(char *arg1) {
    NSLog(@"==== _0x69d90 call args is %s", arg1);
    int v = _0x69d90_native(arg1);
    NSLog(@"==== _0x69d90 call end result is %i", v);
    return 1;
}

int (*aboutDialogOri)(int *ths, int *a2, int *a3);

int aboutDialogNew(int *ths, int *a2, int *a3) {
    //原函数定义：
    //__int64 __fastcall QInfoDialog::QInfoDialog(QInfoDialog *this, QWidget *a2, QFanControl *a3)
    //由于传递的都是指针 所以也需要传递指针过去 参数必须要为指针
    NSLog(@"==== aboutDialogNew is load %p %p %p %p", ths, a2, a3, &aboutDialogOri);
    int ptr = aboutDialogOri(ths, a2, a3);
    NSLog(@"==== aboutDialogNew is load end %i", ptr);
    return ptr;
}

void macsfan() {
    if (!checkSelfInject("com.crystalidea.macsfancontrol")) return;
    intptr_t _0x69d90 = _dyld_get_image_vmaddr_slide(0) + 0x100069D90;
    rd_route((void *) _0x69d90, _0x69d90a, (void **) &_0x69d90_native);

//    intptr_t addr = _dyld_get_image_vmaddr_slide(0) + 0x1000A4750;
//    rd_route((void *) addr, aboutDialogNew, (void **) &aboutDialogOri);
}
// End Macs Fan Control


//AirBuddy2 Start

int (*_0x100050480Ori)();

- (BOOL)new_activated {
    return 1;
}

int _0x100050480New() {
//    register int r13 asm("r13"); //读取寄存器的值
    NSLog(@"==== _0x100050480New called");
//    *(*r13 + 153) = 0;
    __asm
    {   //内联汇编直接修改寄存器的值
            mov byte ptr[r13+99h], 0
    }
    NSLog(@"==== _0x100050480New call end");
    return _0x100050480Ori();
}

void AirBuddy() {
    if (!checkSelfInject("codes.rambo.AirBuddy")) return;
//    register int i asm("r13");
//    Method activated = class_getInstanceMethod(NSClassFromString(@"PADProduct"), NSSelectorFromString(@"activated"));
//    Method activatedEx = class_getInstanceMethod([InlineInjectPlugin class], @selector(activated));
//    method_exchangeImplementations(activated, activatedEx);

    intptr_t _0x100050480 = _dyld_get_image_vmaddr_slide(0) + 0x100050480;
    rd_route((void *) _0x100050480, _0x100050480New, (void **) &_0x100050480Ori);
}


//end of AirBuddy2

//Start MWebPro

- (NSString *)activationEmail {
    return @"秋城落叶@52pojie.cn";
}

- (NSString *)activationID {
    return @"Ke'd By QiuChenly";
}

void mwebPro() {
    if (!checkSelfInject("com.coderforart.MWeb3")) return;
    Method activation = class_getInstanceMethod(NSClassFromString(@"PADProduct"), NSSelectorFromString(@"activated"));
    Method nActivation = class_getInstanceMethod([InlineInjectPlugin class], @selector(isAppActivated));
    method_exchangeImplementations(activation, nActivation);

    Method activationEmail = class_getInstanceMethod(NSClassFromString(@"PADProduct"), NSSelectorFromString(@"activationEmail"));
    Method nactivationEmail = class_getInstanceMethod([InlineInjectPlugin class], @selector(activationEmail));
    method_exchangeImplementations(activationEmail, nactivationEmail);

    Method activationID = class_getInstanceMethod(NSClassFromString(@"PADProduct"), NSSelectorFromString(@"activationID"));
    Method nactivationID = class_getInstanceMethod([InlineInjectPlugin class], @selector(activationID));
    method_exchangeImplementations(activationID, nactivationID);
}
//End MWebPro

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
 * 交换函数IMP实现
 * @param original 原始函数
 * @param new 伪造函数
 */
void switchMethod(Method original, Method new) {
    method_exchangeImplementations(original, new);
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
    intptr_t originalAddress = _dyld_get_image_vmaddr_slide(imageIndex) + addr;
    return rd_route((void *) originalAddress, replaceMethod, retOriginalFunctionAddress) == KERN_SUCCESS;
}

BOOL hookPtrZ(intptr_t addr, void *replaceMethod, void **retOriginalFunctionAddress) {
    return hookPtr(0, addr, replaceMethod, retOriginalFunctionAddress);
}

BOOL hookPtrA(intptr_t addr, void *replaceMethod) {
    return hookPtrZ(addr, replaceMethod, NULL);
}

// Start Bandizip


int checkSignal() {
    return 1;
}

void bandizip() {
    if (!checkSelfInject("com.bandisoft.mac.bandizip365")) return;
    //去掉签名检查
    //7.19 0x1000821B0
    //7.20 0x1000876d0
    hookPtrA(0x1000876d0, checkSignal);
    //激活
    switchMethod(getMethodStr(@"LicenseManager", @"isSubscriptionEdition"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
}

// End Bandizip

//Start popclip

- (NSString *)licenseSummary {
    return @"PopClip 永久授权给 秋城落叶\n"
           "Name & Company: 秋城落叶\n"
           "License: 单用户专业版 x 无限设备数量限制\n"
           "Purchase Date: 2023年2月14日 周二\n"
           "Purchase Ref: QiuChenly@52pojie.cn\n";
}

void popClip() {
    if (!checkSelfInject("com.pilotmoon.popclip")) return;
    hookPtrA(0x100083148, checkSignal);
    switchMethod(getMethodStr(@"PMPurchaseInfo", @"licenseSummary"), getMethod([InlineInjectPlugin class], @selector(licenseSummary)));
    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasLicenseKey"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"isFullAppUnlocked"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasInAppPurchase"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasPaidReceipt"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasReceipt"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
}

//end popclip

//Start Parallels Desktop
void Parallels() {
    if (!checkSelfInject("com.parallels.desktop.dispatcher")) return;
    hookPtrA(0x1005b0700, checkSignal);
    hookPtrA(0x1007c9300, checkSignal);
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"licenseSummary"), getMethod([InlineInjectPlugin class], @selector(licenseSummary)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasLicenseKey"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"isFullAppUnlocked"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasInAppPurchase"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasPaidReceipt"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasReceipt"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
}

//end Parallels Desktop

//Start AppCleaner

void AppCleaner() {
    //https://download.nektony.com/download/app-cleaner-uninstaller/app-cleaner-uninstaller.dmg
    //官方下载地址 非中文版
    if (!checkSelfInject("com.nektony.App-Cleaner-SIII")) return;
    //版本 8.1
    /**
     *  1.unlock
        -[BaseFeaturesController isUnlocked] call NKLicenseManager::LicenseStateStorage::isUnlocked

        __data:00000001007FB8D8                 dq offset sub_100407A70
        __data:00000001007FB8E0                 dq offset _$sBoWV
        __data:00000001007FB8E8 _OBJC_CLASS_$__TtC16NKLicenseManager19LicenseStateStorage __objc2_class <offset _OBJC_METACLASS_$__TtC16NKLicenseManager19LicenseStateStorage,\
        __data:00000001007FB8E8                                offset _OBJC_CLASS_$__TtCs12_SwiftObject, \
        __data:00000001007FB8E8                                offset __objc_empty_cache, 0, \
        __data:00000001007FB8E8                                offset _TtC16NKLicenseManager19LicenseStateStorage_$classData.flags+1>
        __data:00000001007FB910                                         db     2
        __data:00000001007A9D59 00                                      DCB    0
        __data:00000001007A9D5A 00                                      DCB    0
        __data:00000001007A9D5B 00
        ...
        __data:00000001007A9DD5 00                                      DCB    0
        __data:00000001007A9DD6 00                                      DCB    0
        __data:00000001007A9DD7 00                                      DCB    0
        __data:00000001007A9DD8 58 F9 3D 00 01 00 00 00                 DCQ sub_1003DF958
        __data:00000001007A9DE0 78 E4 7C 00 01 00 00 00                 DCQ __imp__swift_deletedMethodError
        __data:00000001007A9DE8 78 E4 7C 00 01 00 00 00                 DCQ __imp__swift_deletedMethodError
        __data:00000001007A9DF0 A0 F9 3D 00 01 00 00 00                 DCQ sub_1003DF9A0 ; <----- return 1
        __data:00000001007A9DF8 D0 F9 3D 00 01 00 00 00                 DCQ sub_1003DF9D0
        __data:00000001007A9E00 40 FD 3D 00 01 00 00 00                 DCQ sub_1003DFD40
        __data:00000001007A9E08 CC FD 3D 00 01 00 00 00                 DCQ sub_1003DFDCC
        2. startup trial alert
        -[BaseFeaturesController onAppDidFinishLaunching] patch to return;
     */

    /**
     * 此处Hook地址来自
     *  __data:00000001007FB990                 dq offset sub_100403D80
        __data:00000001007FB998                 dq offset __imp__swift_deletedMethodError
        __data:00000001007FB9A0                 dq offset __imp__swift_deletedMethodError
        __data:00000001007FB9A8                 dq offset sub_100403DC0 <-- 修改此函数为返回1
        __data:00000001007FB9B0                 dq offset sub_100403DF0
        __data:00000001007FB9B8                 dq offset sub_100404140
        __data:00000001007FB9C0                 dq offset sub_1004041C0
        __data:00000001007FB9C8                 dq offset __imp__swift_deletedMethodError
        __data:00000001007FB9D0                 dq offset __imp__swift_deletedMethodError
        __data:00000001007FB9D8                 dq offset __imp__swift_deletedMethodError
        __data:00000001007FB9E0                 dq offset __imp__swift_deletedMethodError
        __data:00000001007FB9E8                 dq offset __imp__swift_deletedMethodError
        __data:00000001007FB9F0                 dq offset __imp__swift_deletedMethodError
        __data:00000001007FB9F8                 dq offset sub_1004041F0
     */
    if (checkAppVersion("8.1.1")) {
        hookPtrA(0x100403DC0, checkSignal);
        //switchMethod(getMethodStr(@"_TtC13App_Cleaner_822BaseFeaturesController", @"isUnlocked"), getMethod([InlineInjectPlugin class], @selector(new_activated)));
        //去掉打开软件弹框提示试用过期
        switchMethod(getMethodStr(@"_TtC13App_Cleaner_822BaseFeaturesController", @"onAppDidFinishLaunching"), getMethod([InlineInjectPlugin class], @selector(new_activated)));

    }
}

//end AppCleaner

void OmiRecorder() {
    if (!checkSelfInject("com.mac.utility.screen.recorder")) return;
    //MAS 版本1.2.4 (2023020802)
    hookPtrA(0x10001C810, checkSignal);
}

void FigPlayer() {
    if (!checkSelfInject("com.mac.utility.video.player.PotPlayerX")) return;
    //MAS 版本1.2.2 (2023022001)
    hookPtrA(0x1000765F0, checkSignal);
}

// Start Omi NTFS 磁盘专家 官网下载 非MAS版本

IMP originalFun_boolForKey = NULL;

- (BOOL)boolForKey:(NSString *)key {
    BOOL (*boolForKey)(id, SEL, NSString *) = (void *) originalFun_boolForKey;//首先强制转换为函数
    BOOL ret = boolForKey(self, NSSelectorFromString(@"boolForKey:"), key);
    if ([key isEqualToString:@"hasValidLicense"]) return TRUE;
    NSLog(@"==== key ==== %@,result = %d", key, ret);
    return ret;
}

void xNTFS() {
    if (checkSelfInject("com.omni.mac.utility.store.ntfs")) {
        //版本1.1.4
        hookPtrA(0x1000983a0, checkSignal);//AppStore版本
        return;
    }
    if (!checkSelfInject("com.omni.mac.utility.website.ntfs")) return;
//    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    [user setBool:1 forKey:@"hasValidLicense"];
//    BOOL a1 = [user boolForKey:@"hasValidLicense"];
//    NSLog(@"==== hasValidLicense = %d", a1);

    /**
     *  NSMenuItem *__cdecl -[xNTFS_Pro.XNMenuBarController vipItem](_TtC9xNTFS_Pro19XNMenuBarController *self, SEL a2)
        {
          __int64 v2; // rax

          v2 = swift_unknownObjectWeakLoadStrong((char *)self + OBJC_IVAR____TtC9xNTFS_Pro19XNMenuBarController_vipItem);
          return (NSMenuItem *)objc_autoreleaseReturnValue(v2, a2);
        }

        通过OBJC_IVAR____TtC9xNTFS_Pro19XNMenuBarController_vipItem找到下方代码，查到后得知
        _sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(7235433441665442152LL, -1196423208012388020LL)
        这个key字符串是hasValidLicense中文 返回1即可

          v14 = (void *)swift_getInitializedObjCClass(&OBJC_CLASS___NSUserDefaults);
          v15 = objc_msgSend(v14, "standardUserDefaults", v30);
          v16 = (void *)objc_retainAutoreleasedReturnValue(v15);
          v17 = _sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(7235433441665442152LL, -1196423208012388020LL);
          v18 = (unsigned __int64)objc_msgSend(v16, "boolForKey:", v17);
          objc_release(v16);
          objc_release(v17);
          v19 = (void *)swift_getInitializedObjCClass(&OBJC_CLASS___NSBundle);
          v20 = objc_msgSend(v19, "mainBundle");
          v21 = objc_retainAutoreleasedReturnValue(v20);
          if ( v18 )
          {
            v22 = -3458764513820540912LL;
            v23 = ",W,VproUninstallDriverSep";
          }
          else
          {
            v22 = -3458764513820540902LL;
            v23 = "MenuBar.Main.VIP";
          }
     */
    IMP nUpdateActivationState = class_getMethodImplementation([InlineInjectPlugin class], @selector(boolForKey:));
    originalFun_boolForKey = method_setImplementation(getMethodStr(@"NSUserDefaults", @"boolForKey:"), nUpdateActivationState);
}

// End Omi NTFS 磁盘专家

+ (void)load {
    NSBundle *app = [NSBundle mainBundle];
    NSString *appName = [app bundleIdentifier];
    NSString *appVersion = [app objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    const char *app = appName.UTF8String;
//    myAppBundleName = malloc(strlen(app));
//    memcpy(myAppBundleName, app, strlen(app));
    myAppBundleName = [appName UTF8String];
    myAppBundleVersionCode = [appVersion UTF8String];
//    myAppBundleName = [appName cStringUsingEncoding:NSASCIIStringEncoding];
    NSLog(@"==== AppName is %s,Version is %s.", myAppBundleName, myAppBundleVersionCode);
    iShot();
    AutoSwitchInput();
    SuperRightKey();
    CleanMyMacHook();
    Ulysses();
    macsfan();
    AirBuddy();
    mwebPro();
    bandizip();
    popClip();
    Parallels();
    AppCleaner();
    OmiRecorder();
    FigPlayer();
    xNTFS();
}

@end
//sudo /Users/qiuchenly/Downloads/macOS_HookWorkSpace/insert_dylib /Users/qiuchenly/Library/Caches/JetBrains/AppCode2022.3/DerivedData/InlineInjectPlugin-cybkmcvijgblnpbnqwzdzdznmxep/Build/Products/Debug/libInlineInjectPlugin.dylib