Extension { #name : #Boolean }

{ #category : #'*ASTSmalltalk' }
Boolean >> astImageObject: anASImage [ 
	^ anASImage literal: self asBit*2+3 class: 2+self asBit
]

{ #category : #'*ASTSmalltalk' }
Boolean >> astObject: anASImage [ 
	^ self
]
