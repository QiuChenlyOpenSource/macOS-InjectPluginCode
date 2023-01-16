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

+ (void)load {
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

@end
