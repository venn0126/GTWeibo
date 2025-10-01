%hook WBAdSdkFlashAdView

- (id)initWithWindow:(id)arg1 {
	TLog(@"WBAdSdkFlashAdView initWithWindow %@",arg1);
	return nil; // 直接禁用开屏广告
}

%end



%hook WBS3CollectionViewManager

// 1) 出队后判定并隐藏/压缩
- (id)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = %orig;
    @try {
        if ([cell isKindOfClass:[%c(WBS3CollectionViewCell) class]]) {
            id card = ((WBS3CollectionViewCell *)cell).card;
            BOOL isAd = [GTTool gt_isAdByCard:card];
            if (isAd) {
                TLog(@"[AD] cellFor index:%@ -> compress height", indexPath);
                [GTTool gt_markAdIndexPath:indexPath forOwner:self];
                // 不隐藏，交由尺寸回调压缩高度
                [GTTool gt_hideAndCompressCell:cell];
                // cell.contentView.backgroundColor = [UIColor greenColor];
            } else {
                [GTTool gt_resetCellIfNeeded:cell];
                // cell.contentView.backgroundColor = [UIColor clearColor];
            }
        }
    } @catch (__unused NSException *e) {}
    return cell;
}


// 结束展示时清理复用状态
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
	%orig;
	[GTTool gt_resetCellIfNeeded:cell];
}

%end


%hook WBS3ItemModel

- (NSDictionary *)dataDic {
	NSDictionary *r = %orig;
	// TLog(@"WBS3ItemModel dataDic---%@",r);
	// [GTTool gt_logDictionaryDeep:r prefix:@""];

	return r;
}



%end

