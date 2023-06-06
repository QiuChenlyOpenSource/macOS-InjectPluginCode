//
//  InlineInjectPlugin.m
//  InlineInjectPlugin
//
//  Created by 秋城落叶 on 2023/1/16.
//
//

#import "InlineInjectPlugin.h"

@implementation InlineInjectPlugin

static IMP originalFun = NULL;
//声明类内部变量

//变量参数定义 搞半天他妈的函数参数变量是这么定义的
//updateUIForCustomer:licenseValidationResult:
- (void)updateUIForCustomer:(id)arg1 licenseValidationResult:(id)arg2 {
    //拿到IMP指针先定义函数结构
    void (*updateUIForCustomer)(id, SEL, id, id) = (void *) originalFun;//首先强制转换为函数
    updateUIForCustomer(self, @selector(updateUIForCustomer:licenseValidationResult:), arg1, arg2);//开始函数调用成功
    NSLog(@"======= QiuChenly licenseValidationResult called");
    NSLog(@"==== res = %@", arg1);
    NSLog(@"==== res = %@", arg2);//用%@打印一切数据对象。顺便还能展示指针的数据类型是什么
    //引入SwiftUI库直接拿到指针所属对象
    NSTextField *(*customerInfoValueLabel)(id, SEL) = (void *) getMethodImplementation(NSClassFromString(@"MPAActivationInfoViewController"), NSSelectorFromString(@"customerInfoValueLabel"));
    NSTextField *(*dateInfoValueLabel)(id, SEL) = (void *) getMethodImplementation(NSClassFromString(@"MPAActivationInfoViewController"), NSSelectorFromString(@"dateInfoValueLabel"));//声明方法结构和实现体
    NSTextField *customerInfoValueLabels = customerInfoValueLabel(self, NSSelectorFromString(@"customerInfoValueLabel"));
    NSTextField *dateInfoValueLabels = dateInfoValueLabel(self, NSSelectorFromString(@"dateInfoValueLabel"));//传入self和SEL调用函数
    NSLog(@"NSTextField = %@", customerInfoValueLabels);
    [customerInfoValueLabels setStringValue:@"K'ed by 秋城落叶@52pojie.cn/home.php?uid=653608"];//直接调用函数方法设置字符串
    [dateInfoValueLabels setStringValue:@"永不过期 仅供交流学习 禁止传播/牟利"];
}

BOOL (*sub_10036BC40_org)(intptr_t) = NULL;

//定义一个swift函数用于替换 可选是否static静态
static BOOL sub_10036BC40_hook(intptr_t a1) {
    BOOL ret = sub_10036BC40_org(a1);//调用原函数 但是不知道为什么参数传递进去就闪退 内存指向了一个不可读区域
    // Update at : 2023.5.12 闪退的原因是地址指针被格式化为了int 参数类型需要指定为intptr_t表示这是一个内存地址 然后传递给原始函数即可
    NSLog(@"======= QiuChenly load sub_10036BC40_hook called original return value is %d, args1 = %p", ret, &a1);
    return 0x1;
}

