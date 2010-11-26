//
//  HostmaskData.h
//  IRCBot
//
//  Created by Ben K on 2010/09/16.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>


@interface HostmaskData : NSObject {

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

	
-(void)addHostmask:(NSString *)host block:(BOOL)block;

-(IBAction)addNewHostmask:(id)sender;
-(IBAction)removeSelectedHostmask:(id)sender;
-(void)clearData;
-(void)reloadData;


@end
