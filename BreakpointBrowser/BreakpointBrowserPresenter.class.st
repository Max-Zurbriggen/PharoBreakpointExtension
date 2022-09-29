"
I am a Breakpoint Browser to manage breakpoints more easily.
"
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

	^ 	SpPanedLayout newTopToBottom
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 17 percent;
				   add: #bpGroupsList;
				   add: #breakpointsTable;
				   yourself);
		  add: #methodCode;
		  yourself
]

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
	"set the items of the breakpoints table to match the selected group"
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
BreakpointBrowserPresenter >> initializeBreakpointTable [
	"creates a table of breakpoints with some of their properties"

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
				evaluated: [ :item | item group]) 
				width: 100; 
				yourself);
		contextMenu: self breakpointContextMenu.
		
	breakpointsTable whenSelectionChangedDo: [ :selection | self updateMethodSourceCode: selection selectedItem ].
]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializeGroups [
	"initializes the breakpoint groups list"
	bpGroupsList := self newList
		headerTitle: 'Breakpoint Groups';
		whenSelectionChangedDo: [ :selection | 
			self updateBreakpointGroups.
			self buildTableData: selection selectedItem "breakpointsTable refresh." ];
		yourself
]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializePresenters [
	self initializeGroups.
	self initializeBreakpointTable.
	
	self updateBreakpointGroups.
		
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
	"updates the list of breakpoint groups and adds 'All' as an option"
	| groups |

	groups := (Breakpoint all collect: [ :bp | bp group ]) removeDuplicates.
	groups addFirst: 'All'.
	bpGroupsList items: groups.
	bpGroupsList selectIndex: 1.
	


]

{ #category : #updating }
BreakpointBrowserPresenter >> updateMethodSourceCode: aBreakpoint [
	"updates the code window to display the code where the breakpoint is attached"
	
	"methodCode text: aBreakpoint printContentsForBreakpointInspection"
	
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
	
	
	



]
