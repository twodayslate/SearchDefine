// @interface SPSearchResult : NSObject
// @property (nonatomic,retain) NSString * fbr; 
// -(void)setTitle:(NSString *)arg1 ;
// -(void)setSearchResultDomain:(unsigned)arg1 ;
// -(void)setUrl:(NSString *)arg1 ;
// @end

// @interface SPSearchResultSection
// @property (nonatomic, retain) NSString *displayIdentifier;
// @property (nonatomic) unsigned int domain;
// - (void)addResults:(SPSearchResult *)arg1;
// @end

@interface SPSearchAgent
- (id)queryString;
@end

@interface SPUISearchViewController : UIViewController
- (void)actionManager:(id)arg1 presentViewController:(id)arg2 completion:(id /* block */)arg3 modally:(BOOL)arg4;
- (id)_actionManager;
- (void)actionManager:(id)arg1 dismissViewController:(id)arg2 completion:(id /* block */)arg3 animated:(BOOL)arg4;
+(SPUISearchViewController *)sharedInstance;
@end



@interface _UIDictionaryManager : NSObject
+ (id)assetManager;
- (id)_definitionValuesForTerm:(id)arg1;
@end
@interface _UIDefinitionValue : NSObject
- (id)definition;
- (id)term;
- (id)longDefinition;
- (id)localizedDictionaryName;
@end

// @interface ASAssetQuery
// -(id)initWithAssetType:(id)arg1;
// -(id)runQueryAndReturnError:(NSError**)arg1;
// -(NSPredicate *)predicate;
// -(NSArray *)results;
// @end

// %hook ASAsset
// -(id)initWithAssetType:(id)arg1 attributes:(id)arg2  {
// 	//%log;
// 	//HBLogDebug(@"class of arg1 = %@", [arg1 class]);
// 	return %orig;
// }
// %end

// static CFStringRef aCFString = CFStringCreateWithCString(kCFAllocatorDefault, "com.apple.MobileAsset.DictionaryServices.dictionary2", kCFStringEncodingMacRoman);

// %hook ASAssetQuery
// -(id)initWithAssetType:(id)arg1 {
// 	%log;
// 	return %orig;
// }
// // - (void)setPredicate:(id)arg1 {
// // 	%log;
// // 	%orig;
// // }
// - (void)setPredicate:(id*)arg1 {
// 	%log;
// 	%orig;	
// }
// // **NSError
// -(id)runQueryAndReturnError:(id*)arg1 {
// 	%log;
// 	HBLogDebug(@"predicate = %@", [self predicate]);
// 	return %orig;
// }
// + (id)queryPredicateForProperties:(id)arg1 {
// 	%log;
// 	return %orig;
// }
// -(void)startQuery:(/*^block*/id)arg1  {
// 	%log;
// 	%orig;
// }
// %end
@interface SPSearchResult : NSObject
@property (nonatomic,retain) NSString * fbr; 
@property (nonatomic,retain) NSString * templateName; 
@property (nonatomic,retain) NSString * card_title; 
@property (assign,nonatomic) int flags;                                                   //@synthesize flags=_flags - In the implementation block
-(void)setTitle:(NSString *)arg1 ;
- (void)setSubtitle:(id)arg1;
-(void)setSearchResultDomain:(unsigned)arg1 ;
-(void)setBundleID:(NSString *)arg1 ;
-(void)setExternalIdentifier:(NSString *)arg1 ;
-(void)setHasAssociatedUserActivity:(BOOL)arg1 ;
-(void)setUserActivityEligibleForPublicIndexing:(BOOL)arg1 ;
-(void)setUrl:(NSString *)arg1 ;
- (void)setSummary:(id)arg1;
- (void)setAuxiliarySubtitle:(id)arg1;
- (void)setAuxiliaryTitle:(id)arg1;
@property (nonatomic) int description_maxlines;
@property (nonatomic) unsigned int numberOfSummaryLines;
- (void)setNumberOfSummaryLines:(unsigned int)arg1;
- (void)setHasNumberOfSummaryLines:(BOOL)arg1;
@property (nonatomic, retain) NSArray *descriptions;
@property (nonatomic, retain) NSString *resultDescription;
@end

