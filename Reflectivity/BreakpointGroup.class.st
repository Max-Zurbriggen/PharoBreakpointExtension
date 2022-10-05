Class {
	#name : #BreakpointGroup,
	#superclass : #Object,
	#instVars : [
		'name',
		'breakpoints'
	],
	#classVars : [
		'AllBreakpointsGroup',
		'AllGroups',
		'UngroupedBreakpointsGroup'
	],
	#category : #'Reflectivity-Breakpoints'
}

{ #category : #accessing }
BreakpointGroup class >> all [

	^ AllGroups ifNil: [ AllGroups := OrderedCollection new ]
]

{ #category : #'as yet unclassified' }
BreakpointGroup class >> allBreakpointsGroup [
	^ AllBreakpointsGroup
]

{ #category : #'as yet unclassified' }
BreakpointGroup class >> cleanUpAll [
	AllGroups do: [ :group | group breakpoints do: [ :bp | group removeBreakpoint: bp ] ].
	Breakpoint copy all do: [ :bp | bp remove ].
	AllGroups copy do: [ :group | group remove ].
	self initialize.
]

{ #category : #'class initialization' }
BreakpointGroup class >> initialize [

	
	AllBreakpointsGroup := self new name: 'All Breakpoints'.
	UngroupedBreakpointsGroup := self new name: 'No Group'.
]

{ #category : #'instance creation' }
BreakpointGroup class >> newBreakpoint: aBreakpoint [.
	AllBreakpointsGroup addBreakpoint: aBreakpoint.
	UngroupedBreakpointsGroup addBreakpoint: aBreakpoint.
]

{ #category : #'as yet unclassified' }
BreakpointGroup class >> ungroupedBreakpointsGroup [
	^ UngroupedBreakpointsGroup
]

{ #category : #accessing }
BreakpointGroup >> addBreakpoint: aBreakpoint [
	self breakpoints add: aBreakpoint
]

{ #category : #accessing }
BreakpointGroup >> breakpoints [ 
	^breakpoints ifNil: [ breakpoints := OrderedCollection new]
]

{ #category : #accessing }
BreakpointGroup >> initialize [ 
	AllGroups add: self.
	^self.
]

{ #category : #accessing }
BreakpointGroup >> name [
	^name
]

{ #category : #accessing }
BreakpointGroup >> name: aString [
	name := aString
]

{ #category : #accessing }
BreakpointGroup >> remove [
	AllGroups remove: self.
	breakpoints copy do: [ :bp | bp group: self class ungroupedBreakpointsGroup  ]
]

{ #category : #accessing }
BreakpointGroup >> removeBreakpoint: aBreakpoint [
	self breakpoints remove: aBreakpoint ifAbsent: [].
]