void CleanMyMacHook() {
    if (!checkSelfInject("com.macpaw.CleanMyMac4")) return;
//    if (!checkSelfInject("com.macpaw.zh.CleanMyMac4")) return;
    //返回值 (*函数名)(参数类型列表)
    //中文版4.12.3基址 0x10036BC40
    //国际版4.12.4基址 0x1003B4A00
    //4.12.5 0x1003B4A20
    //4.13.0b1 0x1003B45C0
    //4.13.0b2 0x1003B45C0
    //4.13.0 0x1003B7EE0 正式版
    //4.13.2 (41302.0.2304030900) 0x1003B7EE0 正式版

    intptr_t ptr;

    if (checkAppVersion("4.13.3") || checkAppVersion("4.13.4"))
        ptr = 0x1003a76e0;
    else
        ptr = 0x1003a76e0;

    hookPtrZ(ptr, sub_10036BC40_hook, (void **) &sub_10036BC40_org);
//    intptr_t sub_10036BC40 = _dyld_get_image_vmaddr_slide(0) + ptr;//获取第0个镜像基地址 加上偏移地址
//    rd_route((void *) sub_10036BC40, sub_10036BC40_hook, (void **) &sub_10036BC40_org);
    NSLog(@"==== QiuChenly load sub_10036BC40 即将被替换的函数地址 %p - 替换的内存地址: %p", (void *) ptr, sub_10036BC40_hook);

//    NSLog(@"======= QiuChenly load hasLoggedInUser =======");
//    Method ohasLoggedInUser = class_getInstanceMethod(NSClassFromString(@"CMMacPawAccountActivationManager"), NSSelectorFromString(@"hasLoggedInUser"));
//    Method nhasLoggedInUser = class_getInstanceMethod([InlineInjectPlugin class], @selector(hasLoggedInUser));
//    method_exchangeImplementations(ohasLoggedInUser, nhasLoggedInUser);//常规交换函数实现
    Method oMPAActivationInfoViewController = getMethodStr(@"MPAActivationInfoViewController", @"updateUIForCustomer:licenseValidationResult:");
    IMP nMPAActivationInfoViewController = getMethodImplementation([InlineInjectPlugin class], @selector(updateUIForCustomer:licenseValidationResult:));
    //IMP函数实现和Selector的极限拉扯
    originalFun = setMethod(oMPAActivationInfoViewController, nMPAActivationInfoViewController);//设置新的IMP实现到系统中
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

void iShot(void) {
    if (!checkSelfInject("cn.better365.ishot")) return;
    intptr_t sub_100064A0E = _dyld_get_image_vmaddr_slide(0) + 0x100065A3E;//获取第0个镜像基地址 加上偏移地址

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
    if (checkAppVersion("1.5.14")) {
        intptr_t _0x69d90 = _dyld_get_image_vmaddr_slide(0) + 0x100069D90;
        rd_route((void *) _0x69d90, _0x69d90a, (void **) &_0x69d90_native);
    }

    if (checkAppVersion("1.5.15")) {
        hookPtrA(0x100069030, ret1);
    }
//    intptr_t addr = _dyld_get_image_vmaddr_slide(0) + 0x1000A4750;
//    rd_route((void *) addr, aboutDialogNew, (void **) &aboutDialogOri);
}
// End Macs Fan Control


//AirBuddy2 Start

int (*_0x100050480Ori)();

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

- (id)mwebproproduct {
    id ret = class_createInstance(objc_getClass("PADProduct"), 0);
    return ret;
}

- (void)verifyActivationDetailsWithCompletion:arg1 {

}

void mwebPro(void) {
    if (!checkSelfInject("com.coderforart.MWeb3")) return;
    switchMethod(getMethodStr(@"CFAPaddleMWConfig", @"product"), getMethod([InlineInjectPlugin class], @selector(mwebproproduct)));
    switchMethod(getMethodStr(@"PADProduct", @"verifyActivationDetailsWithCompletion:"), getMethod([InlineInjectPlugin class], @selector(verifyActivationDetailsWithCompletion:)));
    switchMethod(getMethodStr(@"PADProduct", @"activated"), getMethod([InlineInjectPlugin class], @selector(ret1)));
    switchMethod(getMethodStr(@"PADProduct", @"activationEmail"), getMethod([InlineInjectPlugin class], @selector(activationEmail)));
    switchMethod(getMethodStr(@"PADProduct", @"activationID"), getMethod([InlineInjectPlugin class], @selector(activationID)));
//    Method activation = class_getInstanceMethod(NSClassFromString(@"PADProduct"), NSSelectorFromString(@"activated"));
//    Method nActivation = class_getInstanceMethod([InlineInjectPlugin class], @selector(isAppActivated));
//    method_exchangeImplementations(activation, nActivation);

//    Method activationEmail = class_getInstanceMethod(NSClassFromString(@"PADProduct"), NSSelectorFromString(@"activationEmail"));
//    Method nactivationEmail = class_getInstanceMethod([InlineInjectPlugin class], @selector(activationEmail));
//    method_exchangeImplementations(activationEmail, nactivationEmail);
//
//    Method activationID = class_getInstanceMethod(NSClassFromString(@"PADProduct"), NSSelectorFromString(@"activationID"));
//    Method nactivationID = class_getInstanceMethod([InlineInjectPlugin class], @selector(activationID));
//    method_exchangeImplementations(activationID, nactivationID);
}
//End MWebPro

// Start Bandizip


void bandizip(void) {
    if (!checkSelfInject("com.bandisoft.mac.bandizip365")) return;
    //去掉签名检查
    //7.19 0x1000821B0
    //7.20 0x1000876d0
    //7.22 0x10008A800
    if (checkAppVersion("7.2.0")) hookPtrA(0x1000876d0, ret1);
    else if (checkAppVersion("7.21")) hookPtrA(0x100087050, ret1);
    else if (checkAppVersion("7.22")) hookPtrA(0x10008A800, ret1);
    //激活
    switchMethod(getMethodStr(@"LicenseManager", @"isSubscriptionEdition"), getMethod([InlineInjectPlugin class], @selector(ret1)));
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
    hookPtrA(0x100083148, ret1);
    switchMethod(getMethodStr(@"PMPurchaseInfo", @"licenseSummary"), getMethod([InlineInjectPlugin class], @selector(licenseSummary)));
    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasLicenseKey"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"isFullAppUnlocked"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasInAppPurchase"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasPaidReceipt"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasReceipt"), getMethod([InlineInjectPlugin class], @selector(ret1)));
}

//end popclip

