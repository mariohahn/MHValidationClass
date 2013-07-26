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


typedef NS_ENUM(NSUInteger, MHTextObjectsCustomizationStyle) {
    MHTextObjectsCustomizationStyleDefault,
    MHTextObjectsCustomizationStyleSelected,
    MHTextObjectsCustomizationStyleNonValidate
};

@interface MHCustomizationDetail : NSObject

@property (nonatomic) float cornerRadius;
@property (nonatomic) float borderWidth;

@property (nonatomic,strong) UIColor *backgroundColor;

@property (nonatomic,strong) UIColor *borderGradientColorUp;
@property (nonatomic,strong) UIColor *borderGradientColorDow;

@property (nonatomic,strong) UIColor *innerShadowColor;

@property (nonatomic,strong) UIFont *labelFont;
@property (nonatomic,strong) UIColor *labelColor;

- (id)initWithBackgroundColor:(UIColor*)backgroundColor
        borderGradientColorUp:(UIColor*)borderGradientColorUp
       borderGradientColorDow:(UIColor*)borderGradientColorDow
                  borderWidth:(float)borderWidth
                 cornerRadius:(float)cornerRadius
             innerShadowColor:(UIColor*)innerShadowColor
                   labelColor:(UIColor*)labelColor
                    labelFont:(UIFont*)labelFont;

@end



@interface MHTextObjectsCustomization : NSObject

@property (nonatomic,strong) NSArray *classesToCustomize;

@property (nonatomic,strong) MHCustomizationDetail *defaultCustomization;
@property (nonatomic,strong) MHCustomizationDetail *selectedCustomization;
@property (nonatomic,strong) MHCustomizationDetail *nonValidCustomization;

- (id)initWithClassesForCustomization:(NSArray*)classesToCustomize
                 defaultCustomization:(MHCustomizationDetail*)defaultCustomization
                selectedCustomization:(MHCustomizationDetail*)selectedCustomization
                nonValidCustomization:(MHCustomizationDetail*)nonValidCustomization;

@end

@interface MHTextView : UIView
@property (nonatomic,strong) MHTextObjectsCustomization *customization;
@property (nonatomic) MHTextObjectsCustomizationStyle style;

-(id)initWithFrame:(CGRect)frame
     customization:(MHTextObjectsCustomization*)customization
             style:(MHTextObjectsCustomizationStyle)style;

@end




@interface MHValidationItem : NSObject
@property (nonatomic, strong) id object;
@property (nonatomic,strong) NSString *regexString;

- (id)initWithObject:(id)object
         regexString:(NSString*)regexString;
@end





@interface UIView (MHValidation)<UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic, copy) NSArray *classObjects;
@property (nonatomic) BOOL showNextAndPrevSegmentedControl;
@property (nonatomic) BOOL shouldShakeNonValidateObjects;
@property (nonatomic,copy) MHTextObjectsCustomization *textObjectsCustomization;


-(void)searchForObjectsOfClass:(NSArray*)classes
        selectNextOrPrevObject:(MHSelectionType)selectionType
              foundObjectBlock:(void(^)(id object,
                                        MHSelectedObjectType objectType )
                                )FoundObjectBlock;

-(void)validateWithNONMandatoryTextObjects:(NSArray*)nonMandatoryFields
         validateObjectsWithMHRegexObjects:(NSArray*)regexObject
                     switchesWhichMustBeON:(NSArray*)onSwitches
                        curruptObjectBlock:(void(^)(NSArray *curruptItem)
                                            )CurruptedObjectBlock
                              successBlock:(void(^)(NSString *emailString,
                                                    NSDictionary *valueKeyDict,
                                                    NSArray *object,
                                                    bool isFirstRegistration)
                                            )SuccessBlock;


-(void)setMHContentSizeOfScrollView;

- (void)shakeObjects:(id)objects;

-(NSArray*)findObjectsofClass:(NSArray*)classArray
                       onView:(UIView*)view
     showOnlyNonHiddenObjects:(BOOL)nonHidden;

-(void)installMHValidationWithClasses:(NSArray*)typeOfClasses
                setCustomizationBlock:(void(^)(MHTextObjectsCustomization *customization))CustomizationBlock;





@end
