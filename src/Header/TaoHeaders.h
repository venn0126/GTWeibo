/// MARK: 全局变量的声明
///
///
typedef id CDUnknownBlockType;
typedef id CDUnknownFunctionPointerType;



@interface WBAdSdkFlashAdView : UIView 


- (void)showAd;
- (void)skipButtonPress:(id)arg1;

@end


@interface WBS3CollectionViewCell : UICollectionViewCell

// Weakly declared to avoid strict protocol dependency; we only need to message it dynamically.
@property(readonly, nonatomic) __weak id card;
@property(retain, nonatomic) NSString *supplementaryKind; // @synthesize supplementaryKind=_supplementaryKind;

@end


@interface WBS3CellCollectionViewCell : WBS3CollectionViewCell
{
}

+ (Class)class;
- (id)accessibilityContentProvider;
- (id)accessibilityContentProviderForView:(id)arg1;
- (id)accessibilityHint;
- (id)accessibilityLabel;
- (_Bool)accessibilityPerformMagicTap;
- (_Bool)accessibilityPerformMagicTapForCell:(id)arg1;
- (id)accessibilityValue;
- (_Bool)isAccessibilityElement;

@end


@interface WBS3RLCollectionView : UICollectionView 



@end
