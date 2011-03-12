//
//  KBLuaActionsData.h
//  IRCBot
//
//  Created by Ben K on 2010/10/10.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "KBLuaAction.h"

@interface KBLuaActionsData : NSObject {

	int actionIndex;
	NSMutableArray *actionsArray;
	
	IBOutlet NSTableView *actionsView;
	IBOutlet NSPathControl *actionPath;
	IBOutlet NSTextField *actionName;
	IBOutlet NSTextField *sheetErrorMessage;
	IBOutlet NSButton *restrictAction;
	IBOutlet BWSheetController *addActionPane;
	IBOutlet NSButton *removeActionButton;
}

@property (nonatomic,assign) NSMutableArray *actionsArray;

- (void)loadActionsFromFile:(NSString *)file;
- (void)saveActionsToFile:(NSString *)file;

-(void)addAction:(NSString *)action name:(NSString *)name restricted:(BOOL)boolean;

-(IBAction)addNewAction:(id)sender;
-(IBAction)removeSelectedAction:(id)sender;

@end
