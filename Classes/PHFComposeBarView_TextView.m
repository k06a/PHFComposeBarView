#import <QuartzCore/QuartzCore.h>
#import "PHFComposeBarView_TextView.h"

@interface PHFComposeBarView_TextView ()
@property (nonatomic) NSMutableDictionary * images;
@end


@implementation PHFComposeBarView_TextView

// Only allow iOS to set the offset when the user scrolls or is selecting
// text. Else it sets it in unpredictable ways which we don't want.
- (void)setContentOffset:(CGPoint)contentOffset {
    if ([self selectedRange].length || [self isTracking] || [self isDecelerating])
        [super setContentOffset:contentOffset];
}

// Expose the original -setContentOffset: method.
- (void)PHFComposeBarView_setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
}

// Slightly decrease the caret size as in iMessage.
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect rect = [super caretRectForPosition:position];
    rect.size.height -= 2;
    rect.origin.y    += 1;

    return rect;
}

@synthesize images = _images;
- (NSMutableDictionary *)images
{
    if (_images == nil)
        _images = [NSMutableDictionary dictionary];
    return _images;
}

- (void)insertImage:(UIImage *)image
{
    unichar ch = [@"Ẁ" characterAtIndex:0];
    ch += self.images.count * 2;
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.borderWidth = 1.0;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    
    [self.images setObject:imageView forKey:@(ch)];
    if (self.text.length == 0)
        self.text = [NSString stringWithCharacters:&ch length:1];
    else
        [self insertText:[NSString stringWithCharacters:&ch length:1]];
    
    NSMutableAttributedString * str = [self.attributedText mutableCopy];
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont fontWithName:self.font.fontName size:40.0]};
    [str setAttributes:attributes range:NSMakeRange(self.selectedRange.location-1,1)];
    [str setAttributes:@{} range:NSMakeRange(self.selectedRange.location,0)];
    self.attributedText = str;
}

- (BOOL)check:(NSRange)range prev:(NSRange)prevRange
{
    //NSLog(@"check: %d-%d", prevRange.location+prevRange.length, range.location);
    NSInteger index = prevRange.location+prevRange.length;
    NSInteger length = range.location-prevRange.location-prevRange.length;
    if (index < 0 || length == 0)
        return NO;
    CGSize size = [self.attributedText attributedSubstringFromRange:NSMakeRange(index, 1)].size;
    
    if (size.height >= 40.0)
    {
        //NSLog(@"size = %f x %f", size.width, size.height);
        NSMutableAttributedString * str = [self.attributedText mutableCopy];
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont fontWithName:self.font.fontName size:16.0]};
        [str setAttributes:attributes range:NSMakeRange(index,length)];
        self.attributedText = str;
        return YES;
    }
    
    return NO;
}

- (void)recalculate
{
    unichar ch = [@"Ẁ" characterAtIndex:0];
    NSMutableString * charStr = [@"" mutableCopy];
    for (int i = 0; i < 10; i++, ch+=2)
    {
        [self.images[@(ch)] setHidden:YES];
        [charStr appendString:[NSString stringWithCharacters:&ch length:1]];
    }
    NSCharacterSet * charSet = [NSCharacterSet characterSetWithCharactersInString:charStr];
    
    NSMutableArray * toDelete = [NSMutableArray array];
    
    NSRange range = NSMakeRange(-1, self.text.length+1);
    NSRange prevRange = NSMakeRange(NSNotFound, 0-NSNotFound);
    while ((range = [self.text rangeOfCharacterFromSet:charSet options:0 range:NSMakeRange(range.location+1,self.text.length - range.location - 1)]).location != NSNotFound)
    {
        if ([self check:range prev:prevRange])
            return;
        
        // If same char exist before this char we need remove it
        if ([self.text rangeOfString:[self.text substringWithRange:range]].location < range.location)
            [toDelete addObject:@(range.location)];
        
        CGSize size = [self.attributedText attributedSubstringFromRange:range].size;
            
        UITextPosition * begin = [self positionFromPosition:self.beginningOfDocument offset:range.location];
        UITextPosition * end = [self positionFromPosition:self.beginningOfDocument offset:range.location+range.length];
        UITextRange * textRange = [self textRangeFromPosition:begin toPosition:end];
        CGPoint origin = [self firstRectForRange:textRange].origin;
            
        CGRect rect = (CGRect){origin,size};
            
        UIImageView * imageView = self.images[@([self.text characterAtIndex:range.location])];
        imageView.hidden = NO;
        imageView.frame = rect;
        prevRange = range;
    }
        
    if (prevRange.location != NSNotFound)
    {
        if ([self check:NSMakeRange(self.text.length,0) prev:prevRange])
            return;
    }
    
    if (toDelete.count > 0)
    {
        [toDelete sortUsingSelector:@selector(compare:)];
        NSMutableAttributedString * attrStr = [self.attributedText mutableCopy];
        for (NSNumber * location in toDelete.reverseObjectEnumerator)
            [attrStr replaceCharactersInRange:NSMakeRange(location.intValue, 1) withString:@""];
        [self setAttributedText:attrStr];
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self recalculate];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self recalculate];
}

- (NSArray *)insertedImages
{
    NSMutableArray * array = [NSMutableArray array];
    
    unichar ch = [@"Ẁ" characterAtIndex:0];
    for (int i = 0; i < 10; i++, ch+=2)
    {
        if (self.images[@(ch)])
            [array addObject:self.images[@(ch)]];
        else
            [array addObject:[NSNull null]];
    }
    
    return array;
}

- (NSArray *)insertedImagesPositions
{
    NSMutableArray * array = [NSMutableArray array];
    
    unichar ch = [@"Ẁ" characterAtIndex:0];
    for (int i = 0; i < 10; i++, ch+=2)
    {
        NSString * str = [NSString stringWithCharacters:&ch length:1];
        NSRange range = NSMakeRange(-1, self.text.length+1);
        if ((range = [self.text rangeOfString:str options:0 range:NSMakeRange(range.location+1,self.text.length - range.location - 1)]).location != NSNotFound)
        {
            [array addObject:@(NSNotFound)];
        }
        else
            [array addObject:@(range.location - i)];
    }
    
    return array;
}

@end
