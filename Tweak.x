
/// Block Launch Ad
%hook WBAdSdkFlashAdView

- (id)initWithWindow:(id)arg1 {
    TLog(@"WBAdSdkFlashAdView initWithWindow %@",arg1);
    return nil; 
}

%end



// Block Home Ad
%hook WBS3ItemModelFactory

+ (id)modelsForDicArray:(id)arg1 userInfo:(id)arg2 {
    id filtered = arg1;
    @try {
        if ([arg1 isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)arg1;
            NSMutableArray *keep = [NSMutableArray arrayWithCapacity:arr.count];
            for (id item in arr) {
                BOOL drop = NO;
                if ([item isKindOfClass:[NSDictionary class]]) {
                    drop = [GTTool gt_isAdDataDict:(NSDictionary *)item];
                }
                if (!drop) {
                    [keep addObject:item];
                }
            }
            filtered = [keep copy];
            if ([(NSArray *)filtered count] != arr.count) {
                TLog(@"[Filter-Factory] drop %ld ads from %ld", (long)(arr.count - [(NSArray *)filtered count]), (long)arr.count);
            }
        }
    } @catch (__unused NSException *e) {}
    return %orig(filtered, arg2);
}

%end


static const void *kGTFilteredCardsKey = &kGTFilteredCardsKey;
static const void *kGTFilteredReadyKey = &kGTFilteredReadyKey;

%hook WBSCellCardGroup

- (void)creatCellCards {
    %orig;
    @try {
        NSArray *cards = nil;
        @try { cards = [self cards]; } @catch (__unused NSException *e) {}
        if (![cards isKindOfClass:[NSArray class]] || cards.count == 0) {
            // 清空标记
            objc_setAssociatedObject(self, kGTFilteredCardsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            objc_setAssociatedObject(self, kGTFilteredReadyKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            return;
        }

        NSMutableArray *keep = [NSMutableArray arrayWithCapacity:cards.count];
        NSInteger drop = 0;
        for (id card in cards) {
            BOOL isAd = [GTTool gt_isAdByCard:card];
            if (!isAd) {
                [keep addObject:card];
            } else {
                drop++;
            }
        }

        NSArray *filtered = [keep copy];
        objc_setAssociatedObject(self, kGTFilteredCardsKey, filtered, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, kGTFilteredReadyKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (drop > 0) {
            TLog(@"[Filter-Group] group:%p drop %ld / %ld", self, (long)drop, (long)cards.count);
        }
    } @catch (__unused NSException *e) {}
}

- (unsigned long long)numberOfItems {
    @try {
        NSNumber *ready = objc_getAssociatedObject(self, kGTFilteredReadyKey);
        if (ready.boolValue) {
            NSArray *filtered = objc_getAssociatedObject(self, kGTFilteredCardsKey);
            if ([filtered isKindOfClass:[NSArray class]]) {
                return (unsigned long long)filtered.count;
            }
        }
    } @catch (__unused NSException *e) {}
    return %orig;
}

- (id)cellCardAtIndex:(long long)idx {
    @try {
        NSNumber *ready = objc_getAssociatedObject(self, kGTFilteredReadyKey);
        if (ready.boolValue) {
            NSArray *filtered = objc_getAssociatedObject(self, kGTFilteredCardsKey);
            if ([filtered isKindOfClass:[NSArray class]]) {
                if (idx >= 0 && idx < (long long)filtered.count) {
                    return filtered[(NSUInteger)idx];
                }
            }
        }
    } @catch (__unused NSException *e) {}
    return %orig;
}

- (id)cards {
    @try {
        NSNumber *ready = objc_getAssociatedObject(self, kGTFilteredReadyKey);
        if (ready.boolValue) {
            NSArray *filtered = objc_getAssociatedObject(self, kGTFilteredCardsKey);
            if ([filtered isKindOfClass:[NSArray class]]) {
                return filtered;
            }
        }
    } @catch (__unused NSException *e) {}
    return %orig;
}

%end


/// Block Video Ad