//Start Parallels Desktop
void Parallels() {
    if (!checkSelfInject("com.parallels.desktop.dispatcher")) return;
    if (checkAppCFBundleVersion("53488")) {
        hookPtrA(0x1005b0700, ret1);
        hookPtrA(0x1007c9300, ret1);
    } else if (checkAppCFBundleVersion("53606")) {
        /*
         *  _const:00000001009B6AF8                                         ; DATA XREF: __const:00000001009B6B18↓o
            __const:00000001009B6AF8                                         ; `vtable for'__cxxabiv1::__class_type_info
            __const:00000001009B6B00                 dq offset aN9signature24i ; "N9Signature24ICertificateChainCheckerE"
            __const:00000001009B6B08 off_1009B6B08   dq offset __ZTVN10__cxxabiv120__si_class_type_infoE+10h
            __const:00000001009B6B08                                         ; DATA XREF: __const:00000001009B6AD8↑o
            __const:00000001009B6B08                                         ; `vtable for'__cxxabiv1::__si_class_type_info
            __const:00000001009B6B10                 dq offset aN9signature16c ; "N9Signature16ChainCheckerImplE"
            __const:00000001009B6B18                 dq offset off_1009B6AF8
            __const:00000001009B6B20 unk_1009B6B20   db    0                 ; DATA XREF: sub_10034CA00+28↑o
            __const:00000001009B6B21                 db    0
            __const:00000001009B6B22                 db    0
            __const:00000001009B6B23                 db    0
            __const:00000001009B6B24                 db    0
            __const:00000001009B6B25                 db    0
            __const:00000001009B6B26                 db    0
            __const:00000001009B6B27                 db    0
            __const:00000001009B6B28                 dq offset off_1009B6B58
            __const:00000001009B6B30                 dq offset sub_1005B46B0
            __const:00000001009B6B38                 dq offset sub_1005B46C0
            __const:00000001009B6B40                 dq offset sub_1005B4330 <--- patch这里
         */
        hookPtrA(0x1005B4330, ret1);
        // /usr/bin/codesign 调用 codesign 的函数
        /**
         *  __text:00000001007CD000 ; __int64 __fastcall sub_1007CD000(__int64, unsigned int, _BYTE *, const char *, const char *, __int64, char)
            __text:00000001007CD000 sub_1007CD000   proc near               ; CODE XREF: sub_1001779D0+28F↑p
            __text:00000001007CD000
            __text:00000001007CD000 var_458         = qword ptr -458h
            __text:00000001007CD000 var_450         = qword ptr -450h
            __text:00000001007CD000 var_448         = qword ptr -448h
            __text:00000001007CD000 var_440         = qword ptr -440h
            __text:00000001007CD000 var_438         = dword ptr -438h
            __text:00000001007CD000 var_430         = byte ptr -430h
            __text:00000001007CD000 var_30          = qword ptr -30h
            __text:00000001007CD000
            __text:00000001007CD000                 push    rbp
            __text:00000001007CD001                 mov     rbp, rsp
            __text:00000001007CD004                 push    r15
            __text:00000001007CD006                 push    r14
            __text:00000001007CD008                 push    r13
            __text:00000001007CD00A                 push    r12
            __text:00000001007CD00C                 push    rbx
            __text:00000001007CD00D                 sub     rsp, 438h
            __text:00000001007CD014                 mov     [rbp+var_448], r8
            __text:00000001007CD01B                 mov     [rbp+var_450], rcx
            __text:00000001007CD022                 mov     [rbp+var_458], rdx
            __text:00000001007CD029                 mov     r12d, esi
            __text:00000001007CD02C                 mov     rbx, rdi
            __text:00000001007CD02F                 mov     rax, cs:___stack_chk_guard_ptr
            __text:00000001007CD036                 mov     rax, [rax]
            __text:00000001007CD039                 mov     [rbp+var_30], rax
            __text:00000001007CD03D                 mov     rcx, cs:off_100A45658 ; "4C6364ACXT"
            __text:00000001007CD044                 lea     rdx, aAnchorAppleGen ; "=anchor apple generic and certificate l"...
            __text:00000001007CD04B                 xor     r14d, r14d
            __text:00000001007CD04E                 lea     rdi, [rbp+var_430] ; char *
            __text:00000001007CD055                 mov     esi, 400h       ; size_t
            __text:00000001007CD05A                 xor     eax, eax
            __text:00000001007CD05C                 call    _snprintf
            __text:00000001007CD061                 mov     [rbp+var_440], 0
            __text:00000001007CD06C                 lea     rdi, aUsrBinCodesign ; "/usr/bin/codesign"
            __text:00000001007CD073                 mov     esi, 1          ; int
            __text:00000001007CD078                 call    _access
            __text:00000001007CD07D                 test    eax, eax
            __text:00000001007CD07F                 jz      short loc_1007CD0AA
         */
        hookPtrA(0x1007CD000, ret1);
    }

//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"licenseSummary"), getMethod([InlineInjectPlugin class], @selector(licenseSummary)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasLicenseKey"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"isFullAppUnlocked"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasInAppPurchase"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasPaidReceipt"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"PMPurchaseInfo", @"hasReceipt"), getMethod([InlineInjectPlugin class], @selector(ret1)));
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
     *  char __cdecl -[_TtC13App_Cleaner_822BaseFeaturesController isUnlocked](
            _TtC13App_Cleaner_822BaseFeaturesController *self,
            SEL a2
        )
    {
      __int64 v2; // r13
      __int64 (__fastcall *v3)(_TtC13App_Cleaner_822BaseFeaturesController *, SEL); // r15
      id v4; // r14
      char v5; // bl

      v2 = (*(&self->super.isa + OBJC_IVAR____TtC13App_Cleaner_822BaseFeaturesController_licenseManager))[5];
      v3 = *(*v2 + 200LL);  <----- 此处调用的函数返回 1 即可通过校验
      swift_retain(v2);
      v4 = objc_retain(self);
      v5 = v3(self, a2);
      objc_release(v4);
      swift_release(v2);
      return (v5 - 1) < 3u;
    }
     */
    if (checkAppVersion("8.1")) {
        hookPtrA(0x100403DC0, ret1);
    } else if (checkAppVersion("8.1.1")) {
        hookPtrA(0x100405830, ret1);
    } else if (checkAppVersion("8.1.2")) {
        hookPtrA(0x1003FD9F0, ret1);
    } else if (checkAppVersion("8.1.3")) {
        hookPtrA(0x100415D90, ret1);
    } else if (checkAppVersion("8.1.4")) {
        hookPtrA(0x100415FF0, ret1);
    }
    //switchMethod(getMethodStr(@"_TtC13App_Cleaner_822BaseFeaturesController", @"isUnlocked"), getMethod([InlineInjectPlugin class], @selector(ret1)));
    //去掉打开软件弹框提示试用过期
    switchMethod(getMethodStr(@"_TtC13App_Cleaner_822BaseFeaturesController", @"onAppDidFinishLaunching"), getMethod([InlineInjectPlugin class], @selector(ret1)));
//    switchMethod(getMethodStr(@"_TtC21NKCommonCocoaControls9NKAboutWC", @"setVersionLabel"), getMethod([InlineInjectPlugin class], @selector(activationID)));
    //    switchMethod(getMethodStr(@"_TtC21NKCommonCocoaControls20LicenseWCLocalizable", @"contactUsButton"), getMethod([InlineInjectPlugin class], @selector(activationID)));
//    switchMethod(getMethodStr(@"_TtC13App_Cleaner_820LicenseWCLocalizable", @"contactUsButton"), getMethod([InlineInjectPlugin class], @selector(activationID)));
}

//end AppCleaner

void OmiRecorder() {
    if (!checkSelfInject("com.mac.utility.screen.recorder")) return;
    //MAS 版本1.2.4 (2023020802)
    hookPtrA(0x10001C810, ret1);
}

void FigPlayer() {
    if (!checkSelfInject("com.mac.utility.video.player.PotPlayerX")) return;
    //MAS 版本1.2.2 (2023022001)
    //MAS 版本1.2.3 (2023032401)
    //    1.3.0 (2023051702)
    if (checkAppVersion("1.2.2") || checkAppVersion("1.2.3")) {
        hookPtrA(0x1000765F0, ret1);
    } else if (checkAppVersion("1.3.0")) {
        hookPtrA(0x100076090, ret1);
    }
}


int passcheck() {
    NSLog(@"==== get check");
    return 2;
}

/**
 * Sublime Text v4147
 */
