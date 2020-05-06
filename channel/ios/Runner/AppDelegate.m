#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import "TestViewController.h"


@interface AppDelegate()
//@property(strong,nonatomic)

@end

@implementation AppDelegate{
    FlutterMethodChannel* methodChannel;
    FlutterBasicMessageChannel* messageChannel;
    FlutterEventSink     eventSink;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationFuncion:) name:@"ios.to.flutter" object:nil];
    
    //FlutterMethodChannel 与 Flutter 之间的双向通信
    [self  methodChannelFunction];
    //FlutterBasicMessageChannel 与Flutter 之间的双向通信
    [self BasicMessageChannelFunction];
    //EventChannel 与Flutter 之间的通信
    [self EventChannelFunction];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
-(void) EventChannelFunction{
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:@"flutter_and_native_102" binaryMessenger:controller];
    [eventChannel setStreamHandler:self];
}


// // 这个onListen是Flutter端开始监听这个channel时的回调，第二个参数 EventSink是用来传数据的载体。
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    eventSink = events;
    //当点击了EventChannel这个通道后，比如上传电池电量，可以在电池电量的回调方法中，执行以下方法
    if (eventSink) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"pjw" forKey:@"message"];
        [dic setObject: [NSNumber numberWithInt:2220] forKey:@"code"];
        eventSink(dic);
    }
    return nil;
}

/// flutter不再接收
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    // arguments flutter给native的参数
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    eventSink = nil;
    return nil;
}


-(void) BasicMessageChannelFunction{
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    // 初始化定义
    messageChannel = [FlutterBasicMessageChannel messageChannelWithName:@"flutter_and_native_100" binaryMessenger:controller];
    // 接收消息监听
    [messageChannel setMessageHandler:^(id message, FlutterReply callback) {
        NSString *method=message[@"method"];
        if ([method isEqualToString:@"test"]) {
            NSLog(@"flutter调用到了ios传递过来的消息\n%@------%@------%@",message[@"code"],message[@"method"],message[@"ontent"]);
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"方式1:iOS传值给Flutter" forKey:@"message"];
            [dic setObject: [NSNumber numberWithInt:100] forKey:@"code"];
            callback(dic);
        }else  if ([method isEqualToString:@"test2"]) {
            NSLog(@"flutter调用到了ios传递过来的消息\n%@------%@------%@",message[@"code"],message[@"method"],message[@"ontent"]);
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"方式2:iOS传值给Flutter" forKey:@"message"];
            [dic setObject: [NSNumber numberWithInt:200] forKey:@"code"];
            [messageChannel sendMessage:dic];
        }
    }];
}

-(void) methodChannelFunction{
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    methodChannel = [FlutterMethodChannel
                     methodChannelWithName:@"flutter_and_native_101"
                     binaryMessenger:controller];
    [methodChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // TODO
        NSString *method=call.method;
        if ([method isEqualToString:@"test"]) {
            NSLog(@"flutter 调用到了 ios test");
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"iOS传值给Flutter" forKey:@"message"];
            [dic setObject: [NSNumber numberWithInt:200] forKey:@"code"];
            result(dic);
        }else  if ([method isEqualToString:@"test2"]) {
            NSLog(@"flutter 调用到了 ios test2");
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:@"iOS传值给Flutter" forKey:@"message"];
            [dic setObject: [NSNumber numberWithInt:200] forKey:@"code"];
            [methodChannel invokeMethod:@"test" arguments:dic];
        }else  if ([method isEqualToString:@"test3"]) {
            NSLog(@"flutter 调用到了 ios test3 打开一个新的页面 ");
            TestViewController *testController = [[TestViewController alloc]initWithNibName:@"TestViewController" bundle:nil];
            [controller presentViewController:testController animated:YES completion:nil];
        }
    }];
}


- (void)notificationFuncion: (NSNotification *) notification {
    //处理消息
    NSLog(@"notificationFuncion ");
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (methodChannel!=nil) {
        [dic setObject:@"methodChannel invokeMethod 向Flutter 发送消息 " forKey:@"message"];
        [dic setObject: [NSNumber numberWithInt:400] forKey:@"code"];
        [methodChannel invokeMethod:@"test" arguments:dic];
    }
    if (messageChannel!=nil) {
        [dic setObject:@"潘家伟" forKey:@"message"];
        [dic setObject: [NSNumber numberWithInt:110] forKey:@"code"];
        [messageChannel sendMessage:dic];
    }
}

- (void)dealloc {
    //单条移除观察者
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"REFRESH_TABLEVIEW" object:nil];
    //移除所有观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
