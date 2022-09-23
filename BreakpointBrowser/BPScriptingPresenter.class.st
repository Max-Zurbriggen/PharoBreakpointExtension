Class {
	#name : #BPScriptingPresenter,
	#superclass : #BreakpointBrowserPresenter,
	#instVars : [
		'scriptList',
		'scriptCode',
		'buttonToolbar',
		'scriptNameField'
	],
	#category : #BreakpointBrowser
}

{ #category : #layout }
BPScriptingPresenter class >> defaultLayout [ 
	^ SpPanedLayout newTopToBottom
		add: super defaultLayout ;  
		add: (SpBoxLayout newTopToBottom 
			add: (SpPanedLayout newHorizontal 
				add: #buttonToolbar ;
				add: (SpBoxLayout new add: #scriptNameField height: 25;yourself);
				yourself) height: 50;
			add: (SpPanedLayout  newTopToBottom
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

{ #category : #initialization }
BPScriptingPresenter >> connectPresenters [ 
	scriptList transmitTo: scriptCode transform: [ :bps | bps code ].
	scriptList transmitTo: scriptNameField transform: [ :bps | bps name ].
]

{ #category : #actions }
BPScriptingPresenter >> deleteScript [
	scriptList selectedItem delete.
	self updateScriptList.
]

{ #category : #initialization }
BPScriptingPresenter >> initializePresenters [ 

	super initializePresenters .
	self initializeScriptList.
	self initializeScriptCode .
	
	buttonToolbar := self newToolbar
		addItem: (SpToolbarButtonPresenter new
			label: 'New';
			icon: (self iconNamed: #smallOk);
			help: 'create a new script';
			action: [ self newScript ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Save';
			icon: (self iconNamed: #smallOk);
			help: 'save script content';
			action: [ self saveScript ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Delete';
			icon: (self iconNamed: #smallCancel);
			help: 'delete the selected script';
			action: [ self deleteScript ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Run';
			icon: (self iconNamed: #smallDoIt);
			help: 'delete the selected script';
			action: [ self runScript ];
			yourself);
		yourself.
		
	scriptNameField := self newTextInput.
]

{ #category : #initialization }
BPScriptingPresenter >> initializeScriptCode [

	scriptCode := self newCode
]

{ #category : #initialization }
BPScriptingPresenter >> initializeScriptList [ 

	scriptList := self newList		
		headerTitle: 'Scripts';
		items: (BreakpointScript all );
		display: [ :bps | bps name ];
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
	self updateScriptList.
]

{ #category : #actions }
BPScriptingPresenter >> runScript [
	scriptList selectedItem run.
	breakpointsTable refresh.
]

{ #category : #actions }
BPScriptingPresenter >> saveScript [
	scriptList selectedItem code: (scriptCode text).
	scriptList selectedItem name: (scriptNameField text).
	self updateScriptList.
]

{ #category : #initialization }
BPScriptingPresenter >> updateScriptList [ 

	scriptList refresh.

]
