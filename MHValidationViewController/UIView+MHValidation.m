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
@dynamic shouldShowNextPrevWithToolbar;
@dynamic shouldShakeNonValidateObjects;


//SHAKE OBEJCTS
-(void)setShouldShakeNonValidateObjects:(BOOL)shouldShakeNonValidateObjects{
    objc_setAssociatedObject(self, &SHAKE_OBJECTS_IDENTIFIER, [NSNumber numberWithBool:shouldShakeNonValidateObjects], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)shouldShakeNonValidateObjects{
    return [objc_getAssociatedObject(self, &SHAKE_OBJECTS_IDENTIFIER) boolValue];
}


//ENABLE NEXT PREV
-(void)setShouldShowNextPrevWithToolbar:(BOOL)shouldShowNextPrevWithToolbar{
    objc_setAssociatedObject(self, &ENABLE_NEXTPREV_IDENTIFIER, [NSNumber numberWithBool:shouldShowNextPrevWithToolbar], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)shouldShowNextPrevWithToolbar{
    return [objc_getAssociatedObject(self, &ENABLE_NEXTPREV_IDENTIFIER) boolValue];
}

//CLASS OBEJCTS
-(void)setClassObjects:(NSArray *)classObjects{
    objc_setAssociatedObject(self, &CLASS_OBJECTS_IDENTIFIER, classObjects, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSArray*)classObjects{
    return objc_getAssociatedObject(self, &CLASS_OBJECTS_IDENTIFIER);
}

-(void)selectFieldWithSelectedObject:(id)selectedObject searchForObjectsOfClass:(NSArray*)classes selectNextOrPrevObject:(MHSelectionType)selectionType foundObjectBlock:(void(^)(id object, MHSelectedObjectType objectType ))FoundObjectBlock{
    
    NSArray *textFields = [self findObjectsofClass:classes onView:self andShowOnlyNonHiddenObjects:YES];
    NSComparator comparatorBlock = ^(id obj1, id obj2) {
        if ([obj1 frame].origin.y > [obj2 frame].origin.y) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 frame].origin.y < [obj2 frame].origin.y) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    id objectWhichShouldBecomeFirstResponder= nil;
    NSMutableArray *fieldsSort = [[NSMutableArray alloc]initWithArray:textFields];
    [fieldsSort sortUsingComparator:comparatorBlock];
    for (id viewsAndFields in fieldsSort) {
        if (([viewsAndFields frame].origin.y == [selectedObject frame].origin.y)&&([viewsAndFields frame].origin.x > [selectedObject frame].origin.x) ) {
            objectWhichShouldBecomeFirstResponder = viewsAndFields;
            break;
        }
        if (([viewsAndFields frame].origin.y > [selectedObject frame].origin.y) ) {
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
            int index = [fieldsSort indexOfObject:[self findFirstResponderBeneathView:self]];
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
        if ([fieldsSort indexOfObject:[self findFirstResponderBeneathView:self]]==0) {
            FoundObjectBlock([self findFirstResponderBeneathView:self],MHSelectedObjectTypeFirst);
        }else if ([fieldsSort indexOfObject:[self findFirstResponderBeneathView:self]]==fieldsSort.count-1) {
            FoundObjectBlock([self findFirstResponderBeneathView:self],MHSelectedObjectTypeLast);
        }else{
            FoundObjectBlock([self findFirstResponderBeneathView:self],MHSelectedObjectTypeMiddle);
        }
    }
    if ([selectedObject isFirstResponder] && selectionType == MHSelectionTypeNext) {
        FoundObjectBlock(nil,MHSelectedObjectTypeLast);
    }
}

-(void)disableSegment:(MHSelectionType)mhselectionType{
    id firstresponder = [self findFirstResponderBeneathView:self];
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
    [self endEditing:YES];
}



-(void)keyboardWillShow:(NSNotification*)not{
    if (self.shouldShowNextPrevWithToolbar) {
    id firstResponder = [self findFirstResponderBeneathView:self];
    if (![firstResponder inputAccessoryView]) {
        UIToolbar *toolBar = [self toolbarInit];
        [toolBar sizeToFit];
        [firstResponder setInputAccessoryView:toolBar];
    }
    [self selectFieldWithSelectedObject:[self findFirstResponderBeneathView:self] searchForObjectsOfClass:self.classObjects selectNextOrPrevObject:MHSelectionTypeCurrent foundObjectBlock:^(id object, MHSelectedObjectType objectType) {
        if (objectType == MHSelectedObjectTypeFirst) {
            [self disableSegment:MHSelectionTypePrev];
        }else if(objectType == MHSelectedObjectTypeLast){
            [self disableSegment:MHSelectionTypeNext];
        }
    }];
    if ([self isKindOfClass:[UIScrollView class]]) {
        
        [self adjustContentOffset];
    }
    }
    
}


-(void)adjustContentOffset{
    UIScrollView *scroll = (UIScrollView*)self;
    
    id firstResponder = [self findFirstResponderBeneathView:self];
   
    if([firstResponder frame].origin.y+[firstResponder frame].size.height<(self.bounds.size.height-[firstResponder inputAccessoryView].frame.size.height-250)){
        [scroll setContentOffset:CGPointMake(0,0) animated:YES];
    }else{
        [scroll setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0,([firstResponder frame].origin.y+ [firstResponder frame].size.height)- self.bounds.size.height+265, 0)];
        [scroll setContentInset:UIEdgeInsetsMake(0, 0, ([firstResponder frame].origin.y+ [firstResponder frame].size.height)- self.bounds.size.height+265, 0)];
        [scroll setContentOffset:CGPointMake(0,([firstResponder frame].origin.y+ [firstResponder frame].size.height)- self.bounds.size.height+265) animated:YES];

    }

}


-(void)keyboardWillHide:(id)sender{
    if (self.shouldShowNextPrevWithToolbar) {
        if ([self isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll= (UIScrollView*)self;
            [scroll setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [scroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [scroll setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

-(void)initMHValidationWithClassObjectsToValidate:(NSArray*)classObjects{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.classObjects = classObjects;
    [self findObjectsofClass:classObjects onView:self andShowOnlyNonHiddenObjects:NO];
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view {
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

-(void)prevOrNext:(UISegmentedControl*)segm{
    if (segm.selectedSegmentIndex ==1) {
        [self selectFieldWithSelectedObject:[self findFirstResponderBeneathView:self] searchForObjectsOfClass:self.classObjects selectNextOrPrevObject:MHSelectionTypeNext foundObjectBlock:^(id object, MHSelectedObjectType objectType) {
            [object becomeFirstResponder];
        }];
    }else{
        [self selectFieldWithSelectedObject:[self findFirstResponderBeneathView:self] searchForObjectsOfClass:self.classObjects selectNextOrPrevObject:MHSelectionTypePrev foundObjectBlock:^(id object, MHSelectedObjectType objectType) {
            [object becomeFirstResponder];
        }];

    }
}

-(UISegmentedControl *)prevNextSegment {
    UISegmentedControl*  prevNextSegment = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"Zurück", nil), NSLocalizedString(@"Weiter", nil) ]];
    prevNextSegment.momentary = YES;
    prevNextSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    [prevNextSegment addTarget:self action:@selector(prevOrNext:) forControlEvents:UIControlEventValueChanged];
    return prevNextSegment;
}

-(UIToolbar *)toolbarInit{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    [barItems addObject:[[UIBarButtonItem alloc] initWithCustomView:[self prevNextSegment]]];
    [barItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissInputView)];
    [barItems addObject:doneItem];
    [toolbar setItems:barItems animated:NO];
    return toolbar;
}

-(void)validateWithNonMandatoryField:(NSArray*)nonMandatoryFields andShouldValidateObjectsWithMHRegexObjects:(NSArray*)regexObject switchesWhichMustBeON:(NSArray*)onSwitches curruptObjectBlock:(void(^)(NSArray *curruptItem))CurruptedObjectBlock successBlock:(void(^)(NSString *emailString,NSDictionary *valueKeyEmail,NSArray *object,bool isFirstRegistration))SuccessBlock{

    NSArray *fields = [self findObjectsofClass:self.classObjects onView:self andShowOnlyNonHiddenObjects:YES];
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
            if (self.shouldShakeNonValidateObjects) {
                [self shakeObjects:[NSArray arrayWithArray:curruptFields] andChangeBorderColor:nil];
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
                [dictMail setObject:objectString forKey:[object accessibilityIdentifier]];
                stringForMail = [stringForMail stringByAppendingString:[NSString stringWithFormat:@"<br /><br />%@:         %@",[object accessibilityIdentifier],objectString ]];
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

-(NSArray*)findObjectsofClass:(NSArray*)classArray onView:(UIView*)view andShowOnlyNonHiddenObjects:(BOOL)nonHidden{
    NSMutableArray *fields= [NSMutableArray new];
    for(id field in [view subviews]){
        for (id class in classArray) {
            if([field isKindOfClass:class]){
                if (![fields containsObject:field]) {
                    if ([field alpha]==1 && nonHidden) {
                        [fields addObject:field];
                    }
                    if (!nonHidden) {
                        [fields addObject:field];
                    }
                }
                if ([field isKindOfClass:[UITextField class]] || [field isKindOfClass:[UITextView class]]) {
                    if (self.shouldShowNextPrevWithToolbar) {
                        [field setDelegate:self];
                    }
                }
            }
            if([field respondsToSelector:@selector(subviews)]){
                [self findObjectsofClass:classArray onView:field andShowOnlyNonHiddenObjects:nonHidden];
            }
        }
    }
    return fields;
}

- (void)shakeObjects:(id)objects andChangeBorderColor:(UIColor*)borderColor{
    for (id object in objects){
        CALayer *layer = [object layer];
        if (borderColor) {
            [layer setBorderColor:[borderColor CGColor]];
        }
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
