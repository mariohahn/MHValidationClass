//
//  ViewController.h
//  MHValidationViewController
//
//  Created by Mario Hahn on 15.05.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHValidationItem : NSObject
@property (nonatomic, strong) id object;
@property (nonatomic,strong) NSString *regexString;

- (id)initWithObject:(id)object andRegexString:(NSString*)regexString;
@end


@interface UIView (MHValidation)

-(void)validateObjectOfClass:(NSArray*)class onView:(UIView*)view andNonMandatoryField:(NSArray*)nonMandatoryFields andShouldValidateObjectsWithRegex:(NSArray*)regexObject andSwitchesWhichMustBeON:(NSArray*)onSwitches curruptObjectBlock:(void(^)(NSArray *curruptItem))CurruptedObjectBlock successBlock:(void(^)(NSString *emailString,NSDictionary *valueKeyEmail,NSArray *object,bool isFirstRegistration))SuccessBlock;
- (void)shakeObjects:(id)objects;
-(NSArray*)findObjectsofClass:(NSArray*)classArray onView:(UIView*)view andShowOnlyNonHiddenObjects:(BOOL)nonHidden;
@end
