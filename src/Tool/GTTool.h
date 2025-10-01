//
//  GTTool.h
//  SimulateLocation
//
//  Created byAugus on 2025/10/1.
//  Copyright © 2025 fosafer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTTool : NSObject

// Detect if a card/model represents an ad.
+ (BOOL)gt_isAdByCard:(id)card; // expects WBS3CellCardProtocol-like object
+ (BOOL)gt_isAdModel:(id)model; // expects WBS3ItemModel-like object

// UI handling
+ (void)gt_hideAndCompressCell:(UICollectionViewCell *)cell;
+ (void)gt_resetCellIfNeeded:(UICollectionViewCell *)cell;

// Index tracking on a manager instance (owner is dataSource like WBS3CollectionViewManager)
+ (void)gt_markAdIndexPath:(NSIndexPath *)indexPath forOwner:(id)owner;
+ (BOOL)gt_isAdIndexPath:(NSIndexPath *)indexPath forOwner:(id)owner;

// Deep log utilities
+ (void)gt_logDictionaryDeep:(NSDictionary *)dict prefix:(NSString *)prefix;


@end

NS_ASSUME_NONNULL_END
