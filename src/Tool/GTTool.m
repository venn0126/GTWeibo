//
//  GTTool.m
//  SimulateLocation
//
//  Created by Augus on 2025/10/1.
//  Copyright © 2025 fosafer. All rights reserved.
//

#import "GTTool.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation GTTool

static const void *kGTCellAdFlagKey = &kGTCellAdFlagKey;
static const void *kGTOwnerAdSetKey = &kGTOwnerAdSetKey;

+ (BOOL)gt_isAdModel:(id)model {
    if (!model) return NO;
    BOOL isAd = NO;
    @try {
        // 仅根据 dataDic -> data -> ad_actionlogs 是否存在有效键值判断
        if ([model respondsToSelector:@selector(dataDic)]) {
            id dictObj = ((id (*)(id, SEL))objc_msgSend)(model, @selector(dataDic));
            if ([dictObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)dictObj;
                id data = dict[@"data"]; // 可能为 NSDictionary
                if ([data isKindOfClass:[NSDictionary class]]) {
                    id adLogs = ((NSDictionary *)data)[@"ad_actionlogs"]; // 规范字段
                    // ad_actionlogs 有效：字典且 count>0，或数组且 count>0，或字符串非空
                    if ([adLogs isKindOfClass:[NSDictionary class]]) {
                        isAd = ([(NSDictionary *)adLogs count] > 0);
                    } else if ([adLogs isKindOfClass:[NSArray class]]) {
                        isAd = ([(NSArray *)adLogs count] > 0);
                    } else if ([adLogs isKindOfClass:[NSString class]]) {
                        isAd = ([(NSString *)adLogs length] > 0);
                    } else if (adLogs) {
                        // 存在其他非空类型也视为有效
                        isAd = YES;
                    }
                }
            }
        }
    } @catch (__unused NSException *e) {}
    return isAd;
}

+ (BOOL)gt_isAdDataDict:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) return NO;
    BOOL isAd = NO;
    @try {
        id data = dict[@"data"]; // 可能为 NSDictionary
        if ([data isKindOfClass:[NSDictionary class]]) {
            id adLogs = ((NSDictionary *)data)[@"ad_actionlogs"]; // 规范字段
            // ad_actionlogs 有效：字典且 count>0，或数组且 count>0，或字符串非空
            if ([adLogs isKindOfClass:[NSDictionary class]]) {
                isAd = ([(NSDictionary *)adLogs count] > 0);
            } else if ([adLogs isKindOfClass:[NSArray class]]) {
                isAd = ([(NSArray *)adLogs count] > 0);
            } else if ([adLogs isKindOfClass:[NSString class]]) {
                isAd = ([(NSString *)adLogs length] > 0);
            } else if (adLogs) {
                // 存在其他非空类型也视为有效
                isAd = YES;
            }
        }
    } @catch (__unused NSException *e) {}
    return isAd;
}

+ (BOOL)gt_isAdByCard:(id)card {
    if (!card) return NO;
    id model = nil;
    @try {
        if ([card respondsToSelector:@selector(itemModel)]) {
            model = ((id (*)(id, SEL))objc_msgSend)(card, @selector(itemModel));
        }
    } @catch (__unused NSException *e) {}
    return [self gt_isAdModel:model];
}

