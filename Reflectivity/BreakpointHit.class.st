Class {
	#name : #BreakpointHit,
	#superclass : #BreakpointAnnouncement,
	#instVars : [
		'valueOrNil'
	],
	#category : #'Reflectivity-Breakpoints'
}

{ #category : #accessing }
BreakpointHit >> valueOrNil [
	^ valueOrNil
]

{ #category : #accessing }
BreakpointHit >> valueOrNil: anObject [
	valueOrNil := anObject
]
