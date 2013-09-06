//
//  ViewController.m
//  MHValidationViewController
//
//  Created by Mario Hahn on 15.05.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "UIView+MHValidation.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")



NSString * const SHAKE_OBJECTS_IDENTIFIER = @"SHAKE_OBJECTS_IDENTIFIER";
NSString * const CLASS_OBJECTS_IDENTIFIER = @"CLASS_OBJECTS_IDENTIFIER";
NSString * const ENABLE_NEXTPREV_IDENTIFIER = @"ENABLE_NEXTPREV_IDENTIFIER";
NSString * const CUSTOMIZATION_IDENTIFIER = @"CUSTOMIZATION_IDENTIFIER";



@implementation MHTextView

-(id)initWithFrame:(CGRect)frame
     customization:(MHTextObjectsCustomization*)customization
             style:(MHTextObjectsCustomizationStyle)style{
    
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    self.style = style;
    self.customization = customization;
    self.backgroundColor = [UIColor clearColor];
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    
    MHCustomizationDetail *customization = [MHCustomizationDetail new];
    switch (self.style) {
        case MHTextObjectsCustomizationStyleDefault:
            customization = self.customization.defaultCustomization;
            break;
        case MHTextObjectsCustomizationStyleSelected:
            customization = self.customization.selectedCustomization;
            break;
        case MHTextObjectsCustomizationStyleNonValidate:
            customization = self.customization.nonValidCustomization;
            break;
            
        default:
            break;
    }
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor* gradientColorUp = customization.borderGradientColorUp;
    UIColor* gradientColorDown = customization.borderGradientColorDow;
    UIColor* backgroundColor = customization.backgroundColor;
    UIColor* shadow = customization.innerShadowColor;
    
    NSArray* gradientColorsForBorder = [NSArray arrayWithObjects:
                                (id)gradientColorUp.CGColor,
                                (id)gradientColorDown.CGColor, nil];
    CGFloat gradientColorsForBorderLocations[] = {0, 1};
    CGGradientRef borderGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColorsForBorder, gradientColorsForBorderLocations);

    
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 2.5;

    
    UIBezierPath* borderGradientPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1, 1, rect.size.width-2, rect.size.height-2) cornerRadius: customization.cornerRadius];
    CGContextSaveGState(context);
    [borderGradientPath addClip];
    CGContextDrawLinearGradient(context, borderGradient, CGPointMake(((rect.size.width-2)/2)+1, 1), CGPointMake(((rect.size.width-2)/2)+1, 1+rect.size.height-2), 0);
    CGContextRestoreGState(context);
    
        
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1+customization.borderWidth, 1+customization.borderWidth, rect.size.width-((1+customization.borderWidth)*2), rect.size.height-((1+customization.borderWidth)*2)) cornerRadius: customization.cornerRadius];
    [backgroundColor setFill];
    [rectangle2Path fill];
    
    CGRect rectangle2BorderRect = CGRectInset([rectangle2Path bounds], -shadowBlurRadius, -shadowBlurRadius);
    rectangle2BorderRect = CGRectOffset(rectangle2BorderRect, -shadowOffset.width, -shadowOffset.height);
    rectangle2BorderRect = CGRectInset(CGRectUnion(rectangle2BorderRect, [rectangle2Path bounds]), -1, -1);
    
    UIBezierPath* rectangle2NegativePath = [UIBezierPath bezierPathWithRect: rectangle2BorderRect];
    [rectangle2NegativePath appendPath: rectangle2Path];
    rectangle2NegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadowOffset.width + round(rectangle2BorderRect.size.width);
        CGFloat yOffset = shadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadowBlurRadius,
                                    shadow.CGColor);
        
        [rectangle2Path addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(rectangle2BorderRect.size.width), 0);
        [rectangle2NegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [rectangle2NegativePath fill];
    }
    CGContextRestoreGState(context);

    CGGradientRelease(borderGradient);
    CGColorSpaceRelease(colorSpace);
    
}

@end


@implementation MHTextObjectsCustomization

