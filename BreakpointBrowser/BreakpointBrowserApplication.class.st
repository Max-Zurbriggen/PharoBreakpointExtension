Class {
	#name : #BreakpointBrowserApplication,
	#superclass : #SpApplication,
	#category : #BreakpointBrowser
}

{ #category : #specs }
BreakpointBrowserApplication >> start [

	^ (self new: BreakpointBrowserPresenter) open
]
