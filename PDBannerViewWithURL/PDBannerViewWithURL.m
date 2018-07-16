//
//  BannerView.m
//  轮播图(循环和自动)
//
//  Created by 裴铎 on 2018/3/9.
//  Copyright © 2018年 裴铎. All rights reserved.
//

#import "PDBannerViewWithURL.h"
/************************ 第三方 ****************************/
#import "UIImageView+WebCache.h"

/**
 定时器 用来自动播放图片
 */
static NSTimer * mv_timer;

/**
 定义私有变量
 遵守滚动式图的代理方法 实现拖拽效果
 */
@interface PDBannerViewWithURL () <
//滚动视图的道理协议
UIScrollViewDelegate>{
    
    //banNerView的宽和高 私有成员变量用下划线开头(书写习惯)
    CGFloat mv_width;
    CGFloat mv_height;
}

/**
 分页控件
 */
@property (nonatomic , strong) UIPageControl * mainPage;

/**
 scrollView
 */
@property (nonatomic , strong) UIScrollView * mainScrollView;

/**
 图片数组
 */
@property (nonatomic , strong) NSMutableArray * dataArray;

/** 占位提示图片 */
@property (nonatomic, copy) NSString * placeholderImage;


@end

@implementation PDBannerViewWithURL

//- (instancetype)initWithFrame:(CGRect)frame{
//
//    self = [super initWithFrame:frame];
//
//    if (self) {
//
//       //系统的初始化方法
//    }
//
//    return self;
//}


/**
 2./自定义的init构造方法 在.h文件提前声明

 @param frame 外界初始化时传入的frame 带有bannerView的宽和高
 @param addImageURLArray 传入的图片数组
 @return 1
 */
- (id)initWithFrame:(CGRect)frame andImageURLArray:(NSMutableArray *)addImageURLArray andplaceholderImage:(NSString *)placeholderImage{
    
    //调用父类方法
    self = [super initWithFrame:frame];
    
    //判断是否是本类对象调用 并 外界传入的图片数量足够滚动
    if (self && addImageURLArray.count > 2) {
        
        /**
         获取banNerView 的宽度
         宽和高是外界传入的 frame (只能在这个方法内有效)
         所以需要定义一个本类都能使用的成员变量
         */
        mv_width = frame.size.width;
        
        //或取bannerView 的高度
        mv_height = frame.size.height;
        
        self.placeholderImage = placeholderImage;
        
        //图片数组 1 2 3 4 5 6 把外界传入的图片数组赋值给本类的数组
        self.dataArray = [NSMutableArray arrayWithArray:addImageURLArray];
        
        //在数组的最后一位添加传进来的第一张图片 1 2 3 4 5 6 1
        [self.dataArray addObject:addImageURLArray.firstObject];
        
        /**
         在数组的第一位添加传进来的最后一张图片 6 1 2 3 4 5 6 1
         insert 插入元素  atIndex: 根据下标
         */
        [self.dataArray insertObject:addImageURLArray.lastObject atIndex:0];
        
        //初始化时把mainscrollView 加载到banNerView上
        [self addSubview:self.mainScrollView];
        
        //初始化时把分页控件加载到bannerView中
        [self addSubview:self.mainPage];
        
        //初始化时加载定时器
        [self addTimer];
    }
    
    /**
     返回本类
     当外界用本类的初始化方法时
     返回一个视图 bannerView 给外界
     */
    return self;
}

/**
 滚动视图开始手动拖拽时出发
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    //判断是否有定时器
    if (mv_timer) {
        
        //如果有定时器就暂停定时器(两种方法实现暂停效果)
        
        /**
         NSTimer 自带的方法中没有暂停和继续定时器的方法
         但是有一个setFireDate:方法 (定时器的触发时间)
         原理是把定时器的触发时间设置成很久的将来
         这样定时器就会进入等待触发的状态 (实现暂停效果)
         distantFuture(遥远的未来)
         */
        [mv_timer setFireDate:[NSDate distantFuture]];
        
        /**
         用NSTimer自带的停止定时器的方法 invalidate
         这个方法会吧定时器永久停止,无法再次启用
         所以需要把定时器清空 nil
         当需要再次开启定时器时 重新初始化定时器
         [self.timer invalidate];
         self.timer = nil;
         */
    }
}