- (id)initWithClassesForCustomization:(NSArray*)classesToCustomize
                 defaultCustomization:(MHCustomizationDetail*)defaultCustomization
                selectedCustomization:(MHCustomizationDetail*)selectedCustomization
                nonValidCustomization:(MHCustomizationDetail*)nonValidCustomization
                    animationDuration:(float)animationDuration{
    self = [super init];
    if (!self)
        return nil;
    self.animationDuration = animationDuration;
    self.classesToCustomize = classesToCustomize;
    self.defaultCustomization = defaultCustomization;
    self.selectedCustomization = selectedCustomization;
    self.nonValidCustomization = nonValidCustomization;
    return self;

}



@end


@implementation MHCustomizationDetail

- (id)initWithBackgroundColor:(UIColor*)backgroundColor
        borderGradientColorUp:(UIColor*)borderGradientColorUp
       borderGradientColorDow:(UIColor*)borderGradientColorDow
                  borderWidth:(float)borderWidth
                 cornerRadius:(float)cornerRadius
             innerShadowColor:(UIColor*)innerShadowColor
                   labelColor:(UIColor*)labelColor
                    labelFont:(UIFont*)labelFont;
{
    self = [super init];
    if (!self)
        return nil;
    self.backgroundColor = backgroundColor;
    self.borderGradientColorDow = borderGradientColorDow;
    self.borderGradientColorUp = borderGradientColorUp;
    self.borderWidth = borderWidth;
    self.cornerRadius = cornerRadius;
    self.innerShadowColor = innerShadowColor;
    self.labelColor = labelColor;
    self.labelFont = labelFont;
    return self;
}


@end


@implementation MHValidationItem

-(id)initWithObject:(id)object regexString:(NSString *)regexString{
    self = [super init];
    if (!self)
        return nil;
    self.object = object;
    self.regexString = regexString;
    return self;
}
@end



@implementation UIView (MHValidation)
@dynamic classObjects;
@dynamic showNextAndPrevSegmentedControl;
@dynamic shouldShakeNonValidateObjects;
@dynamic textObjectsCustomization;



