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
    [self insertText:[NSString stringWithCharacters:&ch length:1]];
    [self setText:self.text];
    
    //NSMutableAttributedString * str = [self.attributedText mutableCopy];
    //NSDictionary * attributes = @{NSFontAttributeName:[UIFont fontWithName:self.font.fontName size:30]};
    //[str setAttributes:attributes range:NSMakeRange(self.selectedRange.location-1,1)];
    //self.attributedText = str;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    NSMutableArray * toDelete = [NSMutableArray array];
    
    unichar ch = [@"Ẁ" characterAtIndex:0];
    for (int i = 0; i < 10; i++, ch+=2)
    {
        NSString * str = [NSString stringWithCharacters:&ch length:1];
        NSRange range = NSMakeRange(-1, text.length+1);
        int count = 0;
        while ((range = [text rangeOfString:str options:0 range:NSMakeRange(range.location+1,text.length - range.location - 1)]).location != NSNotFound)
        {
            if (count > 0)
            {
                [toDelete addObject:@(range.location)];
                continue;
            }
            
            UITextPosition * begin = [self positionFromPosition:self.beginningOfDocument offset:range.location];
            UITextPosition * end = [self positionFromPosition:self.beginningOfDocument offset:range.location+range.length];
            UITextRange * textRange = [self textRangeFromPosition:begin toPosition:end];
            CGRect rect = [self firstRectForRange:textRange];
            
            UIImageView * imageView = self.images[@(ch)];
            imageView.hidden = NO;
            imageView.frame = rect;
            count++;
        }
        
        if (count == 0)
        {
            UIImageView * imageView = self.images[@(ch)];
            imageView.hidden = YES;
        }
    }
    
    if (toDelete.count > 0)
    {
        [toDelete sortUsingSelector:@selector(compare:)];
        NSMutableString * str = [text mutableCopy];
        for (NSNumber * location in toDelete.reverseObjectEnumerator)
            [str replaceCharactersInRange:NSMakeRange(location.intValue, 1) withString:@""];
        [self setText:str];
    }
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
