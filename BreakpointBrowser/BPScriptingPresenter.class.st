"
I am an extention of the Breakpoint Browser. I include a UI for managing scripts.
"
Class {
	#name : #BPScriptingPresenter,
	#superclass : #BreakpointBrowserPresenter,
	#instVars : [
		'scriptList',
		'scriptCode',
		'buttonToolbar'
	],
	#category : #BreakpointBrowser
}

{ #category : #layout }
BPScriptingPresenter class >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  add: (SpBoxLayout newTopToBottom 
		add: super defaultLayout;
		yourself);
		add: (SpBoxLayout newTopToBottom
				   add: #buttonToolbar height: 50;
				   add: (SpPanedLayout newTopToBottom
						add: #scriptList;
						add: #scriptCode;
						yourself);
					yourself);
		  yourself
]

{ #category : #specs }
BPScriptingPresenter class >> menuCommandOn: aBuilder [

	<worldMenu>
	(aBuilder item: #'Breakpoint Browser with Script UI')
		parent: #Debug;
		action: [ self new open ];
		order: -2;
		help:
			'for more information contact max.zurbriggen@uzh.ch';
		icon: (self iconNamed: #glamorousBug).
	aBuilder withSeparatorAfter
]

{ #category : #'ui - dialogs' }
BPScriptingPresenter >> changeScriptName: aScript [
	"opens a popup to enter a new script name"
	| textInput |
	textInput := 'new script name'.
	textInput := UIManager default 
		request: 'Enter new name for this script:'
		initialAnswer: textInput
		title: 'Enter new script name'.
	textInput isEmptyOrNil ifFalse: [ aScript name: textInput ].
	
	"alternative popup:"
	
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

{ #category : #initialization }
BPScriptingPresenter >> connectPresenters [ 
	"updates the code window with the code of the selected script"
	scriptList whenSelectionChangedDo: [ :bps | 
		scriptList selectedItem ifNotNil:[ 
			scriptCode text: bps selectedItem code
			] 
		].
	"scriptList transmitTo: scriptCode transform: [ :bps | bps ifNotNil: [bps code] ]."
]

{ #category : #actions }
BPScriptingPresenter >> deleteScript [
	"deletes the selected script"
	scriptList selectedItem ifNotNil: [ 
		scriptList selectedItem delete.
		scriptList updateList ]
]

{ #category : #initialization }
BPScriptingPresenter >> initializePresenters [ 

	super initializePresenters .
	
	
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
	"creates a new script"
	BreakpointScript new.
	scriptList refresh.
]

{ #category : #actions }
BPScriptingPresenter >> runScript [
	"runs the selected script"
	scriptList selectedItem ifNotNil: [ 
		scriptList selectedItem run.
		breakpointsTable refresh.
	 ]
]

{ #category : #actions }
BPScriptingPresenter >> saveScript [
	"saves the code to the selected script"
	scriptList selectedItem ifNotNil: [ scriptList selectedItem code: (scriptCode text) ].
	
]

{ #category : #ui }
BPScriptingPresenter >> scriptContextMenu [
	"context menu for for the script list"
	^ self newMenu addGroup: [ :aGroup | 
		  aGroup addItem: [ :anItem | 
			  anItem
				  name: 'rename';
				  description: 'Opens a window to change the name of this script';
				  action: [ 
					  self changeScriptName: scriptList selectedItem.
					  scriptList refresh ] ] ] 
]