//SHAKE OBEJCTS
-(void)setShouldShakeNonValidateObjects:(BOOL)shouldShakeNonValidateObjects{
    objc_setAssociatedObject(self, &SHAKE_OBJECTS_IDENTIFIER, [NSNumber numberWithBool:shouldShakeNonValidateObjects], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)shouldShakeNonValidateObjects{
    return [objc_getAssociatedObject(self, &SHAKE_OBJECTS_IDENTIFIER) boolValue];
}

//CUSTOMIZATION
-(void)setTextObjectsCustomization:(MHTextObjectsCustomization *)textObjectsCustomization{
    objc_setAssociatedObject(self, &CUSTOMIZATION_IDENTIFIER, textObjectsCustomization, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(MHTextObjectsCustomization*)textObjectsCustomization{
    return objc_getAssociatedObject(self, &CUSTOMIZATION_IDENTIFIER);
}


//ENABLE NEXT PREV
-(void)setShowNextAndPrevSegmentedControl:(BOOL)showNextAndPrevSegmentedControl{
    objc_setAssociatedObject(self, &ENABLE_NEXTPREV_IDENTIFIER, [NSNumber numberWithBool:showNextAndPrevSegmentedControl], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)showNextAndPrevSegmentedControl{
    return [objc_getAssociatedObject(self, &ENABLE_NEXTPREV_IDENTIFIER) boolValue];
}

//CLASS OBEJCTS
-(void)setClassObjects:(NSArray *)classObjects{
    objc_setAssociatedObject(self, &CLASS_OBJECTS_IDENTIFIER, classObjects, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSArray*)classObjects{
    return objc_getAssociatedObject(self, &CLASS_OBJECTS_IDENTIFIER);
}


- (CGRect)determineFrameForObject:(id)obj {
    UIView *view = (UIView*)obj;
    while (![[view superview] isEqual:self]) {
            view = [view superview];
        }
    CGRect frame = [view convertRect:[view frame] toView:self];
    return frame;
}


-(void)searchForObjectsOfClass:(NSArray*)classes
        selectNextOrPrevObject:(MHSelectionType)selectionType
              foundObjectBlock:(void(^)(id object,
                                        MHSelectedObjectType objectType )
                                )FoundObjectBlock{
    
    
    id selectedObject = [self findFirstResponderOnView:self];
    NSMutableArray *classesOnlyText = [NSMutableArray new];
    for (id classFromClasses in classes) {
        if ([[classFromClasses class] isEqual:[UITextView class]]||[[classFromClasses class] isEqual:[UITextField class]]) {
            [classesOnlyText addObject:classFromClasses];
        }
    }
    NSArray *allObjectsWhichAreKindOfClasses = [self findObjectsofClass:classesOnlyText
                                                                 onView:self
                                               showOnlyNonHiddenObjects:YES
                                                                 fields:nil];
    if (allObjectsWhichAreKindOfClasses.count<=1) {
        [self hideSegment:YES];
    }else{
        [self hideSegment:NO];
    }
    
    NSComparator comparatorBlock = ^(id obj1, id obj2) {
        
        CGRect obj1Frame = [self determineFrameForObject:obj1];
        CGRect obj2Frame = [self determineFrameForObject:obj2];

        if (obj1Frame.origin.y > obj2Frame.origin.y) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (obj1Frame.origin.y < obj2Frame.origin.y) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    id objectWhichShouldBecomeFirstResponder= nil;
    NSMutableArray *fieldsSort = [[NSMutableArray alloc]initWithArray:allObjectsWhichAreKindOfClasses];
    [fieldsSort sortUsingComparator:comparatorBlock];
    
    CGRect frameSelectedObject = [self determineFrameForObject:selectedObject];

    for (id viewsAndFields in fieldsSort) {
        
        CGRect frameViewOrField = [self determineFrameForObject:viewsAndFields];
        if ((frameViewOrField.origin.y == frameSelectedObject.origin.y)&&(frameViewOrField.origin.x > frameSelectedObject.origin.x) ) {
            objectWhichShouldBecomeFirstResponder = viewsAndFields;
            break;
        }
        if ((frameViewOrField.origin.y > frameSelectedObject.origin.y) ) {
            objectWhichShouldBecomeFirstResponder = viewsAndFields;
            break;
        }
    }
    if (selectionType == MHSelectionTypeNext ) {
        if (objectWhichShouldBecomeFirstResponder) {
            int index = [fieldsSort indexOfObject:objectWhichShouldBecomeFirstResponder];
            if (index == fieldsSort.count-1) {
                FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeLast);
                [self disableSegment:MHSelectionTypeNext];
            }else{
                FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeMiddle);
            }
            return;
        }
    }else if(selectionType == MHSelectionTypePrev){
        int index = [fieldsSort indexOfObject:objectWhichShouldBecomeFirstResponder];
        if (index ==1) {
            FoundObjectBlock(nil,MHSelectedObjectTypeFirst);
            return;
        }
        
        if (!objectWhichShouldBecomeFirstResponder) {
            int index = [fieldsSort indexOfObject:[self findFirstResponderOnView:self]];
            objectWhichShouldBecomeFirstResponder = [fieldsSort objectAtIndex:index-1];
            FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeMiddle);
            return;
        }
        
        if (index>=2) {
            objectWhichShouldBecomeFirstResponder = [fieldsSort objectAtIndex:index-2];
            if (index == NSNotFound && [selectedObject isFirstResponder ]) {
                FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeFirst);
            }else{
                int firstresponderIndex = [fieldsSort indexOfObject:objectWhichShouldBecomeFirstResponder];
                if (firstresponderIndex ==0) {
                    FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeFirst);
                    [self disableSegment:MHSelectionTypePrev];
                }else{
                    FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeMiddle);
                }
            }
        }else{
            FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeFirst);
            
        }
    }else{
        if ([fieldsSort indexOfObject:[self findFirstResponderOnView:self]]==0) {
            FoundObjectBlock([self findFirstResponderOnView:self],MHSelectedObjectTypeFirst);
        }else if ([fieldsSort indexOfObject:[self findFirstResponderOnView:self]]==fieldsSort.count-1) {
            FoundObjectBlock([self findFirstResponderOnView:self],MHSelectedObjectTypeLast);
        }else{
            FoundObjectBlock([self findFirstResponderOnView:self],MHSelectedObjectTypeMiddle);
        }
    }
    if ([selectedObject isFirstResponder] && selectionType == MHSelectionTypeNext) {
        FoundObjectBlock(nil,MHSelectedObjectTypeLast);
    }
}
-(void)hideSegment:(BOOL)hide{
    id firstresponder = [self findFirstResponderOnView:self];
    for (id object in [[firstresponder inputAccessoryView] subviews]) {
        if ([object isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segm = object;
            [segm setHidden:hide];
        }
    }
    
}
-(void)disableSegment:(MHSelectionType)mhselectionType{
    id firstresponder = [self findFirstResponderOnView:self];
    for (id object in [[firstresponder inputAccessoryView] subviews]) {
        if ([object isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segm = object;
            if (mhselectionType == MHSelectionTypePrev) {
                [segm setEnabled:NO forSegmentAtIndex:0];
            }else{
                [segm setEnabled:NO forSegmentAtIndex:1];
            }
        }
    }
}
-(void)dismissInputView{
    if ([self isKindOfClass:[UIScrollView class]]) {
        UIScrollView *sv = (UIScrollView*)self;
        [UIView animateWithDuration:0.3 animations:^{
            [sv setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [sv setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

        }];
        }

    [self setCustomization:self.textObjectsCustomization
                forObjects:@[[self findFirstResponderOnView:self]]
                 withStyle:MHTextObjectsCustomizationStyleDefault];
    
    [self endEditing:YES];
}


-(void)keyboardWillShow:(NSNotification*)not{

    
    if (![not userInfo]) {
        
        if (self.showNextAndPrevSegmentedControl) {
            [self setCustomization:self.textObjectsCustomization
                        forObjects:@[[self findFirstResponderOnView:self] ]
                         withStyle:MHTextObjectsCustomizationStyleSelected];
            id firstResponder = [self findFirstResponderOnView:self];
            if (![firstResponder inputAccessoryView]) {
                [firstResponder becomeFirstResponder];

                UIToolbar *toolBar = [self toolbarInit];
                [toolBar sizeToFit];
                [firstResponder setInputAccessoryView:toolBar];
                if ([firstResponder isKindOfClass:[UITextView class]]) {
                    [self endEditing:YES];
                }
            }
            [self searchForObjectsOfClass:self.classObjects
                   selectNextOrPrevObject:MHSelectionTypeCurrent
                         foundObjectBlock:^(id object,
                                            MHSelectedObjectType objectType
                                            ) {
                             
                             if (objectType == MHSelectedObjectTypeFirst) {
                                 [self disableSegment:MHSelectionTypePrev];
                             }else if(objectType == MHSelectedObjectTypeLast){
                                 [self disableSegment:MHSelectionTypeNext];
                             }
                         }];
            
        }
    }else{
        if ([self isKindOfClass:[UIScrollView class]]) {
            CGRect keyborad = [[[not userInfo]objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
            [self adjustContentOffsetWithKeyBoardHeight:keyborad.size.height];
            
            UIScrollView *sv = (UIScrollView*)self;
            [self MHAutoContentSizeForScrollView];
            [sv setContentInset:UIEdgeInsetsMake(0, 0, keyborad.size.height, 0)];
            [sv setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, keyborad.size.height, 0)];
        }
    }
}




-(void)adjustContentOffsetWithKeyBoardHeight:(float)keyBoardHeight{
    UIScrollView *scroll = (UIScrollView*)self;
    
    id firstResponder = [self findFirstResponderOnView:self];
    
        if ((([firstResponder frame].origin.y+ [firstResponder frame].size.height)- self.bounds.size.height+keyBoardHeight+5)<0) {
            [scroll setContentOffset:CGPointMake(0,0) animated:YES];

        }else{
        
            [scroll setContentOffset:CGPointMake(0,([firstResponder frame].origin.y+ [firstResponder frame].size.height)- self.frame.size.height+keyBoardHeight+5) animated:YES];
        }    
}

- (UIImage *)imageByRenderingView:(id)view{
    CGFloat scale = 1.0;
    if([[UIScreen mainScreen]respondsToSelector:@selector(scale)]) {
        CGFloat tmp = [[UIScreen mainScreen]scale];
        if (tmp > 1.5) {
            scale = 2.0;
        }
    }
    if(scale > 1.5) {
        UIGraphicsBeginImageContextWithOptions([view bounds].size, NO, scale);
    } else {
        UIGraphicsBeginImageContext([view bounds].size);
    }
    
    
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}





-(void)setCustomization:(MHTextObjectsCustomization*)customization
             forObjects:(NSArray*)customizationObjects
              withStyle:(MHTextObjectsCustomizationStyle)typeStyle{
    
    if (customization) {
        for (id object in customizationObjects) {
           
            
            MHTextView *txtView = [[MHTextView alloc]initWithFrame:[object frame]
                                                     customization:customization
                                                             style:typeStyle];
            
            if ([object isKindOfClass:[UITextField class]]) {
                NSLog(@"%@",[object subviews]);
                NSLog(@"%@",[[object layer] sublayers]);
                [object setBorderStyle:UITextBorderStyleNone];
                if (![(UITextField*)object background]) {
                    [object setBackground:[self imageByRenderingView:txtView]];
                }else{
                    CATransition *animation = [CATransition animation];
                    animation.duration = customization.animationDuration;
                    animation.type = kCATransitionFade;
                    [[object layer] addAnimation:animation forKey:@"imageFade"];
                    [object setBackground:[self imageByRenderingView:txtView]];
                }

                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
                [object setLeftView:paddingView];
                [object setLeftViewMode:UITextFieldViewModeAlways];
                [object setRightView:paddingView];
                [object setRightViewMode:UITextFieldViewModeAlways];
                [object setBorderStyle:UITextBorderStyleNone];
            }else{
                
                for (id view in  [(UIScrollView*)self subviews]) {
                    if ([view isKindOfClass:[MHTextView class]]) {
                        if ([[view accessibilityIdentifier]isEqualToString:[object accessibilityIdentifier]]) {
                            [view removeFromSuperview];
                        }
                    }
                }
                
                
                [txtView setAccessibilityIdentifier:[object accessibilityIdentifier]];
                [self addSubview:txtView];
                [self bringSubviewToFront:object];
                [object setBackgroundColor:[UIColor clearColor]];
            }
            
            MHCustomizationDetail *detail = [MHCustomizationDetail new];
            switch (typeStyle) {
                case MHTextObjectsCustomizationStyleDefault:
                    detail = customization.defaultCustomization;
                    break;
                case MHTextObjectsCustomizationStyleSelected:
                    detail = customization.selectedCustomization;
                    break;
                case MHTextObjectsCustomizationStyleNonValidate:
                    detail = customization.defaultCustomization;
                    break;
                default:
                    break;
            }
            [object setFont:detail.labelFont];
            [object setTextColor:detail.labelColor];
        }
    }
}

-(void)keyboardWillHide:(id)sender{
    if ([sender object]) {
        if ([[sender object]isKindOfClass:[UITextView class]] ||[[sender object]isKindOfClass:[UITextField class]]) {
            [self setCustomization:self.textObjectsCustomization
                        forObjects:@[[sender object]]
                         withStyle:MHTextObjectsCustomizationStyleDefault];

        }
    }
}

-(void)installMHValidationWithClasses:(NSArray*)typeOfClasses
                setCustomizationBlock:(void(^)(MHTextObjectsCustomization *customization))CustomizationBlock{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UITextViewTextDidBeginEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];

    if (CustomizationBlock) {
        self.textObjectsCustomization = [self setDefaultCustomization];
        CustomizationBlock(self.textObjectsCustomization);
        [self setCustomization:self.textObjectsCustomization
                    forObjects:[self findObjectsofClass:self.textObjectsCustomization.classesToCustomize
                                                 onView:self
                               showOnlyNonHiddenObjects:NO
                                                 fields:nil]
                     withStyle:MHTextObjectsCustomizationStyleDefault];
    }

    
    
    self.classObjects = typeOfClasses;
    [self findObjectsofClass:typeOfClasses
                      onView:self
    showOnlyNonHiddenObjects:NO
                      fields:nil];
}


-(MHTextObjectsCustomization*)setDefaultCustomization{
    
    
    MHCustomizationDetail *defaultCustomization =
    [[MHCustomizationDetail alloc] initWithBackgroundColor:[UIColor whiteColor]
                                     borderGradientColorUp:[UIColor colorWithRed:0.65f green:0.64f blue:0.63f alpha:1.00f]
                                    borderGradientColorDow:[UIColor colorWithRed:0.91f green:0.89f blue:0.88f alpha:1.00f]
                                               borderWidth:1
                                              cornerRadius:8
                                          innerShadowColor:[UIColor grayColor]
                                                labelColor:[UIColor blackColor]
                                                 labelFont:[UIFont systemFontOfSize:12]];
    
    MHCustomizationDetail *nonValidCustomization =
    [[MHCustomizationDetail alloc] initWithBackgroundColor:[UIColor whiteColor]
                                     borderGradientColorUp:[UIColor colorWithRed:0.64f green:0.00f blue:0.00f alpha:1.00f]
                                    borderGradientColorDow:[UIColor colorWithRed:0.94f green:0.30f blue:0.36f alpha:1.00f]
                                               borderWidth:1
                                              cornerRadius:8
                                          innerShadowColor:[UIColor redColor]
                                                labelColor:[UIColor blackColor]
                                                 labelFont:[UIFont systemFontOfSize:12]];
    MHCustomizationDetail *selectedCustomization =
    [[MHCustomizationDetail alloc] initWithBackgroundColor:[UIColor whiteColor]
                                     borderGradientColorUp:[UIColor colorWithRed:0.06f green:0.47f blue:0.18f alpha:1.00f]
                                    borderGradientColorDow:[UIColor colorWithRed:0.61f green:1.00f blue:0.53f alpha:1.00f]
                                               borderWidth:1
                                              cornerRadius:8
                                          innerShadowColor:[UIColor colorWithRed:0.61f green:1.00f blue:0.53f alpha:1.00f]
                                                labelColor:[UIColor blackColor]
                                                 labelFont:[UIFont systemFontOfSize:12]];
    
    
    
   return [[MHTextObjectsCustomization alloc]initWithClassesForCustomization:@[[UITextField class],[UITextView class]]
                                                  defaultCustomization:defaultCustomization
                                                 selectedCustomization:selectedCustomization
                                                 nonValidCustomization:nonValidCustomization
                                                           animationDuration:0.3];
}

- (UIView*)findFirstResponderOnView:(UIView*)view {
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderOnView:childView];
        if ( result ) return result;
    }
    return nil;
}

-(void)prevOrNext:(UISegmentedControl*)segm{
    
    MHSelectionType type = MHSelectionTypePrev;
    
    if (segm.selectedSegmentIndex ==1) {
        type = MHSelectionTypeNext;
    }
    
    
    [self searchForObjectsOfClass:self.classObjects
           selectNextOrPrevObject:type
                 foundObjectBlock:^(id object,
                                    MHSelectedObjectType objectType
                                    ) {
                     [object becomeFirstResponder];
                 }];
}

-(UISegmentedControl *)prevNextSegment {
    UISegmentedControl*  prevNextSegment = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"Zurück", nil), NSLocalizedString(@"Weiter", nil) ]];
    prevNextSegment.momentary = YES;
    [prevNextSegment setTintColor:[UIColor colorWithRed:0.92f green:0.17f blue:0.27f alpha:1.00f]];
    prevNextSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [prevNextSegment addTarget:self
                        action:@selector(prevOrNext:)
              forControlEvents:UIControlEventValueChanged];
    
    return prevNextSegment;
}

