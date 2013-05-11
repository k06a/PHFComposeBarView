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
    NSInteger index = prevRange.location+prevRange.length;
    NSInteger length = range.location-prevRange.location-prevRange.length;
    if (index < 0 || length == 0)
        return NO;
    NSDictionary * attrs = [self.attributedText attributesAtIndex:index effectiveRange:NULL];
    
    if ([attrs[NSFontAttributeName] pointSize] == 40.0)
    {
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
    NSMutableArray * toDelete = [NSMutableArray array];
    
    unichar ch = [@"Ẁ" characterAtIndex:0];
    for (int i = 0; i < 10; i++, ch+=2)
    {
        NSString * str = [NSString stringWithCharacters:&ch length:1];
        NSRange range = NSMakeRange(-1, self.text.length+1);
        NSRange prevRange = NSMakeRange(NSNotFound, 0-NSNotFound);
        int count = 0;
        while ((range = [self.text rangeOfString:str options:0 range:NSMakeRange(range.location+1,self.text.length - range.location - 1)]).location != NSNotFound)
        {
            //if (prevRange.location != NSNotFound)
            {
                if ([self check:range prev:prevRange])
                    return;
            }
            
            if (count > 0)
            {
                [toDelete addObject:@(range.location)];
                continue;
            }
            
            NSAttributedString * str = [self.attributedText attributedSubstringFromRange:range];
            CGSize size = [str boundingRectWithSize:CGSizeMake(100,100) options:0 context:nil].size;
            
            UITextPosition * begin = [self positionFromPosition:self.beginningOfDocument offset:range.location];
            UITextPosition * end = [self positionFromPosition:self.beginningOfDocument offset:range.location+range.length];
            UITextRange * textRange = [self textRangeFromPosition:begin toPosition:end];
            CGPoint origin = [self firstRectForRange:textRange].origin;
            
            CGRect rect = (CGRect){origin,size};
            
            UIImageView * imageView = self.images[@(ch)];
            imageView.hidden = NO;
            imageView.frame = rect;
            count++;
            prevRange = range;
        }
        
        if (prevRange.location != NSNotFound)
        {
            if ([self check:NSMakeRange(self.text.length,0) prev:prevRange])
                return;
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
        NSMutableAttributedString * str = [self.attributedText mutableCopy];
        for (NSNumber * location in toDelete.reverseObjectEnumerator)
            [str replaceCharactersInRange:NSMakeRange(location.intValue, 1) withString:@""];
        [self setAttributedText:str];
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