/**
 滚动视图正在滚动 (拖拽过程中触发的方法)
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    self.mainPage.currentPage = scrollView.contentOffset.x / mv_width - 1;
}

/**
 滚动视图完成减速时调用 (就是手动拖拽完成后)
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //判断是否有定时器
    if (mv_timer) {
        
        /**
         设置定时器的触发时间
         延后2秒触发
         */
        [mv_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
        
        /**
         重新初始化定时器
         self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFUNC:) userInfo:nil repeats:YES];
         */
    }
    
    //获取当前滚动视图的偏移量
    CGPoint currentPoint = scrollView.contentOffset;
    
    /** 判断拖拽完成后将要显示的图片时第几张 6 1 2 3 4 5 6 1 */
    //如果是数组内的最后一张图片 1
    if (currentPoint.x == (self.dataArray.count - 1) * mv_width) {
        
        //改变偏移量 显示数组内的第一张图片 1
        scrollView.contentOffset = CGPointMake(mv_width, 0);
    }
    
    //如果是数组内的第一张图片 6
    if (currentPoint.x == 0) {
        
        //改变偏移量 显示数组内的 第二个图片6
        scrollView.contentOffset = CGPointMake((self.dataArray.count - 2) * mv_width, 0);
    }
    
    /**
     如果是图片数组的第一张图片 或 最后一张图片时
     滚动视图的偏移量发生了改变
     所以之前的偏移量变量不能再使用了 (获取一个新的偏移量)
     */
    //获取新的滚佛那个视图偏移量
    CGPoint newPoint = scrollView.contentOffset;
    
    //改变分页控件上的页码
    self.mainPage.currentPage = newPoint.x / mv_width - 1;
}

/**
 5./初始化定时器
 */
- (void)addTimer{
    
    //初始化定时器 时间戳:2.0秒 目标:本类 方法选择器:timerFUNC 用户信息:nil 是否循环:yes
    mv_timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFUNC:) userInfo:nil repeats:YES];
    
    /**
     将定时器添加到当前线程中(currentRunLoop 当前线程)
     [NSRunLoop currentRunLoop]可以的到一个当前线程下的NSRunLoop对象
     addTimer:添加一个定时器
     forMode:什么模式
     NSRunLoopCommonModes 共同模式
     */
    [[NSRunLoop currentRunLoop] addTimer:mv_timer forMode:NSRunLoopCommonModes];
    /**
     在开启一个NSTimer实质上是在当前的runloop中注册了一个新的事件源，
     而当scrollView滚动的时候，当前的MainRunLoop是处于UITrackingRunLoopMode的模式下，
     在这个模式下，是不会处理NSDefaultRunLoopMode的消息(因为RunLoop 的 Mode不一样)，
     要想在scrollView滚动的同时也接受其它runloop的消息，我们需要改变两者之间的runLoopMode.
     简单的说就是NSTimer不会开启新的进程，只是在RunLoop里注册了一下，
     RunLoop每次loop时都会检测这个timer，看是否可以触发。
     当Runloop在A mode，而timer注册在B mode时就无法去检测这个timer，
     所以需要把NSTimer也注册到A mode，这样就可以被检测到。
     所以模式参数 forMode: 填写 NSRunLoopCommonModes 共同模式
     */
}

/**
 6./实现定时器方法
 */
- (void)timerFUNC:(NSTimer *)timer{
    
    /**
     获取当前图片的X位置
     也就是定时器再次出发时滚动视图上正在显示的是哪一张图片
     */
    CGFloat currentX = self.mainScrollView.contentOffset.x;
    
    /**
     获取下一张图片的X位置
     当前位置 + 一个屏幕宽度
     */
    CGFloat nextX = currentX + mv_width;
    
    /**
     判断滚动视图上将要显示的图片是最后一张时
     通过X值来判断 所以要 self.dataArray.count - 1
     */
    if (nextX == (self.dataArray.count - 1) * mv_width) {
        
        /**
         UIView的动画效果方法(分两个方法)
         */
        [UIView animateWithDuration:0.2 animations:^{
            /**
             动画效果的第一个方法
             Duration:持续时间
             animations:动画内容
             这个动画执行 0.2秒 后进入下一个方法
             */
            
            //往最后一张图片走
            self.mainScrollView.contentOffset = CGPointMake(nextX, 0);
            
            /**
             改变对应的分页控件显示圆点
             */
            self.mainPage.currentPage = 0;
        } completion:^(BOOL finished) {
            /**
             动画效果的第二个方法
             completion: 回调方法 (完成\结束的意思)
             上一个方法结束后进入这个方法
             */
            
            //往第二张图片走
            self.mainScrollView.contentOffset = CGPointMake(self->mv_width, 0);
        }];
    }else{//如果滚动视图上要显示的图片不是最后一张时
        
        //显示下一张图片
        [UIView animateWithDuration:0.2 animations:^{
            
            //让下一个图片显示出来
            self.mainScrollView.contentOffset = CGPointMake( nextX, 0);
            
            //改变对应的分页控件显示圆点
            self.mainPage.currentPage = self.mainScrollView.contentOffset.x / self->mv_width - 1;
        } completion:^(BOOL finished) {
            
            //改变对应的分页控件显示圆点
            self.mainPage.currentPage = self.mainScrollView.contentOffset.x / self->mv_width - 1;
        }];
    }
}