void sublimeText4() {
    if (!checkSelfInject("com.sublimetext.4")) return;
    //官方版本4147
    if (checkAppVersion("Build 4147")) {
        NSLog(@"==== 4147 loading");
        hookPtrA(0x10051C86F, ret1);
    }
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
        hookPtrA(0x1000983a0, ret1);//AppStore版本
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

/**
 解优2 AppStore https://apps.apple.com/cn/app/%E8%A7%A3%E4%BC%98-2-%E4%B8%93%E4%B8%9A%E7%9A%84-7z-rar-zip-%E8%A7%A3%E5%8E%8B%E7%BC%A9%E5%B7%A5%E5%85%B7/id1525983573?mt=12
 */
void BestZip2(void) {
    if (!checkSelfInject("com.artdesktop.bestzip2")) return;
    if (!checkAppVersion("1.6.x")) {
        // 兼容以后版本
        switchMethod(getMethodStr(@"EIAPManager", @"purchased"), getMethod([InlineInjectPlugin class], @selector(ret1)));
    }
}

/**
 OmniPlayer AppStore https://apps.apple.com/cn/app/omni-player-%E9%AB%98%E6%B8%85%E5%BD%B1%E9%9F%B3%E6%92%AD%E6%94%BE%E5%99%A8/id1470926410?mt=12
 v12 = a1;
 if ( qword_100888220 != -1 )
   swift_once(&qword_100888220, sub_1001E5170);
 v1 = (void *)swift_getInitializedObjCClass(&OBJC_CLASS___NSUserDefaults);
 v2 = v1;
 v3 = objc_msgSend(v1, "standardUserDefaults", v12);
 v4 = (void *)objc_retainAutoreleasedReturnValue(v3);
 v5 = _sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(
        -3458764513820540912LL,
        (unsigned __int64)"sub-border-color" | 0x8000000000000000LL);
 v6 = (unsigned __int64)objc_msgSend(v4, "boolForKey:", v5);
 objc_release(v4);
 objc_release(v5);
 result = 1;
 if ( !v6 )
 {
   v8 = objc_msgSend(v2, "standardUserDefaults");
   v9 = (void *)objc_retainAutoreleasedReturnValue(v8);
   v10 = _sSS10FoundationE19_bridgeToObjectiveCSo8NSStringCyF(
           -3458764513820540907LL,
           (unsigned __int64)"isOneTimePaidApp" | 0x8000000000000000LL);
   v11 = (unsigned __int64)objc_msgSend(v9, "boolForKey:", v10);
   objc_release(v9);
   objc_release(v10);
   result = v11 != 0;
 }
 return result;
}
 */
void OmniPlayer(void) {
    if (!checkSelfInject("com.mac.utility.media.player")) return;
    if (checkAppVersion("2.0.18") || checkAppVersion("2.0.19")) {
        hookPtrA(0x1001C1600, ret1);
    } else if (checkAppVersion("2.1.0")) {
        hookPtrA(0x1001C4080, ret1);
    }
}

/**
 <key>CFBundleIdentifier</key>
     <string>com.filmage.screen.mac</string>
     <key>CFBundleInfoDictionaryVersion</key>
     <string>6.0</string>
     <key>CFBundleName</key>
     <string>Filmage Screen</string>
     <key>CFBundlePackageType</key>
     <string>APPL</string>
     <key>CFBundleShortVersionString</key>
     <string>1.4.7</string>
 */
void filmagescreen(void) {
    if (!checkSelfInject("com.filmage.screen.mac")) return;
    if (!checkAppVersion("1.4.7.x")) {
        switchMethod(getMethodStr(@"IAPWindow", @"didPay"), getMethod([InlineInjectPlugin class], @selector(ret1)));
    }
}

- (void)validate {
    NSLog(@"==== validate 函数绕过成功。");
}


/**
 * Navicat Premium 16.1.7
 * MAS版本 https://apps.apple.com/cn/app/navicat-premium-16/id1594061654?mt=12
 */
void NavicatPremium(void) {
    if (!checkSelfInject("com.navicat.NavicatPremium")) return;

    //class_getInstanceMethod 得到类的实例方法
    //class_getClassMethod 得到类的类方法

    if (!checkAppVersion("16.1.7.x")) {

        uint32_t size = _dyld_image_count();//获取所有加载的映像
        NSLog(@"==== 加载的映像数量: %i", size);

        NSLog(@"==== 函数地址：validate = %p ，函数地址：isProductSubscriptionStillValid = %p",
                getMethodStrByCls(@"AppStoreReceiptValidation", @"validate"),
                getMethodStr(@"IAPHelper", @"isProductSubscriptionStillValid")
        );

        for (int a = 0; a < size; a++) {
            const char *name = _dyld_get_image_name(a);//根据映像下标取名称
            NSLog(@"==== Slide: %i,ModuleName: %s", a, name);

            if (strcmp("/Applications/Navicat Premium.app/Contents/Frameworks/libcc-premium.dylib", name) == 0) {
                NSLog(@"==== find libcc-premium.dylib!");
                //class_getClassMethod这里不能用Instance 会返回nil 从gpt回复中可以看出类的实例不代表类函数 所以一般应该用getClassMethod就不会报错nil
                // 下面是ChatGPT的回答
                /**
                 可以这样理解：

                 在Objective-C中，方法是通过消息传递来调用的。当我们调用一个方法时，实际上是向对象发送了一个消息，让它去执行对应的方法。因此，我们需要知道方法的名称和参数类型，才能正确地发送消息。

                 在获取方法的时候，我们需要使用Method对象来表示方法。Method对象包含了方法的名称、参数类型、返回值类型等信息，可以用来发送消息。

                 class_getInstanceMethod和class_getClassMethod就是用来获取Method对象的函数。它们的区别在于，class_getInstanceMethod用于获取实例方法，即针对对象的方法；而class_getClassMethod用于获取类方法，即针对类的方法。

                 举个例子，假设我们有一个Person类，它有一个实例方法run和一个类方法eat。如果我们要获取run方法的Method对象，可以使用class_getInstanceMethod(Person.class, @selector(run))；如果要获取eat方法的Method对象，可以使用class_getClassMethod(Person.class, @selector(eat))。

                 需要注意的是，类方法是属于类的，而不是属于类的实例。因此，如果要获取类方法的Method对象，需要使用类对象而不是实例对象。例如，对于类Person，可以使用[Person class]获取它的类对象，然后再使用class_getClassMethod获取类方法的Method对象。
                 */
                switchMethod(getMethodStrByCls(@"AppStoreReceiptValidation", @"validate"), getMethod([InlineInjectPlugin class], @selector(validate)));
                continue;
            }

            if (strcmp("/Applications/Navicat Premium.app/Contents/MacOS/Navicat Premium", name) == 0) {
                NSLog(@"==== find Navicat Premium!");
                switchMethod(getMethodStr(@"IAPHelper", @"isProductSubscriptionStillValid"), getMethod([InlineInjectPlugin class], @selector(ret1)));
                continue;
            }
        }
    }
}


- (id)iapStatus {
    id it = class_createInstance(objc_getClass("FCTraktIAPStatus"), 0);
    [it performSelector:NSSelectorFromString(@"setExpirationDate:") withObject:@0];
//    [it performSelector:NSSelectorFromString(@"setStatus:") withObject:@1]; //这个函数这样子调用居然无效 我是真不懂了这下
    [it performSelector:NSSelectorFromString(@"setUnlockedDTS:") withObject:@1];
    [it performSelector:NSSelectorFromString(@"setUnlockedDolby:") withObject:@1];

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:2999];
    [dateComponents setMonth:5];
    [dateComponents setDay:25];
    [dateComponents setHour:15];
    [dateComponents setMinute:30];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *customDate = [calendar dateFromComponents:dateComponents];
    [it performSelector:NSSelectorFromString(@"setExpirationDate:") withObject:customDate];
    NSLog(@"输出 %@", it);
    return it;
}

