Class {
	#name : #BreakpointBrowserPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'bpGroupsList',
		'methodCode',
		'breakpointsTable'
	],
	#category : #BreakpointBrowser
}

{ #category : #layout }
BreakpointBrowserPresenter class >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 30 percent;
				   add: #bpGroupsList;
				   add: #breakpointsTable;
				   yourself);
		  add: #methodCode;
		  yourself
]

{ #category : #specs }
BreakpointBrowserPresenter class >> menuCommandOn: aBuilder [

	<worldMenu>
	(aBuilder item: #'My Breakpoint Browser')
		parent: #Debug;
		action: [ self new open ];
		order: -2;
		help:
			'My Breakpoint Browser';
		icon: (self iconNamed: #glamorousBug).
	aBuilder withSeparatorAfter
]

{ #category : #initialization }
BreakpointBrowserPresenter >> breakpointContextMenu [
	^ self newMenu
		addGroup: [ :aGroup | 
			aGroup
				addItem: [ :anItem | 
					anItem
						name: 'Change group';
						description: 'Opens a window to change the group of this breakpoint';
						action: [ 
							self changeBreakpointGroup: (breakpointsTable selectedItem ).  
							self updateBreakpointGroups.
							breakpointsTable refresh.] ];
				addItem: [ :anItem | 
					anItem
						name: 'Remove';
						description: 'Remove this breakpoint';
						action: [ breakpointsTable selectedItem remove. 
							self updateBreakpointGroups.
							breakpointsTable refresh. ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Enable';
						description: 'Enable this breakpoint';
						visibleIf: [ breakpointsTable selectedItem isEnabled not];
						action: [ breakpointsTable selectedItem enable. breakpointsTable refresh. ] ];
				addItem: [ :anItem | 
					anItem
						name: 'Disable';
						description: 'Disable this breakpoint';
						visibleIf: [ breakpointsTable selectedItem isEnabled ];
						action: [ breakpointsTable selectedItem disable. breakpointsTable refresh. ] ].
			]
]

{ #category : #presenters }
BreakpointBrowserPresenter >> buildTableData: group [
	group = 'All' 
		ifTrue: [ ^breakpointsTable items: Breakpoint all. ]
		ifFalse: [ ^breakpointsTable items: (Breakpoint all select: [ :bp | bp group = group ] ). ]
]

{ #category : #'ui - dialogs' }
BreakpointBrowserPresenter >> changeBreakpointGroup: aBreakpoint [
	"popup to change the group of a breakpoint"
	
	| textInput |
	textInput := aBreakpoint group.
	textInput := UIManager default 
		request: 'Enter new name for this script:'
		initialAnswer: textInput
		title: 'Enter group name'.
	textInput isEmptyOrNil ifFalse: [ aBreakpoint group: textInput ].


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

{ #category : #private }
BreakpointBrowserPresenter >> getBreakpointClass: aBreakpoint [
	
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
	^ aBreakpoint printTargetForBreakpointInspection.

]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializeBreakpointTable [
	"List of methods in which a breakpoint is installed"

	breakpointsTable := self newTable.
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
			(SpStringTableColumn
				title: 'Group'
				evaluated: [ :item | item group]);
		contextMenu: self breakpointContextMenu;
		whenSelectionChangedDo: [ :selection | self updateMethodSourceCode: selection selectedItem ].
]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializeGroups [
	bpGroupsList := self newList
		headerTitle: 'Breakpoint Groups';
		whenSelectionChangedDo: [ :selection | self updateBreakpointGroups. self buildTableData: selection selectedItem. "breakpointsTable refresh."];
		yourself.

]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializePresenters [
	self initializeGroups.
	self initializeBreakpointTable.
	
	
	self updateBreakpointGroups.
	"bpGroupsList selectIndex: 1."
	
		
	methodCode := self newCode 
		beNotEditable
		yourself.
		
	
	SystemAnnouncer uniqueInstance weak when: BreakpointAdded send: #updateBreakpointGroups to: self.
	SystemAnnouncer uniqueInstance weak when: BreakpointRemoved send: #updateBreakpointGroups to: self.
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
	| groups |

	groups := (Breakpoint all collect: [ :bp | bp group ]) removeDuplicates.
	groups addFirst: 'All'.
	bpGroupsList items: groups.
	bpGroupsList selectIndex: 1.
	


]

{ #category : #updating }
BreakpointBrowserPresenter >> updateMethodSourceCode: aBreakpoint [
	aBreakpoint ifNil:  [^self].
	methodCode text: aBreakpoint printContentsForBreakpointInspection
	


]
