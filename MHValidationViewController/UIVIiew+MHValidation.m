//
//  ViewController.m
//  MHValidationViewController
//
//  Created by Mario Hahn on 15.05.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "UIVIiew+MHValidation.h"
#import <QuartzCore/QuartzCore.h>

static NSString * const MHValidationEmail = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
static NSString * const MHValidationOnlyNumbers = @"[0-9]+";

@implementation MHValidationItem

-(id)initWithObject:(id)object andRegexString:(NSString *)regexString{
    self = [super init];
    if (!self)
        return nil;
    self.object = object;
    self.regexString = regexString;
    return self;
}
@end

@implementation UIView (MHValidation)

//Example Call

/*
 
 -(void)someMethode:(id)sender{

     MHValidationItem *emailItem = [[MHValidationItem alloc]initWithObject:self.emailTxt andRegexString:MHValidationEmail];
     MHValidationItem *postalCodeItem = [[MHValidationItem alloc]initWithObject:self.postalCodeTxt andRegexString:MHValidationOnlyNumbers];
     
     
     [self validateObjectOfClass:@[[UITextField class],[UISwitch class],[UISegmentedControl class]]
     onView:self.scrollsView
     andNonMandatoryField:@[self.companyTxt]
     andShouldValidateObjectsWithRegex:@[emailItem,postalCodeItem]
     andSwitchesWhichMustBeON:@[self.agreementSwitch]
     curruptObjectBlock:^(NSArray *curruptItem) {
     [self shakeObjects:curruptItem andChangeBorderColor:nil];
     }successBlock:^(NSString *emailString,NSDictionary *valueKeyEmail, NSArray *object,bool isFirstRegistration) {
     
     [self sendMailWithDictionary:[NSDictionary dictionaryWithObject:emailString forKey:@"message"]];
     }];
 }
 
 */

-(void)validateObjectOfClass:(NSArray*)class onView:(UIView*)view andNonMandatoryField:(NSArray*)nonMandatoryFields andShouldValidateObjectsWithRegex:(NSArray*)regexObject andSwitchesWhichMustBeON:(NSArray*)onSwitches curruptObjectBlock:(void(^)(NSArray *curruptItem))CurruptedObjectBlock successBlock:(void(^)(NSString *emailString,NSDictionary *valueKeyEmail,NSArray *object,bool isFirstRegistration))SuccessBlock{
    
    NSArray *fields = [self findObjectsofClass:class onView:view andShowOnlyNonHiddenObjects:YES];
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
            if([field isKindOfClass:class])
                if (![fields containsObject:field]) {
                    if ([field alpha]==1 && nonHidden) {
                        [fields addObject:field];
                    }
                    if (!nonHidden) {
                        [fields addObject:field];
                    }
                }
            if([field respondsToSelector:@selector(subviews)]){
                [self findObjectsofClass:classArray onView:field andShowOnlyNonHiddenObjects:nonHidden];
            }
        }
    }
    return fields;
}

- (void)shakeObjects:(id)objects {
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