/**
 * Infuse 7.5.4381
 * 版本7.5.1 (7.5.4394)
 * https://apps.apple.com/cn/app/infuse-%E6%99%BA%E8%83%BD%E8%A7%86%E9%A2%91%E6%92%AD%E6%94%BE%E5%99%A8/id1136220934
 */
void infuse(void) {
    if (!checkSelfInject("com.firecore.infuse")) return;
    if (checkAppCFBundleVersion("7.5.4410") || checkAppCFBundleVersion("7.5.4425") || TRUE) {
        NSLog(@"Loading InFuse 4410");
        switchMethod(getMethodStr(@"FCTraktIAPStatus", @"status"), getMethod([InlineInjectPlugin class], @selector(ret1)));
        switchMethod(getMethodStr(@"FCTraktIAPManager", @"receivedStatus"), getMethod([InlineInjectPlugin class], @selector(iapStatus)));
        return;
//        switchMethod(getMethodStr(@"FCInAppPurchaseServiceFreemium", @"iapVersionStatus"), getMethod([InlineInjectPlugin class], @selector(ret1)));
        switchMethod(getMethodStr(@"FCTraktIAPManager", @"iapStatus"), getMethod([InlineInjectPlugin class], @selector(iapStatus)));
        switchMethod(getMethodStr(@"FCTraktIAPStatus", @"isAlivePro"), getMethod([InlineInjectPlugin class], @selector(ret1)));
        switchMethod(getMethodStr(@"FCTraktIAPManager", @"deviceList"), getMethod([InlineInjectPlugin class], @selector(ret1)));
        switchMethod(getMethodStr(@"FCTraktTVDeviceList", @"containsCurrentDevice"), getMethod([InlineInjectPlugin class], @selector(ret1)));
    } else if (checkAppCFBundleVersion("7.5.4381")) {
        NSLog(@"Loading InFuse 4381");
        switchMethod(getMethodStr(@"FCInAppPurchaseServiceMobile", @"iapVersionStatus"), getMethod([InlineInjectPlugin class], @selector(ret1)));
    }
}

/**
 * Paste 3.1.9
 * https://apps.apple.com/cn/app/paste-clipboard-manager/id967805235
 */
void Paste(void) {
    if (!checkSelfInject("com.wiheads.paste")) return;
    if (checkAppVersion("3.1.9")) {
        NSLog(@"Loading Paste");
        hookPtrA(0x1001f9f10, ret0);
    }
}

/**
 * Office 全家桶 MAS版本破解
 * 16.71 365订阅
 * ```
 * void __cdecl -[DocsUILicensing handleActivationStateChange:](DocsUILicensing *self, SEL a2, id a3){
       void ***v3; // rax
       id v4; // rbx

       if ( (unsigned __int8)_objc_msgSend(self, "isActivated", a3) )
       {
         v3 = off_20DFFC0;
       }
       else if ( (unsigned __int8)_objc_msgSend(self, "canRenew") )
       {
         v3 = off_20DFFC8;
       }
       else
       {
         v3 = &off_20DFFD0;
       }
       v4 = objc_retain(*v3);
       _objc_msgSend(&OBJC_CLASS___DocsUIBridgeNotifications, "sendNotification:object:", v4, self);
       _objc_release(v4);
     }
 * ```
 */
void Office(void) {
    if (checkSelfInject("com.microsoft.Excel") || checkSelfInject("com.microsoft.Powerpoint") || checkSelfInject("com.microsoft.Word")) {
        uint32_t mso99_addr;
        uint32_t mso30_addr;

        uint32_t mso30 = getImageVMAddrSlideIndex("mso30");
        uint32_t mso99 = getImageVMAddrSlideIndex("mso99");
        if (checkAppVersion("16.71")) {
            mso99_addr = 0x5076;
            mso30_addr = 0x81b0f;
        } else if (checkAppVersion("16.72")) {
            mso30_addr = 0x7e82f;
            mso99_addr = 0x6666;
        } else if (checkAppVersion("16.73")) {
            mso30_addr = 0x8167f; //Mso::Licensing::Category::IsSubscription
            mso99_addr = 0x5356; //-[DocsUILicensing isActivated]: 找 call       qword [rcx+8]
        } else {
            NSLog(@"版本不对，取消注入。");
            return;
        }
        hookPtr(mso99, mso99_addr, ret1, NULL);
        hookPtr(mso30, mso30_addr, ret1, NULL);
    }
}

