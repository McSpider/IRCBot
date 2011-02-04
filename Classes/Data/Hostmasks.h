//
//  Hostmasks.h
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

@interface Hostmasks : NSObject {

	int userIndex;
	NSMutableArray *hostmaskArray;
	
	IBOutlet NSTableView *hostmaskView;
	IBOutlet NSTextField *newHostmaskField;
	IBOutlet NSTextField *sheetErrorMessage;
	IBOutlet NSButton *newHostmaskCheck;
	IBOutlet BWSheetController *addHostmaskPane;
	IBOutlet NSButton *removeHostmaskButton;
	
}

@property (nonatomic,assign) NSMutableArray *hostmaskArray;

-(IBAction)addNewHostmask:(id)sender;
-(IBAction)removeSelectedHostmask:(id)sender;

-(void)addHostmask:(NSString *)host block:(BOOL)boolean;
-(void)removeHostmask:(NSString *)host;

-(void)hostmask:(NSString *)host isBlocked:(BOOL)boolean;


-(void)clearData;

-(BOOL)getAuthForHostmask:(NSString *)hostmask;

@end
