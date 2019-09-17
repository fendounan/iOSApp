//
//  SwitchSlideView.m
//  SwitchSlideView
//
//  Created by B.H. Liu on 12-5-14.
//  Copyright (c) 2012年 Appublisher. All rights reserved.
//

#import "SwitchSlideView.h"
#import "UIColor+StringToColor.h"

@interface SwitchSlideView()
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,readwrite) NSInteger direction; //1- right 0- left
@end

@implementation SwitchSlideView
@synthesize scrollView=_scrollView;
@synthesize pageControl=_pageControl;
@synthesize titleLabel=_titleLabel;
@synthesize currentIndex=_currentIndex,totalPages=_totalPages;
@synthesize timer=_timer;
@synthesize direction=_direction;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 10)];
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 20)];
        self.titleLabel.enabled = NO;
        
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.delegate = self;
        
        self.pageControl.userInteractionEnabled = NO;
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        [self addSubview:self.titleLabel];
        self.pageControl.hidden = YES;
        
        //开启三益宝之旅
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake([U], <#CGFloat y#>, 100, CGFloat height)
//        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
//        [self.scrollView addGestureRecognizer:tapGesture];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (BOOL)is5 {
    static int result = -3;
    if( result == -3 ) {
        result = CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size);
    }
    return result;
}
- (BOOL)is6 {
    static int result = -3;
    if( result == -3 ) {
        result = CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size);
    }
    return result;
}

- (UIImage*)getProperImage:(NSString*)path {
    UIImage *image;
    if( [self is5] ) {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-568h@2x",path]];
    }else if( [self is6] ) {
        image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-667h@2x",path]];
    }
    if( image == nil )
        image = [UIImage imageNamed:path];
    //iOS7 specific
    if( image == nil )
        image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (void)setImagesWithArray:(NSArray *)array
{
    static NSInteger prevIndex, prevDir;
    prevIndex = self.currentIndex;
    prevDir = self.direction;
    
    self.totalPages = array.count;
    self.pageControl.numberOfPages = self.totalPages;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * self.totalPages, self.scrollView.frame.size.height);
    self.currentIndex = 0;
    self.direction = 1;
    
    for (int i = 0; i<self.totalPages; i++)
    {
        id imgU = [array objectAtIndex:i];
        UIImage *img = nil;
        if( [imgU isKindOfClass:[UIImage class]] )
            img = imgU;
        if( [imgU isKindOfClass:[NSString class]] )
            img = [self getProperImage:imgU];
        if( !img )
            return;
        UIImageView *imageView = [[UIImageView alloc]initWithImage:img];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.frame = CGRectMake(self.frame.size.width*i, 0, self.frame.size.width, self.scrollView.frame.size.height);
        
        if (!self.noBtn) {
            if (i == self.totalPages-1) {
                CGFloat startButtonH = 45;
                UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [startButton setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-200)/2, self.pageControl.frame.origin.y-70, 200, startButtonH)];
                [startButton setTitle:@"立即体验" forState:UIControlStateNormal];
//                [startButton setTintColor:[UIColor whiteColor]];
                [startButton setTitleColor:[UIColor hexStringToColor:@"#fa6f57"] forState:UIControlStateNormal];
                startButton.backgroundColor = [UIColor hexStringToColor:@"#fad838"];
                startButton.layer.cornerRadius = startButtonH / 2;
                startButton.layer.borderColor = [UIColor whiteColor].CGColor;
//                startButton.layer.borderWidth = 1.0f;
                [startButton addTarget:self action:@selector(startButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                imageView.userInteractionEnabled = YES;
                [imageView addSubview:startButton];
            }

        }
        [self.scrollView addSubview:imageView];
    }
    
    self.titleLabel.text = @"";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if( !self.noTimer ) {
        if( self.timer ) {
            [self.timer invalidate];
            self.currentIndex = prevIndex;
            self.direction = prevDir;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onTimerScroll) userInfo:nil repeats:YES];
    }
}

- (void)setViewsWithArray:(NSArray *)array {
    self.totalPages = array.count;
    self.pageControl.numberOfPages = self.totalPages;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * self.totalPages, self.scrollView.frame.size.height);
    self.currentIndex = 0;
    self.direction = 1;
    
    for (int i = 0; i<self.totalPages; i++)
    {
        UIView *view = array[i];
        view.frame = CGRectMake(self.frame.origin.x+self.frame.size.width*i, self.frame.origin.y, self.frame.size.width, self.scrollView.frame.size.height);
        [self.scrollView addSubview:view];
    }
    
    self.titleLabel.text = @"";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)onTimerScroll
{
    if( self.totalPages == 1 ) return;
    CGFloat offset_x = self.scrollView.contentOffset.x;
    if(self.direction == 1)
    {
        if (offset_x <= self.scrollView.contentSize.width - 2*self.scrollView.frame.size.width) 
        {
            offset_x = ( self.currentIndex + 1 ) * self.scrollView.frame.size.width;
            [self.scrollView setContentOffset:CGPointMake(offset_x, 0) animated:YES];
        }
        else if(self.currentIndex == self.totalPages -1)
        {
            self.direction = 0;
            offset_x = ( self.currentIndex - 1 ) * self.scrollView.frame.size.width;
            [self.scrollView setContentOffset:CGPointMake(offset_x, 0) animated:YES];
        }  
    }
    else 
    {
        if (offset_x >= self.scrollView.frame.size.width) 
        {
            offset_x = ( self.currentIndex - 1 ) * self.scrollView.frame.size.width;
            [self.scrollView setContentOffset:CGPointMake(offset_x, 0) animated:YES];
        }
        else if(self.currentIndex == 0)
        {
            self.direction = 1;
            offset_x = ( self.currentIndex + 1 ) * self.scrollView.frame.size.width;
            [self.scrollView setContentOffset:CGPointMake(offset_x, 0) animated:YES];
        } 
    }
    
}

#pragma mark-
#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    int pageNum = round( scrollView.contentOffset.x / scrollView.frame.size.width);
    self.currentIndex = pageNum;
    self.pageControl.currentPage = pageNum;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if( !self.noTimer ) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if( !self.noTimer ) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(onTimerScroll) userInfo:nil repeats:YES];
    }
}


- (void) tapped:(UITapGestureRecognizer*)tapRecognizer 
{
    [self.delegate tapOn:self.currentIndex];
}

- (void)startButtonAction:(UIButton *)sender{
   [self.delegate tapOn:self.currentIndex];
}

@end
