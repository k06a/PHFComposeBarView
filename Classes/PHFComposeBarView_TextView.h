#import <UIKit/UIKit.h>

@interface PHFComposeBarView_TextView : UITextView
- (void)PHFComposeBarView_setContentOffset:(CGPoint)contentOffset;
- (void)insertImage:(UIImage *)image;
- (NSArray *)insertedImages;
- (NSArray *)insertedImagesPositions;
@end