@interface SPSearchResultSection
@property (nonatomic, retain) NSString *displayIdentifier;
@property (nonatomic) unsigned int domain;
@property (nonatomic, retain) NSString *category;
- (void)addResults:(SPSearchResult *)arg1;
- (id)results;
- (id)resultsAtIndex:(unsigned int)arg1;
@end

@interface SPUISearchModel
- (void)addDictionarySection;
- (NSString *)queryString;
-(void)addSections:(id)arg1 ;
- (SPSearchResultSection*)sectionAtIndex:(unsigned int)arg1;
@end


static UIReferenceLibraryViewController *controller = nil;
static SPUISearchModel *myModel = nil;
static bool didDefine = NO;

%hook SBIconController
- (_Bool)dismissSpotlightIfNecessary {
	if(controller) {
		[(SPUISearchViewController *)[%c(SPUISearchViewController) sharedInstance] actionManager:[(SPUISearchViewController *)[%c(SPUISearchViewController) sharedInstance] _actionManager] dismissViewController:controller completion:^{controller = nil;} animated:YES];
	}
	return %orig;
}
%end

%hook SPUISearchViewController
-(void)openURL:(NSURL *)arg1  {
	if([arg1.pathComponents[0] isEqualToString:@"twerk_define:"]) {
		controller = [[UIReferenceLibraryViewController alloc] initWithTerm:arg1.pathComponents[1]];
		[self actionManager:[self _actionManager] presentViewController:controller completion:nil modally:YES];
	} else {
		%orig;
	}
}
%end



%hook SPUISearchModel 
%new
- (void)addDictionarySection {
	SPSearchResultSection *newSection = [[%c(SPSearchResultSection) alloc] init];
	[newSection setDisplayIdentifier:@"Dictionary"];
	[newSection setCategory:@"Dictionary"];
	[newSection setDomain:23];
	_UIDictionaryManager *manager = [%c(_UIDictionaryManager) assetManager];
	HBLogDebug(@"manager = %@, class = %@", manager, [manager class]);
	id definitions = [manager _definitionValuesForTerm:[self queryString]];

	for(_UIDefinitionValue *item in definitions) {
		myModel = self;
		NSMutableAttributedString *def = [item definition];
		NSString *str = [def string];
		NSArray *lines = [str componentsSeparatedByString:@"\n"];
		HBLogDebug(@"%@ = %@", [item localizedDictionaryName], lines[1]);

		SPSearchResult *myOtherCustomThing = [[%c(SPSearchResult) alloc] init];
		[myOtherCustomThing setTitle:[item localizedDictionaryName]];
		// [myOtherCustomThing setSubtitle:lines[1]];
		[myOtherCustomThing setSummary:lines[1]];
		[myOtherCustomThing setHasNumberOfSummaryLines:YES];
		[myOtherCustomThing setNumberOfSummaryLines:3];

		myOtherCustomThing.numberOfSummaryLines = 3;

		// [myOtherCustomThing setAuxiliarySubtitle:lines[1]];
		// [myOtherCustomThing setAuxiliaryTitle:lines[1]];
		[myOtherCustomThing setSearchResultDomain:1];
		// [myOtherCustomThing setBundleID:@"twerk_define"];
		// [myOtherCustomThing setExternalIdentifier:@"twerk_define"];
		NSString *searchDefQuery = [NSString stringWithFormat:@"twerk_define://%@", [self queryString]];
		[myOtherCustomThing setUrl:searchDefQuery];
		myOtherCustomThing.templateName = @"generic";
		myOtherCustomThing.card_title = @"Dictionary";
		myOtherCustomThing.fbr = @"search_define"; 
		// NSDictionary* text = @{@"emphasized":@0, @"lines":lines[1]};
		// NSDictionary* dict = @{@"formatted_text":text, @"text_maxlines":@3};
		// HBLogDebug(@"%@", dict);
		// myOtherCustomThing.descriptions = @[dict];
		myOtherCustomThing.resultDescription = lines[1];
		myOtherCustomThing.description_maxlines = 3;
		[myOtherCustomThing setHasAssociatedUserActivity:NO];
		[myOtherCustomThing setUserActivityEligibleForPublicIndexing:NO];

		[newSection addResults:myOtherCustomThing];
	}
	NSMutableArray *rar = [NSMutableArray array];
	[rar addObject:newSection];
	[self addSections:rar];
}

