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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.validateButton addTarget:self action:@selector(validateButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.firstName.accessibilityIdentifier = @"Firstname";
    self.secondName.accessibilityIdentifier = @"Secondname";
    self.email.accessibilityIdentifier = @"E-Mail";
    self.PLZ.accessibilityIdentifier = @"Postleitzahl";
    self.sex.accessibilityIdentifier = @"Geschlecht";
    self.allow.accessibilityIdentifier = @"Erlauben";
    self.problems.accessibilityIdentifier = @"Probleme";

    
    
    
    
    
    
    
    
    [self.scrollView installMHValidationWithClasses:@[[UITextField class],
                                                      [UISwitch class],
                                                      [UISegmentedControl class],
                                                      [UITextView class]
                                                        ]
                           setCustomizationBlock:^(MHTextObjectsCustomization *customization) {
                            
                           }];
    
    
    
    [self.scrollView setShouldShakeNonValidateObjects:YES];
    [self.scrollView setShowNextAndPrevSegmentedControl:YES];
    
}

-(void)validateButtonAction{
    
    MHValidationItem *emailValidation = [[MHValidationItem alloc]initWithObject:self.email
                                                                    regexString:MHValidationRegexEmail];
    
    
    
    [self.scrollView validateWithNONMandatoryTextObjects:@[self.secondName]
                       validateObjectsWithMHRegexObjects:@[emailValidation]
                                   switchesWhichMustBeON:nil
                                      curruptObjectBlock:^(NSArray *curruptItem) {
                                        //  [self.scrollView shakeObjects:curruptItem shakeBorderColor:nil];
                                          
                                      } successBlock:^(NSString *emailString, NSDictionary *valueKeyDict, NSArray *object, bool isFirstRegistration) {
                                          
                                          NSLog(@"%@",emailString);
                                          NSLog(@"%@",valueKeyDict);
                                          NSLog(@"%@",object);
                                          
                                      }];
}


@end