-(UIToolbar *)toolbarInit{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    [barItems addObject:[[UIBarButtonItem alloc] initWithCustomView:[self prevNextSegment]]];
    
    [barItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                      target:nil
                                                                      action:nil]];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(dismissInputView)];
    [doneItem setTintColor:[UIColor colorWithRed:0.92f green:0.17f blue:0.27f alpha:1.00f]];
    
    [barItems addObject:doneItem];
    [toolbar setItems:barItems animated:NO];
    return toolbar;
}

-(void)validateWithNONMandatoryTextObjects:(NSArray*)nonMandatoryFields
         validateObjectsWithMHRegexObjects:(NSArray*)regexObject
                     switchesWhichMustBeON:(NSArray*)onSwitches
                        curruptObjectBlock:(void(^)(NSArray *curruptItem)
                                            )CurruptedObjectBlock
                              successBlock:(void(^)(NSString *emailString,
                                                    NSDictionary *valueKeyDict,
                                                    NSArray *object,
                                                    bool isFirstRegistration)
                                            )SuccessBlock{
    
    
    NSArray *fields = [self findObjectsofClass:self.classObjects
                                        onView:self
                      showOnlyNonHiddenObjects:YES
                                        fields:nil];
    
    
    NSMutableArray *curruptFields = [NSMutableArray new];
    [fields enumerateObjectsUsingBlock:^(id field, NSUInteger idx, BOOL *stop) {
        if ([field isKindOfClass:[UITextField class]] || [field isKindOfClass:[UITextView class]]) {
            if ([field alpha]==1) {
                if (([field text].length ==0) && ![nonMandatoryFields containsObject:field]) {
                    [curruptFields addObject:field];
                }
                for (MHValidationItem *item in regexObject) {
                    if ([item.object isEqual:field]) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",item.regexString];
                        BOOL isStringValid = [predicate evaluateWithObject:[field  text]];
                        if (!isStringValid) {
                            [curruptFields addObject:field];
                        }
                    }
                }
            }
        }
        if ([field isKindOfClass:[UISwitch class]]) {
            if(![field isOn] && [onSwitches containsObject:field]){
                [curruptFields addObject:field];
            }
        }
    }];
    if (curruptFields.count) {
        if (CurruptedObjectBlock) {
            CurruptedObjectBlock([NSArray arrayWithArray:curruptFields]);
                [self setCustomization:self.textObjectsCustomization
                            forObjects:curruptFields
                             withStyle:MHTextObjectsCustomizationStyleNonValidate];
                
                NSMutableArray *accessIdent = [NSMutableArray new];
                for (id views in curruptFields) {
                    [accessIdent addObject:[views accessibilityIdentifier]];
                }
                
                NSMutableArray *textViews = [NSMutableArray new];
                for (id views in [(UIScrollView*)self subviews]) {
                    if ([views isKindOfClass:[MHTextView class]]) {
                        if ([accessIdent containsObject:[views accessibilityIdentifier]]) {
                            [textViews addObject:views];
                        }
                    }
                }
                [textViews addObjectsFromArray:curruptFields];
            if (self.shouldShakeNonValidateObjects) {
                [self shakeObjects:[NSArray arrayWithArray:textViews]];
            }
        }
    }else{
        if (SuccessBlock) {
            NSString *stringForMail = [NSString new];
            NSMutableDictionary *dictMail = [NSMutableDictionary new];
            for (id object in fields) {
                NSString *objectString = [NSString new];
                if ([object isKindOfClass:[UITextField class]] || [object isKindOfClass:[UITextView class]]) {
                    objectString = [object text];
                }
                if ([object isKindOfClass:[UISwitch class]]) {
                    objectString = @"OFF";
                    if ([object isOn]) {
                        objectString = @"ON";
                    }
                }
                if ([object isKindOfClass:[UISegmentedControl class]]) {
                    objectString = [object titleForSegmentAtIndex:[object selectedSegmentIndex]];
                }
                if ([object accessibilityIdentifier]) {
                    [dictMail setObject:objectString forKey:[object accessibilityIdentifier]];
                    stringForMail = [stringForMail stringByAppendingString:[NSString stringWithFormat:@"<br /><br />%@:         %@",[object accessibilityIdentifier],objectString ]];
                }
               
            }
            bool isFirstRegistration =NO;
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MHValidationStorage"]) {
                [dictMail setObject:@"update" forKey:@"status"];
                stringForMail = [stringForMail stringByAppendingString:[NSString stringWithFormat:@"<br /><br />%@:         %@",@"status",@"update" ]];
                
            }else{
                [dictMail setObject:@"new" forKey:@"status"];
                stringForMail = [stringForMail stringByAppendingString:[NSString stringWithFormat:@"<br /><br />%@:         %@",@"status",@"new" ]];
                isFirstRegistration =YES;
            }
            
            [[NSUserDefaults standardUserDefaults]setObject:dictMail forKey:@"MHValidationStorage"];
            [[NSUserDefaults standardUserDefaults ]synchronize];
            SuccessBlock(stringForMail,dictMail,fields,isFirstRegistration);
        }
    }
}

