ios-MHValidation
================
![alt tag](https://dl.dropboxusercontent.com/u/17911939/UIViewios7.png)


Setup
--------------------

Install MVValidation

		
	[self.scrollView installMHValidationWithClasses:@[[UITextField class],
                                                      [UISwitch class],
                                                      [UISegmentedControl class],
                                                      [UITextView class]
                                                        ]
                           setCustomizationBlock:^(MHTextObjectsCustomization *customization) {

                           }];

Set AccessibilityIdentifiers 

	self.firstName.accessibilityIdentifier = @"Vorname";
   	self.secondName.accessibilityIdentifier = @"Nachname";
   	self.email.accessibilityIdentifier = @"E-Mail";
   	self.PLZ.accessibilityIdentifier = @"Postleitzahl";
   	self.sex.accessibilityIdentifier = @"Geschlecht";
   	self.allow.accessibilityIdentifier = @"Erlauben";
   	self.problems.accessibilityIdentifier = @"Probleme";
   	self.phoneNumber.accessibilityIdentifier = @"Telefonnummer";	

Validate

	
    	//Regex Validation
  	  MHValidationItem *emailValidation = [[MHValidationItem alloc]initWithObject:self.email
                                                                    regexString:MHValidationRegexEmail];
    
    
   	 [self.scrollView validateWithNONMandatoryTextObjects:@[self.secondName]
                       validateObjectsWithMHRegexObjects:@[emailValidation]
                                   switchesWhichMustBeON:nil
                                      curruptObjectBlock:^(NSArray *curruptItem) {
                                          
                                      } successBlock:^(NSString *emailString, NSDictionary *valueKeyDict, NSArray *object, bool isFirstRegistration) {
                                          
                                                                                  
                                      }];