void AdobeApps(void) {
    if (checkSelfInject("com.adobe.Photoshop")) {
//        rd_route_byname("adobe::nglcontroller::NglController::ProcessV2Profile", _dyld_get_image_name(0), ret1, NULL);
        //Adobe Photoshop 2023
        if (checkAppVersion("24.2.0")) {
            NSLog(@"Loading AdobeApps 24.2.0");
            hookPtrA(0x10412069E, ret1);
        } else if (checkAppVersion("24.4.1")) {
            NSLog(@"Loading AdobeApps 24.4.1");
            // %s: Initial profile failure: not licensed from cache (profile status %d) 搜索这个直接定位到目标函数
            // (*(void (__fastcall **)(__int64, const char *, const char *, _QWORD))(*(_QWORD *)v114 + 32LL))(
            //          v114,
            //          "%s: Initial profile failure: licensed from cache (profile status %d)",
            //          "ProcessV2Profile",
            //          *v101);

            // __int64 __fastcall adobe::nglcontroller::NglController::ProcessV2Profile(__int64 a1, __int64 a2, __int64 a3, __int64 a4)

            // https://ims-prod06.adobelogin.com/ims/token/v4
            hookPtrA(0x1041BA110, ret1);//这个函数是实际检查用户权限函数 nop掉就不提示窗口
//        hookPtrA(0x10424E59C, ret1);//这个函数是检查账户权限线程
        } else if (checkAppVersion("24.5.0")) {
            hookPtrA(0x10420BE40, ret1);
        } else if (checkAppVersion("24.6.0")) {
            hookPtrA(0x10430a6b0, ret1);
        }
    }

    if (checkSelfInject("com.adobe.LightroomClassicCC7")) {
        //Adobe Lightroom Classic
        if (checkAppVersion("12.3")) {
            NSLog(@"Loading LightroomClassicCC7 12.3");
//            hookPtrA(0x1001AE6C7, ret1);
            hookPtrA(0x100027638, ret1);
//            hookPtrA(0x1001BA216, ret0);
        }
    }

    if (checkSelfInject("com.adobe.Adobe-Animate-2023.application")) {
        //Adobe Animate 2023
        if (checkAppVersion("23.0.1")) {
            NSLog(@"Loading Adobe Animate 2023 23.0.1");
            hookPtrA(0x100019F10, ret1);
        }
    }

    if (checkSelfInject("com.adobe.xd")) {
        //sudo insert_dylib /Users/qiuchenly/Library/Caches/JetBrains/AppCode2023.1/DerivedData/InlineInjectPlugin-eklzvojrwuuobhdysecelanfrlvy/Build/Products/Debug/libInlineInjectPlugin.dylib /Applications/Adobe\ XD/Adobe\ XD.app/Contents/Frameworks/nanopb.framework/Versions/A/nanopb_副本 /Applications/Adobe\ XD/Adobe\ XD.app/Contents/Frameworks/nanopb.framework/Versions/A/nanopb
        //Adobe XD
        if (checkAppVersion("56.1.12.1")) {
            NSLog(@"Loading Adobe XD 56.1.12.1");
            hookPtrA(0x100B78FC4, ret1);
        }
    }

    if (checkSelfInject("com.adobe.Audition")) {
        //Adobe Audition 2023
        if (checkAppVersion("23.3")) {
            NSLog(@"==== Loading Adobe Audition 2023 23.3");
            uint32_t AuUI = getImageVMAddrSlideIndex("AuUI.framework/Versions/A/AuUI");
            hookPtr(AuUI, 0xD06D40, ret1, NULL);
        }
    }

    if (checkSelfInject("com.adobe.illustrator")) {
        //Adobe Illustrator
        if (checkAppVersion("27.5.0")) {
            NSLog(@"Loading com.adobe.illustrator 27.5.0");
            hookPtrA(0x100BF9F84, ret1);
        }
    }

    if (checkSelfInject("com.adobe.dreamweaver-18.1")) {
        //Adobe Illustrator
        if (checkAppVersion("21.3.0.15593")) {
            NSLog(@"Loading com.adobe.dreamweaver-18.1 21.3.0.15593");
            hookPtrA(0x1018927C0, ret1);
        }
    }

    if (checkSelfInject("com.adobe.AfterEffects")) {
        //After Effects 2023
        uint32_t AfterFXLib = getImageVMAddrSlideIndex("AfterFXLib");
        if (checkAppVersion("23.3")) {
            NSLog(@"Loading com.adobe.AfterEffects 23.3");
            hookPtr(AfterFXLib, 0x11C52C0, ret1, NULL);
        } else if (checkAppVersion("23.4")) {
            NSLog(@"Loading com.adobe.AfterEffects 23.4");
            hookPtr(AfterFXLib, 0x11e99a0, ret1, NULL);
        }
    }

    if (checkSelfInject("com.adobe.ame.application.23")) {
        //Adobe Media Encoder 2023
        if (checkAppVersion("23.3")) {
            NSLog(@"Loading Adobe Media Encoder 2023 23.3");
            hookPtrA(0x1000E3180, ret1);
        } else if (checkAppVersion("23.4")) {
            NSLog(@"Loading Adobe Media Encoder 2023 23.4");
            hookPtrA(0x1000eaed0, ret1);
        }
    }

    if (checkSelfInject("com.adobe.PremierePro.23")) {
        //Adobe Premiere Pro 2023
        uint32_t AfterFXLib = getImageVMAddrSlideIndex("Frontend");
        uint32_t Registration = getImageVMAddrSlideIndex("Registration");
        if (checkAppVersion("23.3")) {
            NSLog(@"Loading com.adobe.PremierePro 23.3");
//            hookPtr(AfterFXLib, 0x2095C0, ret1, NULL);
            hookPtr(Registration, 0x4D3A0, ret1, NULL);
        } else if (checkAppVersion("23.4")) {
            NSLog(@"Loading com.adobe.PremierePro 23.4");
            hookPtr(Registration, 0x5c950, ret1, NULL);
        }
    }

    if (checkSelfInject("com.adobe.Acrobat.Pro")) {
        //Acrobat
        if (checkAppVersion("23.001.20143")) {
            NSLog(@"Loading Acrobat 23.001.20143");
            uint32_t Acrobat = getImageVMAddrSlideIndex("Acrobat.framework/Versions/A/Acrobat");
            hookPtr(Acrobat, 0x16EE830, ret1, NULL);
        } else if (checkAppVersion("23.001.20177")) {
            NSLog(@"Loading Acrobat 23.001.20177");
            uint32_t Acrobat = getImageVMAddrSlideIndex("Acrobat.framework/Versions/A/Acrobat");
            hookPtr(Acrobat, 0x16EE830, ret1, NULL);
        }
    }

    if (checkSelfInject("com.adobe.distiller")) {
        //Acrobat Distiller
        if (checkAppVersion("23.001.20143")) {
            NSLog(@"Loading Acrobat Distiller 23.001.20143");
            uint32_t Acrobat = getImageVMAddrSlideIndex("DistillerLib.framework/Versions/A/DistillerLib");
            hookPtr(Acrobat, 0x1F70F0, ret1, NULL);
        }
    }

    // image list -o -f | grep PublicLib.dylib
    // br s -n "+[NSURL URLWithString:]" 定位找到线程位置
    if (checkSelfInject("com.adobe.InCopy")) {
        uint32_t Acrobat = getImageVMAddrSlideIndex("MacOS/PublicLib.dylib");
        if (checkAppVersion("18.2.1.455")) {
            hookPtr(Acrobat, 0x237f30, ret1, NULL);
        } else if (checkAppVersion("18.3.0.50")) {
            hookPtr(Acrobat, 0x23A100, ret1, NULL);
        }
    }

    if (checkSelfInject("com.adobe.InDesign")) {
        uint32_t Acrobat = getImageVMAddrSlideIndex("MacOS/PublicLib.dylib");
        if (checkAppVersion("18.2.1.455")) {
            hookPtr(Acrobat, 0x237f30, ret1, NULL);
        } else if (checkAppVersion("18.3.0.50")) {
            hookPtr(Acrobat, 0x23A100, ret1, NULL);
        }
    }
}

