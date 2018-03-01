//
//  FSCalendarStaticHeader.m
//  FSCalendar
//
//  Created by dingwenchao on 9/17/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import "FSCalendarStickyHeader.h"
#import "FSCalendar.h"
#import "FSCalendarWeekdayView.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarConstants.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarStickyHeader ()

@property (weak  , nonatomic) UIView  *contentView;
@property (weak  , nonatomic) UIView  *bottomBorder;
@property (weak  , nonatomic) FSCalendarWeekdayView *weekdayView;
@property (assign, nonatomic) UIEdgeInsets textInsets;
@property (assign, nonatomic) CGFloat separatorOffset;

@end

@implementation FSCalendarStickyHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *view;
        UILabel *label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor clearColor];
        [self addSubview:view];
        self.contentView = view;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [_contentView addSubview:label];
        self.titleLabel = label;
        
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        [_contentView addSubview:label];
        self.additionalInfoLabel = label;
        
        view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = FSCalendarStandardLineColor;
        [_contentView addSubview:view];
        self.bottomBorder = view;
        
        FSCalendarWeekdayView *weekdayView = [[FSCalendarWeekdayView alloc] init];
        [self.contentView addSubview:weekdayView];
        self.weekdayView = weekdayView;
        
        self.textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
    
    CGFloat weekdayHeight = _calendar.preferredWeekdayHeight;
    CGFloat weekdayMargin = weekdayHeight * 0.1;
    
    self.weekdayView.frame = CGRectMake(0, _contentView.fs_height-weekdayHeight-weekdayMargin, self.contentView.fs_width, weekdayHeight);
    
    _bottomBorder.frame = CGRectMake(0, _contentView.fs_height-weekdayHeight-weekdayMargin*2, _contentView.fs_width, 1.0);
    
    [self setupLabels];
}

- (void)setupLabels 
{
    CGFloat weekdayHeight = _calendar.preferredWeekdayHeight;
    UILabel * title = self.titleLabel;
    UILabel * additional = self.additionalInfoLabel;
    
    [title removeFromSuperview];
    [additional removeFromSuperview];
    
    [title setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [title setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    [additional setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [additional setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [title setTranslatesAutoresizingMaskIntoConstraints:NO];
    [additional setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_contentView addSubview:title];
    [_contentView addSubview:additional];
    
    NSDictionary * views = @{@"title" : _titleLabel, @"additional" : _additionalInfoLabel};
    NSDictionary * metrics = @{@"top" : @(_textInsets.top),
                               @"bottom" : @(_textInsets.bottom + weekdayHeight),
                               @"left" : @(_textInsets.left),
                               @"right" : @(_textInsets.right),
                               @"separator" : @(_separatorOffset)
                               };
    
    NSArray *horizontalConstraints = [NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-(left)-[title]-(separator)-[additional]-(right)-|"
                                      options:0
                                      metrics:metrics
                                      views:views];
    NSArray *verticalTitleConstraints = [NSLayoutConstraint
                                         constraintsWithVisualFormat:@"V:|-(top)-[title]-(bottom)-|"
                                         options:0
                                         metrics:metrics
                                         views:views];
    NSArray *verticalAdditionalConstraints = [NSLayoutConstraint
                                              constraintsWithVisualFormat:@"V:|-(top)-[additional]-(bottom)-|"
                                              options:0
                                              metrics:metrics
                                              views:views];
    
    [_contentView addConstraints:horizontalConstraints];
    [_contentView addConstraints:verticalTitleConstraints];
    [_contentView addConstraints:verticalAdditionalConstraints];
}

- (void)layoutLabels {
    
}

#pragma mark - Properties

- (void)setCalendar:(FSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _weekdayView.calendar = calendar;
        [self configureAppearance];
    }
}

#pragma mark - Private methods

- (void)configureAppearance
{
    _titleLabel.font = self.calendar.appearance.headerTitleFont;
    _titleLabel.textColor = self.calendar.appearance.headerTitleColor;
    _titleLabel.textAlignment = _calendar.appearance.headerTitleTextAlignment;
    _additionalInfoLabel.font = _calendar.appearance.headerAdditionalInfoFont;
    _additionalInfoLabel.textColor = _calendar.appearance.headerAdditionalInfoColor;
    _additionalInfoLabel.textAlignment = _calendar.appearance.headerAdditionalInfoTextAlignment;
    _bottomBorder.backgroundColor = _calendar.appearance.bottomBorderLineColor;
    _contentView.backgroundColor = _calendar.appearance.headerBackgroundColor;
    _textInsets = _calendar.appearance.headerTextInsets;
    _separatorOffset = _calendar.appearance.headerTextSeparatorOffset;

    [self.weekdayView configureAppearance];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setMonth:(NSDate *)month
{
    _month = month;
    _calendar.formatter.dateFormat = self.calendar.appearance.headerDateFormat;

    NSInteger monthNumber = [_calendar.formatter.calendar component:NSCalendarUnitMonth fromDate:month];
    _calendar.formatter.formattingContext = NSFormattingContextBeginningOfSentence;
    NSString *text = _calendar.formatter.standaloneMonthSymbols[monthNumber-1];

    BOOL usesUpperCase = (self.calendar.appearance.caseOptions & 15) == FSCalendarCaseOptionsHeaderUsesUpperCase;
    text = usesUpperCase ? text.uppercaseString : text;
    self.titleLabel.text = text;
}

- (void)setAdditionalInfo:(NSString *)info {
    _additionalInfo = info;
    self.additionalInfoLabel.text = info;
}

@end


