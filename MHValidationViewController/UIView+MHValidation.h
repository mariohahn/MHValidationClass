//
//  ViewController.h
//  MHValidationViewController
//
//  Created by Mario Hahn on 15.05.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#define OSVersion [[[UIDevice currentDevice] systemVersion] floatValue]


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

@property (nonatomic,strong) UIImage *ownBackgroundImage;

@property (nonatomic,strong) UIColor *backgroundColor;

@property (nonatomic,strong) UIColor *borderGradientColorUp;
@property (nonatomic,strong) UIColor *borderGradientColorDow;

@property (nonatomic,strong) UIColor *borderColor;

@property (nonatomic,strong) UIColor *innerShadowColor;

@property (nonatomic,strong) UIFont *labelFont;
@property (nonatomic,strong) UIColor *labelColor;
@property (nonatomic,strong) UIColor *placeHolderColor;

- (id)initWithBackgroundColor:(UIColor*)backgroundColor
        borderGradientColorUp:(UIColor*)borderGradientColorUp
       borderGradientColorDow:(UIColor*)borderGradientColorDow
                  borderWidth:(float)borderWidth
                 cornerRadius:(float)cornerRadius
             innerShadowColor:(UIColor*)innerShadowColor
                   labelColor:(UIColor*)labelColor
             placeHolderColor:(UIColor*)placeHolderColor
                    labelFont:(UIFont*)labelFont;
@end



@interface MHTextObjectsCustomization : NSObject

@property (nonatomic,strong) NSArray *classesToCustomize;
@property (nonatomic) float animationDuration;

@property (nonatomic,strong) MHCustomizationDetail *defaultCustomization;
@property (nonatomic,strong) MHCustomizationDetail *selectedCustomization;
@property (nonatomic,strong) MHCustomizationDetail *nonValidCustomization;

- (id)initWithClassesForCustomization:(NSArray*)classesToCustomize
                 defaultCustomization:(MHCustomizationDetail*)defaultCustomization
                selectedCustomization:(MHCustomizationDetail*)selectedCustomization
                nonValidCustomization:(MHCustomizationDetail*)nonValidCustomization
                    animationDuration:(float)animationDuration;

@end

@interface MHTextView : UIView
@property (nonatomic,strong) MHTextObjectsCustomization *customization;
@property (nonatomic) MHTextObjectsCustomizationStyle style;

-(id)initWithFrame:(CGRect)frame
     customization:(MHTextObjectsCustomization*)customization
             style:(MHTextObjectsCustomizationStyle)style;

@end


/****************************************************************************************************************************
 MHValidation controls all text fields and text views if the text is longer than 0. If you want to check if the text is a valid email or consists only of numbers you can use a MHValidationItem
 ****************************************************************************************************************************/

@interface MHValidationItem : NSObject
@property (nonatomic, strong) id object;
@property (nonatomic,strong) NSString *regexString;

- (id)initWithObject:(id)object
         regexString:(NSString*)regexString;
@end





@interface UIView (MHValidation)<UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate>
/****************************************************************************************************************************
 List of available Classes + description:
 
 Standard:
 
 UITextView:         checks if the textlenght is > 0
 UITextField:        checks if the textlenght is > 0
 UISegmentedControl: returns the name of the selected index
 UISwicth:           returns ON or OFF
 
 MHValidationItem:
 
 UITextView:         checks if the textlenght is > 0 and REGEX
 UITextField:        checks if the textlenght is > 0 and REGEX
 UISegmentedControl: Standard
 UISwicth:           Standard
 ****************************************************************************************************************************/
@property (nonatomic, copy) NSArray *classObjects;
/****************************************************************************************************************************
 Adds a ToolBar to UITextField and UITextView
 
 ToolBar contains a doneButton and a SegmentedControl with a Next and Prev Button
 if you use a ScrollView MHValidation sets the ContentOffset for you.
 ****************************************************************************************************************************/
@property (nonatomic) BOOL showNextAndPrevSegmentedControl;
/****************************************************************************************************************************
 AutoShake animation for NonValidateObjects
 ****************************************************************************************************************************/
@property (nonatomic) BOOL shouldShakeNonValidateObjects;
/****************************************************************************************************************************
 Enable Next Object Selection With Enter
 
 DEFAULT Is NO
 ****************************************************************************************************************************/
@property (nonatomic) BOOL shouldEnableNextObjectSelectionWithEnter;


@property (nonatomic,copy) MHTextObjectsCustomization *textObjectsCustomization;


-(void)searchForObjectsOfClass:(NSArray*)classes
        selectNextOrPrevObject:(MHSelectionType)selectionType
              foundObjectBlock:(void(^)(id object,
                                        MHSelectedObjectType objectType )
                                )FoundObjectBlock;



/****************************************************************************************************************************
 Start Validation
 nonMandatoryFields- Can only be TextViews and TextField
 regexObject - Objects with special validation can only be TextViews and Textfields
 onSwitches - Switches which must be on
 curruptObjectBlock - return all curruptItems
 successBlock- can't find curruptItems
 
 emailString structure:      <br /><br />accessibilityIdentifier:         outcome
 valueKeyDict structure:     "accessibilityIdentifier" = outcome;
 object structure:           @[object,object,object]
 
 outcome:
 UITextField & UITextView :          text
 UISegmentedControl :                title of selected Objects
 UISwitch :                          ON / OFF
 ****************************************************************************************************************************/

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

/****************************************************************************************************************************
 Sets the ContentSize. You dont have to think about differnt Screen sizes
 ****************************************************************************************************************************/
-(void)MHAutoContentSizeForScrollViewWithPadding:(CGFloat)padding;

/****************************************************************************************************************************
 Shake all objects from the objects Array
 ****************************************************************************************************************************/
- (void)shakeObjects:(NSArray*)objects;

-(NSArray*)findObjectsofClass:(NSArray*)classArray
                       onView:(UIView*)view
     showOnlyNonHiddenObjects:(BOOL)nonHidden
                       fields:(NSMutableArray*)fields;

/****************************************************************************************************************************
 **************************************************    REQUIRED Methode     **************************************************
 Install MHValidation
 typeOfClasses look at classObjects
 ****************************************************************************************************************************/
-(void)installMHValidationWithClasses:(NSArray*)typeOfClasses
                setCustomizationBlock:(void(^)(MHTextObjectsCustomization *customization))CustomizationBlock;





@end