/**
 * 旧版劫持代码方式 其实可以直接调用
 * @param a1
 * @param a2
 * @return
 */
int revertMain(int a1, int a2) {
    int (*sub_10041F51E)(int, int) = (void *) getImageAddress(0x10041F51E);//MainApplication绕过执行反调试代码
    return sub_10041F51E(a1, a2);
}

int ret2(void) {
    //5.1.1 2235
//    int *dword_1007E0DE0 = (void *) _dyld_get_image_vmaddr_slide(0) + 0x1007E0DE0;
//    *dword_1007E0DE0 = 2; //强制修改内存地址中的激活值

    //5.1.1 2237
//    *dword_1007E0EA0 = 2
    //幸好这里只需要劫持这个函数即可 否则修改内存地址在这里还需要单独判断并修改

    int r = hookMethod();
    NSLog(@"==== 输出的原始返回值 %i", r);
    r = 2;
    NSLog(@"==== 输出的修改返回值 %i", r);
    return r;
}

/**
 * 更新授权信息 让字符串正常显示
 * @return
 */
- (id)settings {
    id ret = class_createInstance(objc_getClass("SGMEnterpriseSettings"), 0);
    [ret performSelector:NSSelectorFromString(@"setCompanyID:") withObject:@"QiuChenly"];
    [ret performSelector:NSSelectorFromString(@"setCompanyName:") withObject:@"K'ed By TNT｜HCISO"];
    [ret performSelector:NSSelectorFromString(@"setUserID:") withObject:@"QiuChenly@52pojie.cn"];
    return ret;
}

/**
 * 原始函数指针
 * @return
 */
int (*hookMethod)() = NULL;

void surge(void) {
    if (!checkSelfInject("com.nssurge.surge-mac")) return;
    if (checkAppVersion("5.1.0")) {
        hookPtrA(0x1002ABCBE, revertMain);//过掉反调试
        hookPtrA(0x100185a43, ret2);//返回 2 即可
    } else if (checkAppVersion("5.1.1") && checkAppCFBundleVersion("2235")) {
        hookPtrA(0x1002B0D9C, (void *) getImageAddress(0x10057F162));//过掉反调试 直接把入口函数挂到 MainApplication
        hookPtrZ(0x100189921, ret2, (void **) &hookMethod);//劫持返回函数 用来返回 2 表示激活
        hookPtrA(0x1001724F7, ret1);// 改为企业版授权
    } else if (checkAppVersion("5.1.1") && (
            checkAppCFBundleVersion("2237") ||
                    checkAppCFBundleVersion("2238") ||
                    checkAppCFBundleVersion("2239") ||
                    TRUE
    )) {
        intptr_t start = 0x1002B0059;
        intptr_t active = 0x100188B51;
        intptr_t enterprise = 0x100171727;
        if (checkAppCFBundleVersion("2237")) {
            start = 0x1002B0059;
        } else if (checkAppCFBundleVersion("2238")) {
            start = 0x1002AFF59;
        } else if (checkAppCFBundleVersion("2239")) {
            start = 0x10057F162;
        } else if (checkAppCFBundleVersion("2264")) {
            start = 0x1002afc32;
            active = 0x100187ef1;
            enterprise = 0x100170a77;
        } else{
            //防止有些sb版本号不对非要去尝试注入 报错开始质疑我的能力 这种脑残我真的日死你的吗
            return;
        }
        hookPtrA(start, (void *) getImageAddress(0x10057F162));//过掉反调试 直接把入口函数挂到 MainApplication
        // void __cdecl -[WindowController exec](WindowController *self, SEL a2)
        hookPtrZ(active, ret2, (void **) &hookMethod);//劫持返回函数 用来返回 2 表示激活
        // void __cdecl -[SGMLicenseViewController viewDidLoad](SGMLicenseViewController *self, SEL a2)
        hookPtrA(enterprise, ret1);// 改为企业版授权
    }
    switchMethod(getMethodStr(@"SGMEnterprise", @"settings"), getMethod([InlineInjectPlugin class], @selector(settings)));//显示企业授权信息
}

