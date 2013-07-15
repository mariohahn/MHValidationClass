//
//  ViewController.h
//  MHValidationViewController
//
//  Created by Mario Hahn on 15.05.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString * const MHValidationRegexEmail = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
static NSString * const MHValidationRegexOnlyNumbers = @"[0-9]+";

typedef NS_ENUM(NSUInteger, MHSelectedObjectType) {
    MHSelectedObjectTypeFirst,
    MHSelectedObjectTypeLast,
    MHSelectedObjectTypeMiddle
};

typedef NS_ENUM(NSUInteger, MHSelectionType) {
    MHSelectionTypeNext,
    MHSelectionTypePrev,
    MHSelectionTypeCurrent
};

@interface MHValidationItem : NSObject
@property (nonatomic, strong) id object;
@property (nonatomic,strong) NSString *regexString;

- (id)initWithObject:(id)object andRegexString:(NSString*)regexString;
@end


@interface UIView (MHValidation)<UITextFieldDelegate>
@property (nonatomic, copy) NSArray *classObjects;

-(void)selectFieldWithSelectedObject:(id)selectedObject searchForObjectsOfClass:(NSArray*)classes selectNextOrPrevObject:(MHSelectionType)selectionType foundObjectBlock:(void(^)(id object, MHSelectedObjectType objectType ))FoundObjectBlock;

-(void)validateWithNonMandatoryField:(NSArray*)nonMandatoryFields andShouldValidateObjectsWithMHRegexObjects:(NSArray*)regexObject andSwitchesWhichMustBeON:(NSArray*)onSwitches curruptObjectBlock:(void(^)(NSArray *curruptItem))CurruptedObjectBlock successBlock:(void(^)(NSString *emailString,NSDictionary *valueKeyEmail,NSArray *object,bool isFirstRegistration))SuccessBlock;
- (void)shakeObjects:(id)objects andChangeBorderColor:(UIColor*)borderColor;

-(NSArray*)findObjectsofClass:(NSArray*)classArray onView:(UIView*)view andShowOnlyNonHiddenObjects:(BOOL)nonHidden;

-(void)initMHValidationWithClassObjectsToValidate:(NSArray*)classObjects;

@end
