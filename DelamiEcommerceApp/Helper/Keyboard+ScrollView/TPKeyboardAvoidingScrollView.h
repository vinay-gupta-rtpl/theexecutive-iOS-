//
//  TPKeyboardAvoidingScrollView.h
//  TPKeyboardAvoiding
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2015 A Tasty Pixel. All rights reserved.
//

//This class is use for maintain keyboard appearance means automatic scroll when keyboard open. So this class hendle all text view and text field keyboard appearance.
#import <UIKit/UIKit.h>
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@interface TPKeyboardAvoidingScrollView : UIScrollView <UITextFieldDelegate, UITextViewDelegate>
- (void)contentSizeToFit;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;
@end
