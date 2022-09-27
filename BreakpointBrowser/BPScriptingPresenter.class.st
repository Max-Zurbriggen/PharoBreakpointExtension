Class {
	#name : #BPScriptingPresenter,
	#superclass : #BreakpointBrowserPresenter,
	#instVars : [
		'expandButton',
		'scriptList',
		'scriptCode',
		'buttonToolbar'
	],
	#category : #BreakpointBrowser
}

{ #category : #layout }
BPScriptingPresenter class >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: (SpBoxLayout newTopToBottom 
		add: super defaultLayout;
		add:#expandButton height: 25;
		yourself);
		"positionOfSlider: 365;"
		  "add: (SpBoxLayout newTopToBottom
				   add: #expandButton height: 25;
				   add: #buttonToolbar height: 50;
				   add: (SpPanedLayout newTopToBottom
						    add: #scriptList;
						    add: #scriptCode;
						    yourself);
				   yourself);"
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
	textInput := 'new script name'.
	textInput := UIManager default 
		request: 'Enter new name for this script:'
		initialAnswer: textInput
		title: 'Enter new script name'.
	textInput isEmptyOrNil ifFalse: [ aScript name: textInput ].
	
	"| textInput |
	textInput := SpRequestTextDialog new.
	textInput 
	title: 'Enter script name';
	extent: 300 @ 160;
	text: aScript name;
	acceptLabel: 'Accept';
	label: 'enter new name for this script';
	onAccept: [aScript name: (textInput text)];
	openModal."
]

{ #category : #actions }
BPScriptingPresenter >> collapseAction [

	^[	self layout remove: self layout presenters last. 
		expandButton action: self expandAction.
		expandButton label: '▼ Expand Breakpoint Script UI ▼'.
		self window resize: (self window window extent)-(0@400) ]
]

{ #category : #initialization }
BPScriptingPresenter >> connectPresenters [ 
	scriptList whenSelectionChangedDo: [ :bps | scriptList selectedItem ifNotNil:[ scriptCode  text: bps selectedItem code] ].
	"scriptList transmitTo: scriptCode transform: [ :bps | bps ifNotNil: [bps code] ]."
]

{ #category : #ui }
BPScriptingPresenter >> createScriptPresenterLayout [

	^ self class new
		layout: (SpBoxLayout newTopToBottom
				   add: #buttonToolbar height: 50;
				   add: (SpPanedLayout newTopToBottom
						add: #scriptList;
						add: #scriptCode;
						yourself);
					yourself);
			yourself.

]

{ #category : #actions }
BPScriptingPresenter >> deleteScript [
 
	scriptList selectedItem ifNotNil: [ 
		scriptList selectedItem delete.
		scriptList updateList ]
]

{ #category : #actions }
BPScriptingPresenter >> expandAction [

	^[ self layout add: self createScriptPresenterLayout. 
		expandButton action: self collapseAction.
		expandButton label: '▲ Collapse Breakpoint Script UI ▲'.
		self window resize: (self window window extent)+(0@400) ]
]

{ #category : #initialization }
BPScriptingPresenter >> initializeExpandButton [
			
	expandButton := self newButton
	label: '▼ Expand Breakpoint Script UI ▼'.
	expandButton action: self expandAction .
	

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
		initialExtent: 800@400
]

{ #category : #'instance creation' }
BPScriptingPresenter >> newScript [
	BreakpointScript new.
	scriptList refresh.
]

{ #category : #actions }
BPScriptingPresenter >> runScript [
	scriptList selectedItem ifNotNil: [ 
		scriptList selectedItem run.
		breakpointsTable refresh.
	 ]
]

{ #category : #actions }
BPScriptingPresenter >> saveScript [
	scriptList selectedItem ifNotNil: [ scriptList selectedItem code: (scriptCode text) ].
	
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