+ (void)gt_hideAndCompressCell:(UICollectionViewCell *)cell {
    if (!cell) return;
    objc_setAssociatedObject(cell, kGTCellAdFlagKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    cell.hidden = YES;
    cell.alpha = 0.0;
    cell.contentView.clipsToBounds = YES;
    // Compress frame immediately to avoid visible gap where possible
    CGRect f = cell.contentView.frame;
    f.size.height = 0.1;
    cell.contentView.frame = f;
}

+ (void)gt_resetCellIfNeeded:(UICollectionViewCell *)cell {
    if (!cell) return;
    NSNumber *flag = objc_getAssociatedObject(cell, kGTCellAdFlagKey);
    if (flag.boolValue) {
        cell.hidden = NO;
        cell.alpha = 1.0;
        objc_setAssociatedObject(cell, kGTCellAdFlagKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

+ (NSMutableSet<NSString *> *)p_adIndexSetForOwner:(id)owner create:(BOOL)create {
    if (!owner) return nil;
    NSMutableSet *set = objc_getAssociatedObject(owner, kGTOwnerAdSetKey);
    if (!set && create) {
        set = [NSMutableSet set];
        objc_setAssociatedObject(owner, kGTOwnerAdSetKey, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return set;
}

+ (void)gt_markAdIndexPath:(NSIndexPath *)indexPath forOwner:(id)owner {
    if (!indexPath || !owner) return;
    NSMutableSet *set = [self p_adIndexSetForOwner:owner create:YES];
    [set addObject:indexPath.description];
}

+ (BOOL)gt_isAdIndexPath:(NSIndexPath *)indexPath forOwner:(id)owner {
    if (!indexPath || !owner) return NO;
    NSSet *set = [self p_adIndexSetForOwner:owner create:NO];
    return [set containsObject:indexPath.description];
}


#pragma mark - Deep log utilities

+ (void)gt_logDictionaryDeep:(NSDictionary *)dict prefix:(NSString *)prefix {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        TLog(@"[DeepLog] not a dictionary: %@", dict);
        return;
    }
    NSString *pfx = prefix ?: @"";
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *line = [NSString stringWithFormat:@"%@[key=%@] -> %@", pfx, key, NSStringFromClass([obj class])];
        TLog(@"%s", line.UTF8String);
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [self gt_logDictionaryDeep:(NSDictionary *)obj prefix:[pfx stringByAppendingFormat:@"  "]];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)obj;
            NSInteger idx = 0;
            for (id sub in arr) {
                NSString *aline = [NSString stringWithFormat:@"%@[index=%ld] -> %@", pfx, (long)idx, NSStringFromClass([sub class])];
                TLog(@"%s", aline.UTF8String);
                if ([sub isKindOfClass:[NSDictionary class]]) {
                    [self gt_logDictionaryDeep:(NSDictionary *)sub prefix:[pfx stringByAppendingFormat:@"  "]];
                } else if ([sub isKindOfClass:[NSArray class]]) {
                    // 递归打印数组
                    [self p_logArrayDeep:(NSArray *)sub prefix:[pfx stringByAppendingFormat:@"  "]];
                } else {
                    NSString *vline = [NSString stringWithFormat:@"%@[value] %@", pfx, sub];
                    TLog(@"%s", vline.UTF8String);
                }
                idx++;
            }
        } else {
            NSString *vline = [NSString stringWithFormat:@"%@[value] %@", pfx, obj];
            TLog(@"%s", vline.UTF8String);
        }
    }];
}

+ (void)p_logArrayDeep:(NSArray *)arr prefix:(NSString *)prefix {
    NSString *pfx = prefix ?: @"";
    NSInteger idx = 0;
    for (id sub in arr) {
        NSString *aline = [NSString stringWithFormat:@"%@[index=%ld] -> %@", pfx, (long)idx, NSStringFromClass([sub class])];
        TLog(@"%s", aline.UTF8String);
        if ([sub isKindOfClass:[NSDictionary class]]) {
            [self gt_logDictionaryDeep:(NSDictionary *)sub prefix:[pfx stringByAppendingFormat:@"  "]];
        } else if ([sub isKindOfClass:[NSArray class]]) {
            [self p_logArrayDeep:(NSArray *)sub prefix:[pfx stringByAppendingFormat:@"  "]];
        } else {
            NSString *vline = [NSString stringWithFormat:@"%@[value] %@", pfx, sub];
            TLog(@"%s", vline.UTF8String);
        }
        idx++;
    }
}

@end