/**
 4./加载分页控件
 */
- (UIPageControl *)mainPage{
    
    if (!_mainPage) {
        
        //初始化分页控制器
        _mainPage = [[UIPageControl alloc]initWithFrame:CGRectMake( 50, mv_height - 20, mv_width - 50 * 2, 20)];
        
        //分页控件上要显示的圆点数量
        _mainPage.numberOfPages = self.dataArray.count - 2;
        //分页控件不允许和用户交互(不许点击)
        _mainPage.userInteractionEnabled = NO;
        
        //设置 默认点 的颜色
        _mainPage.pageIndicatorTintColor = [UIColor whiteColor];
        
        //设置 滑动点(当前点) 的颜色
        _mainPage.currentPageIndicatorTintColor = [UIColor blackColor ];
    }
    
    return _mainPage;
}

/**
 3./加载滚动视图
 */
- (UIScrollView *)mainScrollView{
    
    if (!_mainScrollView) {
        
        //初始化滚动控件
        _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mv_width, mv_height)];
        
        //滚动式图的代理
        _mainScrollView.delegate = self;
        
        /**
         滚动范围(手动拖拽时的范围)
         如果不写就不能手动拖拽(但是定时器可以让图片滚动)
         */
        _mainScrollView.contentSize = CGSizeMake(self.dataArray.count * mv_width, mv_height);
        
        //分页滚动效果 yes
        _mainScrollView.pagingEnabled = YES;
        
        //能否滚动
        _mainScrollView.scrollEnabled = YES;
        
        //弹簧效果 NO
        _mainScrollView.bounces = NO;
        
        //滚动视图的起始偏移量
        _mainScrollView.contentOffset = CGPointMake(mv_width, 0);
        
        //垂直滚动条
        _mainScrollView.showsVerticalScrollIndicator = NO;
        
        //水平滚动条
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        
        /**
         循环往滚动视图上添加图片视图
         循环条件 i < self.dataArray.count 一定不要写等号 =
         如果 i <= self.dataArray.count 程序就会崩溃,(下标越界)
         */
        for (NSInteger i = 0; i < self.dataArray.count; i ++) {
            
            //初始化图片视图
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(mv_width * i, 0, mv_width, mv_height)];
            
            //给图片视图添加图片 通过图片数组
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.dataArray[i]] placeholderImage:[UIImage imageNamed:self.placeholderImage]];
            
            //让图片可以与用户交互
            imageView.userInteractionEnabled = YES;
            
            //初始化一个点击手势
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAcyion:)];
            
            //把点击手势添加到图片上
            [imageView addGestureRecognizer:tap];
            
            //把图片视图 添加 到滚动视图上
            [_mainScrollView addSubview:imageView];
        }
    }
    
    //返回滚动视图 给 bannerView
    return _mainScrollView;
}
/**
 点击图片触发的手势方法
 */
- (void)tapAcyion:(UITapGestureRecognizer *)tap{
    
    /**
     如果代理属性能够响应协议方法方法
     才会通过代理属性 调用协议方法
     */
    if ([self.delegate respondsToSelector:@selector(selectImage:currentImage:)]) {
        
        /**
         通过代理属性 调用协议方法
         currentImage:当前的图片时第几张
         可以通过分页控件的当前圆点来判断是第几张图片
         */
        [self.delegate selectImage:self currentImage:self.mainPage.currentPage];
    }
}

+ (void)destroyTimer{
    //  清理定时器
    [mv_timer invalidate];
    mv_timer = nil;
}



@end