-(void)MHAutoContentSizeForScrollView{
    
    if ([self isKindOfClass:[UIScrollView class]]) {
        CGRect rect = CGRectZero;
        for(UIView * view in [(UIScrollView*)self subviews]){
            rect = CGRectUnion(rect, view.frame);
        }
        
        [(UIScrollView*)self setContentSize:CGSizeMake(rect.size.width, rect.size.height)];
    }else{
        NSLog(@"You can only set the ContentSize for ScrollViews");
    }
}

-(NSArray*)findAllTextFieldsInView:(UIView*)view{
    NSMutableArray *fields= [NSMutableArray new];
    for(id field in [view subviews]){
        if([field isKindOfClass:[UITextField class]])
            if (![fields containsObject:field]) {
                [fields addObject:field];
            }
        if([field respondsToSelector:@selector(subviews)]){
            [self findAllTextFieldsInView:field];
        }
    }
    return fields;
}

-(NSArray*)findObjectsofClass:(NSArray*)classArray
                       onView:(UIView*)view
     showOnlyNonHiddenObjects:(BOOL)nonHidden
                       fields:(NSMutableArray*)fields{
    
    if (!fields) {
        fields= [NSMutableArray new];
    }
    for(id field in [view subviews]){
        for (id class in classArray) {
            if([field isKindOfClass:class]){
                if (![fields containsObject:field]) {
                    if (nonHidden) {
                        BOOL isHidden = NO;
                        if ([field alpha]==0) {
                            isHidden =YES;
                        }
                        if ([field isHidden]) {
                            isHidden =YES;
                        }
                        if (!isHidden) {
                            [fields addObject:field];
                        }
                    }else{
                        [fields addObject:field];
                    }
                }
                if ([field isKindOfClass:[UITextField class]] || [field isKindOfClass:[UITextView class]]) {
                    if (![field inputAccessoryView]) {                        
                        UIToolbar *toolBar = [self toolbarInit];
                        [toolBar sizeToFit];
                        [field setInputAccessoryView:toolBar];
                    }
                }
            }
            if([field respondsToSelector:@selector(subviews)]){
                [self findObjectsofClass:classArray
                                  onView:field
                showOnlyNonHiddenObjects:nonHidden
                                  fields:fields];

            }
        }
    }
    return fields;
}

- (void)shakeObjects:(NSArray*)objects{
    
    for (id object in objects){
        CALayer *layer = [object layer];

        CGPoint pos = layer.position;
        static int numberOfShakes = 4;
        CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        CGMutablePathRef shakePath = CGPathCreateMutable();
        CGPathMoveToPoint(shakePath, NULL, pos.x, pos.y);
        int index;
        for (index = 0; index < numberOfShakes; ++index){
            CGPathAddLineToPoint(shakePath, NULL, pos.x - 8, pos.y);
            CGPathAddLineToPoint(shakePath, NULL, pos.x + 8, pos.y);
        }
        CGPathAddLineToPoint(shakePath, NULL, pos.x, pos.y);
        CGPathCloseSubpath(shakePath);
        shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        shakeAnimation.duration = 1.2;
        shakeAnimation.path = shakePath;
        [layer addAnimation:shakeAnimation forKey:nil];
    }
}


@end
