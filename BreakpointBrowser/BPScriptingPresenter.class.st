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
	textInput := self application newRequestText
		label: 'Enter new name for this script:';
		text: textInput;
		title: 'Enter new script name';
		openModal.
	textInput isEmptyOrNil ifFalse: [ aScript name: textInput ].
	
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

{ #category : #layout }
BPScriptingPresenter >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  add: (SpBoxLayout newTopToBottom 
		add: super defaultLayout;
		yourself);
		add: (SpBoxLayout newTopToBottom
				   add: buttonToolbar height: 50;
				   add: (SpPanedLayout newTopToBottom
						add: scriptList;
						add: scriptCode;
						yourself);
					yourself);
		  yourself
]

{ #category : #actions }
BPScriptingPresenter >> doDeleteScript [
	"deletes the selected script"
	scriptList selectedItem ifNotNil: [ 
		scriptList selectedItem delete.
		scriptList updateList ]
]

{ #category : #actions }
BPScriptingPresenter >> doNewScript [
	"creates a new script"
	BreakpointScript new.
	scriptList refresh.
]

{ #category : #actions }
BPScriptingPresenter >> doRunScript [
	"runs the selected script"
	scriptList selectedItem ifNotNil: [ 
		scriptList selectedItem run.
		breakpointsTable refresh.
	 ]
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
		beForScripting;
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
			action: [ self doRunScript ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'New';
			icon: (self iconNamed: #smallNew);
			help: 'create a new script';
			action: [ self doNewScript ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Delete';
			icon: (self iconNamed: #smallDelete);
			help: 'delete the selected script';
			action: [ self doDeleteScript ];
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
