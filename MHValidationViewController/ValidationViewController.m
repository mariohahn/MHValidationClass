//
//  ValidationViewController.m
//  MHValidationViewController
//
//  Created by Mario Hahn on 12.07.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "ValidationViewController.h"

@interface ValidationViewController ()

@end



@implementation ValidationViewController




-(void)allowChanged:(UISwitch*)allow{
    if ([allow isOn]) {
        [self.scrollView setShouldShakeNonValidateObjects:YES];
    }else{
        [self.scrollView setShouldShakeNonValidateObjects:NO];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.allow addTarget:self action:@selector(allowChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.validateButton addTarget:self action:@selector(validateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    /****************************************************************************************************************************
     You have To set All AccessibilityIdentifiers for all Objects you want to Validate
     ****************************************************************************************************************************/
    
    self.firstName.accessibilityIdentifier = @"Vorname";
    self.secondName.accessibilityIdentifier = @"Nachname";
    self.email.accessibilityIdentifier = @"E-Mail";
    self.PLZ.accessibilityIdentifier = @"Postleitzahl";
    self.sex.accessibilityIdentifier = @"Geschlecht";
    self.allow.accessibilityIdentifier = @"Erlauben";
    self.problems.accessibilityIdentifier = @"Probleme";
    self.phoneNumber.accessibilityIdentifier = @"Telefonnummer";

    
    /****************************************************************************************************************************
     Sets the ContentSize. You dont have to think about differnt Screen sizes 
     ****************************************************************************************************************************/
    [self.scrollView MHAutoContentSizeForScrollViewWithPadding:10];
    
    [self.scrollView installMHValidationWithClasses:@[[UITextField class],
                                                      [UISwitch class],
                                                      [UISegmentedControl class],
                                                      [UITextView class]
                                                        ]
                           setCustomizationBlock:^(MHTextObjectsCustomization *customization) {
                        
                               
                               
                               /*****************************************************************************************
                                You can Change the look of an TextView and Textfield 
                                MHTextObjectsCustomization is changing the style of UITextFields and UITextViews by default.
                                
                                So you can set the same Style for TextFiels and TextViews.
                                
                                There are 3 different Styles:
                                
                                customization.defaultCustomization
                                customization.selectedCustomization
                                customization.nonValidCustomization
                                
                                You can change the classes here:
                                
                                Example only UITextFiels
                                customization.classesToCustomize = @[UITextField class]];
                                
                                If you don't want to use the MHTextObjectsCustomization: 
                                
                                [self.yourViewYouWantToValidate installMHValidationWithClasses:arrayOfClassesYouWantToValidate          
                                                                         setCustomizationBlock:nil];
                               ******************************************************************************************/
                           }];
    
    
    /****************************************************************************************************************************
     Shake all NonValidateObjects automatic
     ****************************************************************************************************************************/
    [self.scrollView setShouldShakeNonValidateObjects:YES];
    
    /****************************************************************************************************************************
     Shows a SegmentedControl With a Next And Prev Item
     ****************************************************************************************************************************/
    [self.scrollView setShowNextAndPrevSegmentedControl:YES];
    [self.scrollView setShouldEnableNextObjectSelectionWithEnter:YES];
    
    [self.scrollView setShouldSaveTextInput:YES];
    
}

-(void)validateButtonAction{
    
   /****************************************************************************************************************************
    MHValidation controls all text fields and text views if the text is longer than 0. If you want to check if the text is a valid email or consists only of numbers you can use a MHValidationItem
    ****************************************************************************************************************************/
    
    MHValidationItem *emailValidation = [[MHValidationItem alloc]initWithObject:self.email
                                                                    regexString:MHValidationRegexEmail];
    
    
    
    
    [self.scrollView validateWithNONMandatoryTextObjects:@[self.secondName]
                       validateObjectsWithMHRegexObjects:@[emailValidation]
                                   switchesWhichMustBeON:nil
                                      curruptObjectBlock:^(NSArray *curruptItem) {
                                          
                                      } successBlock:^(NSString *emailString, NSDictionary *valueKeyDict, NSArray *object, bool isFirstRegistration) {
                                          
                                          NSLog(@"%@",emailString);
                                          NSLog(@"%@",valueKeyDict);
                                          NSLog(@"%@",object);
                                          
                                      }];
}


@end