- (void)addSections:(NSMutableArray *)arg1 {
	SPSearchResultSection *firstSection = [arg1 objectAtIndex:0];
	for(SPSearchResultSection *res in arg1) {
		SPSearchResult *first = [res resultsAtIndex:0];
		HBLogDebug(@"%@", [first descriptions][0]);
		HBLogDebug(@"%@", [[first descriptions][0] class]);
	}
	
	if(firstSection.domain == 1) {
		// ASAssetQuery * aq = [[%c(ASAssetQuery) alloc] initWithAssetType:@"com.apple.MobileAsset.DictionaryServices.dictionary2"];
		// NSError *err = nil;
		// id ret = [aq runQueryAndReturnError:&err];
		// HBLogDebug(@"err = %@", err);
		// NSArray *results = [aq results];
		// HBLogDebug(@"results = %@", results);
		// HBLogDebug(@"ret = %@", ret);

		if([UIReferenceLibraryViewController dictionaryHasDefinitionForTerm:[self queryString]]) {
			didDefine = YES;
			//might want to move this outside of firstsection.domain == 1
			[self addDictionarySection];

			NSString *searchDefQuery = [NSString stringWithFormat:@"twerk_define://%@", [self queryString]];

			SPSearchResult *myOtherCustomThing = [[%c(SPSearchResult) alloc] init];
			[myOtherCustomThing setTitle:@"Search Dictionary"];
			[myOtherCustomThing setSearchResultDomain:1];
			[myOtherCustomThing setUrl:searchDefQuery];
			myOtherCustomThing.fbr = @"search_define"; 

			[firstSection addResults:myOtherCustomThing];
		} else {
			didDefine = NO;
		}
	}
	
	%orig(arg1);
}
%end

@interface SPUISearchTableHeaderView
@property (nonatomic) unsigned int section;
-(void)setMoreButtonVisible:(bool)arg1;
- (void)updateWithTitle:(id)arg1 section:(unsigned int)arg2 isExpanded:(BOOL)arg3;
@end
@interface SPUISearchTableView : UITableView
- (void)toggleExpansionForSection:(unsigned int)arg1;
- (BOOL)sectionIsExpanded:(int)arg1;
@end
%hook SPUISearchTableHeaderView
- (void)updateWithTitle:(id)arg1 section:(unsigned int)arg2 isExpanded:(BOOL)arg3 {
	%log;
	bool newArg3 = arg3;
	if(didDefine) {
		SPUISearchViewController *vcont = [%c(SPUISearchViewController) sharedInstance];
		SPUISearchTableView *tableview = MSHookIvar<SPUISearchTableView *>(vcont, "_tableView");
		if([[myModel sectionAtIndex:arg2].displayIdentifier isEqual:@"Dictionary"]) {
			arg1 = @"Dictionary";
		} else  if(self.section == tableview.numberOfSections-1) { // definitions is always the last section
			[self setMoreButtonVisible:NO];
			arg3 = YES;
		}
	}
	%orig(arg1, arg2, newArg3);
}
- (void)setMoreButtonVisible:(BOOL)arg1 {
	SPUISearchViewController *vcont = [%c(SPUISearchViewController) sharedInstance];
	SPUISearchTableView *tableview = MSHookIvar<SPUISearchTableView *>(vcont, "_tableView");
	if(didDefine && self.section == tableview.numberOfSections-1) { // definitions is always the last section
		if(![tableview sectionIsExpanded:self.section]) {
			[tableview toggleExpansionForSection:self.section];
		}
		%orig(NO);
	} else {
		%orig;
	}
}
%end