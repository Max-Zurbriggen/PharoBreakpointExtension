"
A BreakpointTest is a test class for testing the behavior of Breakpoint
"
Class {
	#name : #BreakpointTest,
	#superclass : #TestCase,
	#instVars : [
		'previousBreakpoints',
		'cls',
		'oldSystemAnnouncer'
	],
	#category : #'Reflectivity-Tools-Tests'
}

{ #category : #tests }
BreakpointTest >> testAddGroup [
	|bp group|	
	bp := Breakpoint new.
	group := 'test'.
	bp group: group.
	
	self assert: (bp properties includesKey: #Group).
	self assert: (bp property: #Group) identicalTo: group.

]

{ #category : #tests }
BreakpointTest >> testAddGroupAPI [
	|bp group|	
	bp := Breakpoint new.
	group := 'test'.
	bp groupTo: group.
	
	self assert: (bp properties includesKey: #Group).
	self assert: (bp property: #Group) identicalTo: group.

]

{ #category : #tests }
BreakpointTest >> testAddProperty [
	|bp property|	
	bp := Breakpoint new.
	property := #PropertyName.
	bp property: property put: 'test'.
	
	self assert: (bp properties includesKey: property).
	self assert: (bp property: property) identicalTo: 'test'.

]

{ #category : #tests }
BreakpointTest >> testNoGroup [
	|bp |	
	bp := Breakpoint new.
	
	self assert: bp group equals: 'no group'.
	


]

{ #category : #tests }
BreakpointTest >> testProperties [
	|bp dictionary|	
	bp := Breakpoint new.
	bp property: #P1 put: 'test'.
	bp property: #P2 put: 'test2'.
	dictionary := Dictionary new.
	dictionary at: #Group put: 'no group'.
	dictionary at: #P1 put: 'test'.
	dictionary at: #P2 put: 'test2'.
	
	self assert: (bp properties) equals: dictionary.


]

{ #category : #tests }
BreakpointTest >> testRemoveProperty [
	|bp property|	
	bp := Breakpoint new.
	property := #PropertyName.
	bp property: property put: 'test'.
	
	self assert: (bp properties includesKey: property).
	
	bp removeProperty: property.

	self assert: (bp properties includesKey: property) equals: false.
]
