"
I am a Breakpoint Browser to manage breakpoints more easily.
"
Class {
	#name : #BreakpointBrowserPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'bpGroupsList',
		'groupsButtonToolbar',
		'methodCode',
		'breakpointsTable'
	],
	#category : #BreakpointBrowser
}

{ #category : #specs }
BreakpointBrowserPresenter class >> menuCommandOn: aBuilder [

	<worldMenu>
	(aBuilder item: #'Breakpoint Browser')
		parent: #Debug;
		action: [ self new open ];
		order: -3;
		help:
			'for more information contact max.zurbriggen@uzh.ch';
		icon: (self iconNamed: #glamorousBug).
]

{ #category : #initialization }
BreakpointBrowserPresenter >> breakpointContextMenu [
	"context menu for changing groups, removing, enabling/disabling breakpoints"
	^ self newMenu
		addGroup: [ :aGroup | 
			aGroup
				addItem: [ :anItem | 	anItem
					name: 'edit breakpoint';
					description: 'Opens a window to edit this breakpoint';
					action: [ 
						BreakpointEditor new open; selectBreakpoint: (breakpointsTable selectedItem) ] ];
"				addItem: [ :anItem | 
					anItem
						name: 'Change group';
						description: 'Opens a window to change the group of this breakpoint';
						action: [ 
							self changeBreakpointGroup: (breakpointsTable selectedItem ).  
							self updateBreakpointGroups.
							breakpointsTable refresh.] ];"
				addItem: [ :anItem | anItem
					name: 'Remove';
					description: 'Remove this breakpoint';
					action: [ breakpointsTable selectedItem remove. 
						self updateBreakpointGroups.
						breakpointsTable refresh. ] ];
				addItem: [ :anItem | anItem
					name: 'Enable';
					description: 'Enable this breakpoint';
					enabled: [ breakpointsTable selectedItem isEnabled not];
					action: [ 
						breakpointsTable selectedItem enabled: true. 
						breakpointsTable refresh. ] ];
				addItem: [ :anItem | anItem
					name: 'Disable';
					description: 'Disable this breakpoint';
					enabled: [ breakpointsTable selectedItem isEnabled ];
					action: [ 
						breakpointsTable selectedItem enabled: false. 
						breakpointsTable refresh. ] ].
			]
]

{ #category : #private }
BreakpointBrowserPresenter >> buildTableData: group [
	"set the items of the breakpoints table to match the selected group"

	group ifNil: [ ^ BreakpointGroup allBreakpointsGroup breakpoints ].
	breakpointsTable items: group breakpoints.
	
]

{ #category : #'ui - dialogs' }
BreakpointBrowserPresenter >> changeBreakpointGroup: aBreakpoint [
	"popup to change the group of a breakpoint"
	"to be removed"
	
	| textInput |
	textInput := aBreakpoint group.
	textInput := self application newRequestText 
		request: 'Enter new group for this breakpoint:';
		text: textInput;
		title: 'Enter group name'.
	textInput isEmptyOrNil ifFalse: [ aBreakpoint group: textInput ].
	
	"| textInput |
	textInput := aBreakpoint group.
	textInput := UIManager default 
		request: 'Enter new name for this script:'
		initialAnswer: textInput
		title: 'Enter group name'.
	textInput isEmptyOrNil ifFalse: [ aBreakpoint group: textInput ]."

	"alternative popup:"

	"| textInput |
	textInput := SpRequestTextDialog new.
	textInput 
	title: 'Enter group name';
	extent: 300 @ 160;
	text: aBreakpoint group;
	acceptLabel: 'Accept';
	label: 'enter new group name for this breakpoint';
	onAccept: [aBreakpoint group: (textInput text)];
	openModal."
]

{ #category : #layout }
BreakpointBrowserPresenter >> defaultLayout [

	^ 	SpPanedLayout newTopToBottom
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 17 percent;
				   add: (SpBoxLayout newTopToBottom 
						add: bpGroupsList;
						add: groupsButtonToolbar; "here should the interface be to edit groups somehow"
						yourself );
				   add: breakpointsTable;
				   yourself);
		  add: methodCode;
		  yourself
]

{ #category : #initialization }
BreakpointBrowserPresenter >> doDeleteGroup [

	bpGroupsList selection selectedItem remove.
	bpGroupsList refresh.
	breakpointsTable refresh.
]

{ #category : #initialization }
BreakpointBrowserPresenter >> doNewGroup [

	| textInput |
	textInput := self application newRequestText 
		label: 'Enter name of a new breakpoint group:';
		text: '';
		title: 'Enter new group name';
		validateAnswer: [ :answer | answer isEmptyOrNil not ];
		openModal.
	textInput isEmptyOrNil ifFalse: [ BreakpointGroup new name: textInput ].
	bpGroupsList refresh.

	
]

{ #category : #private }
BreakpointBrowserPresenter >> getBreakpointClass: aBreakpoint [
	"returns the class where a breakpoint is attached"
	^ aBreakpoint isObjectCentric
		ifTrue: [ aBreakpoint targetInstance ]
		ifFalse: [ 
			aBreakpoint isVariableBreakpoint 
			ifTrue: [ aBreakpoint targetClassOrMethod ] 
			ifFalse: [ aBreakpoint node methodNode methodClass ]
			 ].

]

{ #category : #private }
BreakpointBrowserPresenter >> getBreakpointTarget: aBreakpoint [
	"returns the target of a breakpoint"
	^ aBreakpoint printTargetForBreakpointInspection.

]

{ #category : #initialization }
BreakpointBrowserPresenter >> initialize [

	super initialize.
	SystemAnnouncer uniqueInstance weak when: BreakpointAdded send: #updateBreakpointGroups to: self.
	SystemAnnouncer uniqueInstance weak when: BreakpointRemoved send: #updateBreakpointGroups to: self.
		
	

		

]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializeBreakpointTable [
	"creates a table of breakpoints with some of their properties"

	breakpointsTable := self newTable.
	breakpointsTable dragEnabled: true.
	breakpointsTable 
		addColumn:
			((SpCheckBoxTableColumn
				title: ' '
				evaluated: [ :item | item isEnabled ])
				onActivation: [ :item | item enable ];
				onDeactivation: [ :item | item disable ];
				width: 20;
				yourself);
		addColumn:
			((SpStringTableColumn
				title: 'Type'
				evaluated: [ :item | item class ])
				width: 110;
				yourself);
		addColumn:
			((SpStringTableColumn
				title: 'Class'
				evaluated: [ :item | self getBreakpointClass: item])
				yourself);
		addColumn:
			(SpStringTableColumn
				title: 'Target'
				evaluated: [ :item | self getBreakpointTarget: item]);
		addColumn:
			((SpStringTableColumn
				title: 'Group'
				evaluated: [ :item | item group name]) 
				width: 100; 
				yourself);
		contextMenu: self breakpointContextMenu.
		
	breakpointsTable whenSelectionChangedDo: [ :selection | self updateMethodSourceCode: selection selectedItem ].
]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializeGroupButtonToolbar [

	groupsButtonToolbar := self newToolbar
		addItem: (SpToolbarButtonPresenter new
			label: 'New';
			icon: (self iconNamed: #smallNew);
			help: 'create a new script';
			action: [ self doNewGroup ];
			yourself);
		addItem: (SpToolbarButtonPresenter new
			label: 'Delete';
			icon: (self iconNamed: #smallDelete);
			help: 'delete the selected script';
			action: [ self doDeleteGroup ];
			
			yourself);

		yourself.
]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializeGroups [
	"initializes the breakpoint groups list"
	bpGroupsList := self newList
		headerTitle: 'Breakpoint Groups';
		display: [ :bpg | bpg name ];
		whenSelectionChangedDo: [ :selection | 
			self updateBreakpointGroups.
			self buildTableData: selection selectedItem "breakpointsTable refresh." ];
		yourself.
	bpGroupsList dropEnabled: true.
	bpGroupsList wantsDrop: [ :s | ((s passenger at:1) isKindOf: Breakpoint) and: (s index ~= 1) ].
	bpGroupsList acceptDrop: [ :s | 
		(s passenger at:1) group: (BreakpointGroup all at:(s index)). 
		bpGroupsList refresh.
		breakpointsTable refresh.]
		
]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializePresenters [
	self initializeGroups.
	self initializeBreakpointTable.
	self initializeGroupButtonToolbar.
	self updateBreakpointGroups.

	methodCode := self newCode 
		beNotEditable
		yourself.
		
		
	

]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializeWindow: aWindowPresenter [
	
	aWindowPresenter
		title: 'Breakpoint Browser';		
		windowIcon: (self application iconNamed: #glamorousBug);
		initialExtent: 800@400
]

{ #category : #updating }
BreakpointBrowserPresenter >> updateBreakpointGroups [
	"updates the list of breakpoint groups"
	
	bpGroupsList items: BreakpointGroup all.
	bpGroupsList selectIndex: 1.
]

{ #category : #updating }
BreakpointBrowserPresenter >> updateMethodSourceCode: aBreakpoint [
	"updates the code window to display the code where the breakpoint is attached"
	
	aBreakpoint ifNil:  [^self].
	
	aBreakpoint isVariableBreakpoint 
		ifTrue: [ 
			methodCode text: ( (((SortedCollection sortBlock: [ :a :b | 
				a methodClass name < b methodClass name ])
				addAll: (aBreakpoint targetMethodsToNodesMap ) keys;
				yourself) at:1) sourceCode).
			methodCode beForBehavior: aBreakpoint targetClassOrMethod ]
		ifFalse: [ 
			methodCode text: aBreakpoint node methodNode method sourceCode.
			methodCode beForBehavior:	aBreakpoint node methodNode method ]
	
	
	"estebans code (to be implemented):"
"	 aBreakpoint ifNil:  [^self].
    
    methodCode 
        beForMethod: aBreakpoint node compiledMethod;
        text: aBreakpoint printContentsForBreakpointInspection;
        addTextSegmentDecoration:  (SpTextPresenterDecorator forHighlight
            interval: (1 to: 10);
            yourself)"
	
	



]