void Reveal2(void) {
    if (!checkSelfInject("com.ittybittyapps.Reveal2")) return;

    if (checkAppCFBundleVersion("17801")) {
        intptr_t Security = getImageVMAddrSlideIndex("Security.framework/Versions/A/Security");
        hookPtrA(0x1006D10AB, ret1);//过掉反调试 Step1
    }
}

- (void)updateLicenceUI2 {
    NSLog(@"-====- updateLicenceUI %p", self);
    id m_currentTab = getInstanceIvar(self, "m_currentTab");
    NSLog(@"m_currentTab == %p", m_currentTab);

    if (!m_currentTab) {
        [getInstanceIvar(self, "accountNameLabel") performSelector:NSSelectorFromString(@"setStringValue:") withObject:@"秋城落叶@52pojie.cn"];
        [getInstanceIvar(self, "affinityIdLabel") performSelector:NSSelectorFromString(@"setStringValue:") withObject:@"秋城落叶@52pojie.cn"];

//        [getInstanceIvar(self, "exportPurchaseReceiptMenuItem") performSelector:NSSelectorFromString(@"setHidden:") withObject:@false];
//        [getInstanceIvar(self, "deleteAccountMenuItem") performSelector:NSSelectorFromString(@"setHidden:") withObject:@false];
//        [getInstanceIvar(self, "deleteAccountMenuItem") performSelector:NSSelectorFromString(@"setEnabled:") withObject:@true];
//        [getInstanceIvar(self, "deactivateDeviceMenuItem") performSelector:NSSelectorFromString(@"setHidden:") withObject:@false];

//        objc_msgSend(deleteAccountMenuItem, "setHidden:", v18 == 0);
//        objc_msgSend(self->deactivateDeviceMenuItem, "setEnabled:", v39);
//        objc_msgSend(self->exportPurchaseReceiptMenuItem, "setEnabled:", v12);
//        v19 = self->deleteAccountMenuItem;
//        objc_msgSend(v19, "setEnabled:", HasAccount);
//        objc_msgSend(exportPurchaseReceiptMenuItem, "setHidden:", v16 == 0);
        NSLog(@"m_currentTab Loading!");
    }
}

void affinity2(void) {
    if (checkSelfInject("com.seriflabs.affinityphoto2") || checkSelfInject("com.seriflabs.affinitydesigner2") || checkSelfInject("com.seriflabs.affinitypublisher2")) {
        // 2.1 1806
        if (checkAppVersion("2.1.0") && checkAppCFBundleVersion("1806")) {
            uint32_t libcocoaui = getImageVMAddrSlideIndex("libcocoaui.framework/Versions/A/libcocoaui");
            uint32_t liblibaffinity = getImageVMAddrSlideIndex("Frameworks/liblibaffinity.dylib");

            hookPtr(liblibaffinity, 0x10758D0, ret1, NULL);// Affinity::IsLicensed(Affinity *this, const Affinity::LicenceInfo *a2)
            hookPtr(liblibaffinity, 0x1075890, ret1, NULL);// Affinity::CanDeactivateLicence(Affinity *this, const Affinity::LicenceInfo *)
            hookPtr(liblibaffinity, 0x1075D90, ret0, NULL);// Affinity::IsTrialRunning(Affinity *this, const Affinity::LicenceInfo *)

            //libcocoaui 库中的函数
            // char __cdecl -[Application hasEntitlementToRun](Application *self, SEL a2)
            switchMethod(getMethodStr(@"Application", @"hasEntitlementToRun"), getMethod([InlineInjectPlugin class], @selector(ret1)));
            switchMethod(getMethodStr(@"UserStatusViewController", @"updateLicenceUI"), getMethod([InlineInjectPlugin class], @selector(updateLicenceUI2)));
        }
    }
}

- (NSString *)userInfo {
    return @"QiuChenly 破解 永远不会";
}

- (void)update_subscription {
    void (*update_subscription)(id, SEL) = (void *) org_update_subscription;
    update_subscription(self, NSSelectorFromString(@"update_subscription"));
    id ivar = getInstanceIvar(self, "m_subscription_label");
    [ivar performSelector:NSSelectorFromString(@"setString:") withObject:@"QiuChenly@52pojie.cn 永不过期"];
    [getInstanceIvar(self, "m_pay_btn") performSelector:NSSelectorFromString(@"setTitle:") withObject:@"无需续费"];
}

IMP org_update_subscription;

void effie(void) {
    if (checkSelfInject("co.effie.mac")) {
        if (checkAppVersion("2.7.1")) {
            switchMethod(getMethodStr(@"wm_UserMgr", @"subscriped"), getMethod([InlineInjectPlugin class], @selector(ret1)));
            switchMethod(getMethodStr(@"wm_UserMgr", @"subscription_info"), getMethod([InlineInjectPlugin class], @selector(userInfo)));
            org_update_subscription = setMethod(getMethodStr(@"wm_SettingsSubscriptionViewController", @"update_subscription"), getMethodImplementation([InlineInjectPlugin class], @selector(update_subscription)));
//            hookPtrA(0x1002565CE, ret1);
//            hookPtrA(0x10007CF4D, ret1);
//            switchMethod(getMethodStrByCls(@"wm_UserMgr", @"signed_in"), getMethod([InlineInjectPlugin class], @selector(ret1)));
        }
    }
}


+ (void)load {
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
    sublimeText4();
    BestZip2();
    OmniPlayer();
    filmagescreen();
    NavicatPremium();
    infuse();
//    Paste(); //无法使用
    Office();
    AdobeApps();
    surge();
    Reveal2();
    affinity2();
    effie();
}
@end