Class {
	#name : #BreakpointGroup,
	#superclass : #Object,
	#instVars : [
		'name',
		'breakpoints'
	],
	#classVars : [
		'AllGroups'
	],
	#category : #'Reflectivity-Breakpoints'
}

{ #category : #accessing }
BreakpointGroup class >> all [

	^ AllGroups ifNil: [ AllGroups := OrderedCollection new ]
]

{ #category : #'class initialization' }
BreakpointGroup class >> initialize [

	self new name: 'All Breakpoints'.
	self new name: 'No Group'.
]

{ #category : #accessing }
BreakpointGroup >> addBreakpoint: aBreakpoint [
	breakpoints add: aBreakpoint
]

{ #category : #accessing }
BreakpointGroup >> breakpoints [ 
	^breakpoints
]

{ #category : #accessing }
BreakpointGroup >> initialize [ 
	AllGroups add: self.
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
BreakpointGroup >> removeBreakpoint: aBreakpoint [
	breakpoints remove: aBreakpoint
]
