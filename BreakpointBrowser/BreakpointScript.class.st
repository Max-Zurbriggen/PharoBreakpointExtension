"
I am a script (code) used in the BPScriptingPresenter where I can be managed and run.
"
Class {
	#name : #BreakpointScript,
	#superclass : #Object,
	#instVars : [
		'name',
		'code'
	],
	#classVars : [
		'AllBreakpointScripts'
	],
	#category : #BreakpointBrowser
}

{ #category : #accessing }
BreakpointScript class >> all [
	^ AllBreakpointScripts ifNil: [ AllBreakpointScripts  := OrderedCollection new ]
]

{ #category : #accessing }
BreakpointScript >> code [
	^code
]

{ #category : #accessing }
BreakpointScript >> code: aString [
	^code:= aString
]

{ #category : #initialization }
BreakpointScript >> delete [ 
	AllBreakpointScripts remove: self.
]

{ #category : #initialization }
BreakpointScript >> initialize [ 
	self code: ''.
	self name: 'unnamed script'.
	AllBreakpointScripts add: self.
]

{ #category : #accessing }
BreakpointScript >> name [
	^name
]

{ #category : #accessing }
BreakpointScript >> name: aString [
	^name := aString
]

{ #category : #accessing }
BreakpointScript >> run [
	Behavior evaluate: code.
	
	
	

	
]
