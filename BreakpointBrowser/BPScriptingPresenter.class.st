Class {
	#name : #BPScriptingPresenter,
	#superclass : #BreakpointBrowserPresenter,
	#instVars : [
		'completeScriptLayout',
		'expandButton',
		'scriptList',
		'scriptCode',
		'buttonToolbar'
	],
	#category : #BreakpointBrowser
}

{ #category : #layout }
BPScriptingPresenter class >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  add: super defaultLayout;
		  add: (SpBoxLayout newTopToBottom
				   add: #expandButton height: 25;
				   add: #buttonToolbar height: 50;
				   add: (SpPanedLayout newTopToBottom
						    add: #scriptList;
						    add: #scriptCode;
						    yourself);
				   yourself);
		  yourself
]

{ #category : #'world menu' }
BPScriptingPresenter class >> menuCommandOn: aBuilder [

	<worldMenu>
	(aBuilder item: #'My Breakpoint Browser2')
		parent: #Debug;
		action: [ self new open ];
		order: -2;
		help:
			'My Breakpoint Browser';
		icon: (self iconNamed: #glamorousBug).
	aBuilder withSeparatorAfter
]

{ #category : #'ui - dialogs' }
BPScriptingPresenter >> changeScriptName: aScript [
	| textInput |
	textInput := SpRequestTextDialog new.
	textInput 
	title: 'Enter script name';
	extent: 300 @ 160;
	text: aScript name;
	acceptLabel: 'Accept';
	label: 'enter new name for this script';
	onAccept: [aScript name: (textInput text)];
	openModal.
]

{ #category : #initialization }
BPScriptingPresenter >> connectPresenters [ 

	scriptList transmitTo: scriptCode transform: [ :bps | bps code ].
]

{ #category : #ui }
BPScriptingPresenter >> createScriptPresenterLayout [

	| scriptLayout |
	scriptLayout := self newBoxLayoutTopToBottom .
	scriptLayout 
			add: #buttonToolbar height: 50;
			add: (SpPanedLayout  newTopToBottom
			add: #scriptList;
			add: #scriptCode;
			yourself).
			
			
	^ scriptLayout 
]

{ #category : #actions }
BPScriptingPresenter >> deleteScript [
	scriptList selectedItem delete.
	scriptList refresh.
]

{ #category : #initialization }
BPScriptingPresenter >> initializeExpandButton [
			
	expandButton := self newButton
	label: 'expand';
	action: [ self layout add: self createScriptPresenterLayout].
]

{ #category : #initialization }
BPScriptingPresenter >> initializePresenters [ 

	super initializePresenters .
	
	self initializeExpandButton.
	
	self initializeToolbar.
	self initializeScriptList.
	self initializeScriptCode .
	

]

{ #category : #initialization }
BPScriptingPresenter >> initializeScriptCode [

	scriptCode := self newCode
		whenTextChangedDo: [ self saveScript ];
		yourself.
]

{ #category : #initialization }
BPScriptingPresenter >> initializeScriptList [ 

	scriptList := self newList		
		headerTitle: 'Scripts';
		items: (BreakpointScript all );
		display: [ :bps | bps name ];
		contextMenu: self scriptContextMenu;
		yourself.
]

{ #category : #initialization }
BPScriptingPresenter >> initializeToolbar [ 

	buttonToolbar := self newToolbar
		addItem: (SpToolbarButtonPresenter new
			label: 'Do it';
			icon: (self iconNamed: #smallDoIt);
			help: 'run the selected script';
			action: [ self runScript ];
			yourself);
		"addItem: (SpToolbarButtonPresenter new
			label: 'Save';
			icon: (self iconNamed: #smallSave);
			help: 'save script content';
			action: [ self saveScript ];
			yourself);"
		addItem: (SpToolbarButtonPresenter new
			label: 'New';
			icon: (self iconNamed: #smallNew);
			help: 'create a new script';
			action: [ self newScript ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Delete';
			icon: (self iconNamed: #smallDelete);
			help: 'delete the selected script';
			action: [ self deleteScript ];
			yourself);

		yourself.
]

{ #category : #initialization }
BPScriptingPresenter >> initializeWindow: aWindowPresenter [
	
	aWindowPresenter
		title: 'Breakpoint Browser';		
		windowIcon: (self application iconNamed: #glamorousBug);
		initialExtent: 800@800
]

{ #category : #'instance creation' }
BPScriptingPresenter >> newScript [
	BreakpointScript new.
	scriptList refresh.
]

{ #category : #actions }
BPScriptingPresenter >> runScript [
	scriptList selectedItem run.
	breakpointsTable refresh.
]

{ #category : #actions }
BPScriptingPresenter >> saveScript [
	scriptList selectedItem ifNil: [ ^self ].
	scriptList selectedItem code: (scriptCode text).
]

{ #category : #ui }
BPScriptingPresenter >> scriptContextMenu [

	^ self newMenu addGroup: [ :aGroup | 
		  aGroup addItem: [ :anItem | 
			  anItem
				  name: 'rename';
				  description: 'Opens a window to change the name of this script';
				  action: [ 
					  self changeScriptName: scriptList selectedItem.
					  scriptList refresh ] ] ] 
]
