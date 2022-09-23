Class {
	#name : #BreakpointBrowserPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'breakpointGroups',
		'selectedGroup',
		'selectedMethod',
		'breakpointsTable'
	],
	#category : #BreakpointBrowser
}

{ #category : #layout }
BreakpointBrowserPresenter class >> defaultLayout [

	^ SpPanedLayout newTopToBottom
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 30 percent;
				   add: #breakpointGroups;
				   add: #breakpointsTable;
				   yourself);
		  add: #selectedMethod;
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

{ #category : #presenters }
BreakpointBrowserPresenter >> buildTableData: group [
	group = 'All' 
		ifTrue: [ breakpointsTable items: Breakpoint all. ]
		ifFalse: [ breakpointsTable items: (Breakpoint all select: [ :bp | bp group = group ] ). ]
]

{ #category : #initialization }
BreakpointBrowserPresenter >> getAllBreakpointGroups [

	| groups |

	groups := (Breakpoint all collect: [ :bp | bp group ]) removeDuplicates.
	groups addFirst: 'All'.
	^ groups
]

{ #category : #'as yet unclassified' }
BreakpointBrowserPresenter >> getBreakpointClass: aBreakpoint [
	
	^ aBreakpoint isObjectCentric
		ifTrue: [ aBreakpoint targetInstance ]
		ifFalse: [ 
			aBreakpoint isVariableBreakpoint 
			ifTrue: [ aBreakpoint targetClassOrMethod ] 
			ifFalse: [ aBreakpoint node methodNode methodClass ]
			 ].

]

{ #category : #'as yet unclassified' }
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

		whenSelectionChangedDo: [ :selection | self updateMethodSourceCode: selection selectedItem ].
]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializeGroups [
	breakpointGroups := self newList
		headerTitle: 'Breakpoint Groups';
		items: (self getAllBreakpointGroups);
		whenSelectionChangedDo: [ :selection | self buildTableData: selection selectedItem.  ];
		yourself.

]

{ #category : #initialization }
BreakpointBrowserPresenter >> initializePresenters [
	self initializeGroups.
	self getAllBreakpointGroups.
	self initializeBreakpointTable.

				
	selectedMethod := self newCode 
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

{ #category : #'as yet unclassified' }
BreakpointBrowserPresenter >> updateMethodSourceCode: aBreakpoint [
	aBreakpoint ifNil:  [^self].
	selectedMethod text: aBreakpoint printContentsForBreakpointInspection
	


]
