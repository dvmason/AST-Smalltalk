Class {
	#name : #ASTNumber,
	#superclass : #ASTMagnitude,
	#category : #'ASTKernel-Numeric'
}

{ #category : #'as yet unclassified' }
ASTNumber class >> readFrom: stringOrStream [
	"Answer a number as described on aStream. The number may include a leading radix specification, as in 16rFADE."

	| value base aStream sign |
	aStream := stringOrStream class = ASTString
		ifTrue: [ ASTReadStream on: stringOrStream ]
		ifFalse: [ stringOrStream ].
	sign := (aStream peekFor: $-)
		ifTrue: [ -1 ]
		ifFalse: [ 1 ].
	base := 10.
	value := ASTInteger readFrom: aStream base: base.
	(aStream peekFor: $r)
		ifTrue: [ (base := value) < 2
				ifTrue: [ ^ self error: 'Invalid radix' ].
			(aStream peekFor: $-)
				ifTrue: [ sign := sign negated ].
			value := ASTInteger readFrom: aStream base: base ].
	"<base>r<integer>"
	^ self
		readRemainderOf: value
		from: aStream
		base: base
		withSign: sign
]

{ #category : #'as yet unclassified' }
ASTNumber class >> readFrom: stringOrStream base: base [
	"Answer a number as described on aStream in the given number base."

	| aStream sign |
	aStream := stringOrStream class = ASTString
		ifTrue: [ ASTReadStream on: stringOrStream ]
		ifFalse: [ stringOrStream ].
	sign := (aStream peekFor: $-)
		ifTrue: [ -1 ]
		ifFalse: [ 1 ].
	^ self
		readRemainderOf: (ASTInteger readFrom: aStream base: base)
		from: aStream
		base: base
		withSign: sign
]

{ #category : #'as yet unclassified' }
ASTNumber class >> readRemainderOf: integerPart from: aStream base: base withSign: sign [
	"Read optional fractional part and exponent, and return the final result"

	"MNumber readFrom: (ReadStream on: '3r-22.2')"

	| value fraction fracpos |
	value := integerPart.
	(aStream peekFor: $.)
		ifTrue: [ (aStream atEnd not
				and: [ aStream peek digitValue between: 0 and: base - 1 ])
				ifTrue: [ fracpos := aStream position.
					fraction := ASTInteger readFrom: aStream base: base.
					fraction := fraction asFloat
						/ (base raisedTo: aStream position - fracpos).
					value := value asFloat + fraction ]
				ifFalse: [ aStream skip: -1.	"un-gobble the period"
					^ value * sign ]
			"oops - just <integer>." ].
	"<integer>.<fraction>"
	(aStream peekFor: $e)
		ifTrue:
			[ value := value * (base raisedTo: (ASTInteger readFrom: aStream)) ].
	"<integer>e<exponent>"
	^ value * sign
]

{ #category : #'as yet unclassified' }
ASTNumber >> * aNumber [
	"Answer the result of multiplying the receiver by aNumber."

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
ASTNumber >> + aNumber [
	"Answer the sum of the receiver and aNumber."

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
ASTNumber >> - aNumber [
	"Answer the difference between the receiver and aNumber."

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
ASTNumber >> / aNumber [
	"Answer the result of dividing the receiver by aNumber."

	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
ASTNumber >> // aNumber [
	"Integer quotient defined by division with truncation toward negative 
	infinity. 9//4 = 2, -9//4 = -3. -0.9//0.4 = -3. \\ answers the remainder 
	from this division."

	^ (self / aNumber) floor
]

{ #category : #'as yet unclassified' }
ASTNumber >> \\ aNumber [
	"modulo. Remainder defined in terms of //. Answer a Number with the 
	same sign as aNumber. e.g. 9\\4 = 1, -9\\4 = 3, 9\\-4 = -3, 0.9\\0.4 = 0.1."

	^ self - (self // aNumber * aNumber)
]

{ #category : #'as yet unclassified' }
ASTNumber >> abs [
	"Answer a Number that is the absolute value (positive magnitude) of the 
	receiver."

	self < 0
		ifTrue: [ ^ self negated ]
		ifFalse: [ ^ self ]
]

{ #category : #'as yet unclassified' }
ASTNumber >> adaptToFloat: rcvr andSend: selector [
	"If I am involved in arithmetic with a Float, convert me to a Float."

	^ rcvr perform: selector with: self asFloat
]

{ #category : #'as yet unclassified' }
ASTNumber >> adaptToInteger: rcvr andSend: selector [
	"If I am involved in arithmetic with a Integer, convert us and evaluate exprBlock."

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
ASTNumber >> arcCos [
	"The receiver is the cosine of an angle. Answer the angle measured in 
	radians."

	^ self asFloat arcCos
]

{ #category : #'as yet unclassified' }
ASTNumber >> arcSin [
	"The receiver is the sine of an angle. Answer the angle measured in 
	radians."

	^ self asFloat arcSin
]

{ #category : #'as yet unclassified' }
ASTNumber >> arcTan [
	"The receiver is the tangent of an angle. Answer the angle measured in 
	radians."

	^ self asFloat arcTan
]

{ #category : #'as yet unclassified' }
ASTNumber >> asInteger [
	"Answer an Integer nearest the receiver toward zero."

	^ self truncated
]

{ #category : #'as yet unclassified' }
ASTNumber >> ceiling [
	"Answer the integer nearest the receiver toward positive infinity."

	self <= 0
		ifTrue: [ ^ self truncated ]
		ifFalse: [ ^ self negated floor negated ]
]

{ #category : #'as yet unclassified' }
ASTNumber >> cos [
	"The receiver represents an angle measured in radians. Answer its cosine."

	^ self asFloat cos
]

{ #category : #'as yet unclassified' }
ASTNumber >> degreesToRadians [
	"The receiver is assumed to represent degrees. Answer the conversion to 
	radians."

	^ self asFloat degreesToRadians
]

{ #category : #'as yet unclassified' }
ASTNumber >> exp [
	"Answer the exponential of the receiver as a floating point number."

	^ self asFloat exp
]

{ #category : #'as yet unclassified' }
ASTNumber >> floor [
	"Answer the integer nearest the receiver toward negative infinity."

	| truncation |
	truncation := self truncated.
	self >= 0
		ifTrue: [ ^ truncation ].
	self = truncation
		ifTrue: [ ^ truncation ]
		ifFalse: [ ^ truncation - 1 ]
]

{ #category : #'as yet unclassified' }
ASTNumber >> floorLog: radix [
	"Answer the floor of the log base radix of the receiver."

	^ self asFloat floorLog: radix
]

{ #category : #testing }
ASTNumber >> isNumber [
	^ true
]

{ #category : #'as yet unclassified' }
ASTNumber >> ln [
	"Answer the natural log of the receiver."

	^ self asFloat ln
]

{ #category : #'as yet unclassified' }
ASTNumber >> log [
	"Answer the base-10 log of the receiver."

	^ self asFloat log
]

{ #category : #'as yet unclassified' }
ASTNumber >> log: aNumber [
	"Answer the log base aNumber of the receiver."

	^ self ln / aNumber ln
]

{ #category : #'as yet unclassified' }
ASTNumber >> negated [
	"Answer a Number that is the negation of the receiver."

	^ 0 - self
]

{ #category : #'as yet unclassified' }
ASTNumber >> negative [
	"Answer whether the receiver is mathematically negative."

	^ self < 0
]

{ #category : #printing }
ASTNumber >> printOn: aStream [
	"Default print radix is 10"

	self printOn: aStream base: 10
]

{ #category : #'as yet unclassified' }
ASTNumber >> printStringBase: base [
	| stream |
	stream := ASTWriteStream on: (ASTString new: 100).
	self printOn: stream base: base.
	^ stream contents
]

{ #category : #'as yet unclassified' }
ASTNumber >> quo: aNumber [
	"Integer quotient defined by division with truncation toward zero. -9 quo: 
	4 = -2, -0.9 quo: 0.4 = -2. rem: answers the remainder from this division."

	^ (self / aNumber) truncated
]

{ #category : #'as yet unclassified' }
ASTNumber >> radiansToDegrees [
	"The receiver is assumed to represent radians. Answer the conversion to 
	degrees."

	^ self asFloat radiansToDegrees
]

{ #category : #'as yet unclassified' }
ASTNumber >> raisedTo: aNumber [
	"Answer the receiver raised to aNumber."

	aNumber isInteger
		ifTrue:
			[ ^ self raisedToInteger: aNumber ].
	"Do the special case of integer power"
	aNumber = 0
		ifTrue: [ ^ 1 ].	"Special case of exponent=0"
	aNumber = 1
		ifTrue: [ ^ self ].	"Special case of exponent=1"
	^ (aNumber * self ln) exp	"Otherwise raise it to the power using logarithms"
]

{ #category : #'as yet unclassified' }
ASTNumber >> raisedToInteger: anInteger [
	"Answer the receiver raised to the power anInteger where the argument 
	must be a kind of Integer. This is a special case of raisedTo:."

	anInteger isInteger
		ifFalse: [ ^ self error: 'raisedToInteger: only works for integral arguments' ].
	anInteger = 0
		ifTrue: [ ^ 1 ].
	anInteger = 1
		ifTrue: [ ^ self ].
	anInteger > 1
		ifTrue: [ ^ (self * self raisedToInteger: anInteger // 2)
				* (self raisedToInteger: anInteger \\ 2) ].
	^ (self raisedToInteger: anInteger negated) reciprocal
]

{ #category : #'as yet unclassified' }
ASTNumber >> reciprocal [
	"Answer 1 divided by the receiver. Create an error notification if the 
	receiver is 0."

	self = 0
		ifTrue: [ ^ self error: 'zero has no reciprocal' ]
		ifFalse: [ ^ 1 / self ]
]

{ #category : #'as yet unclassified' }
ASTNumber >> rem: aNumber [
	"Remainder defined in terms of quo:. Answer a Number with the same 
	sign as self. e.g. 9 rem: 4 = 1, -9 rem: 4 = -1. 0.9 rem: 0.4 = 0.1."

	^ self - ((self quo: aNumber) * aNumber)
]

{ #category : #'as yet unclassified' }
ASTNumber >> roundTo: aNumber [
	"Answer the integer that is a multiple of aNumber that is nearest the 
	receiver."

	^ (self / aNumber) rounded * aNumber
]

{ #category : #'as yet unclassified' }
ASTNumber >> roundUpTo: aNumber [
	"Answer the next multiple of aNumber toward infinity that is nearest the receiver."

	^ (self / aNumber) ceiling * aNumber
]

{ #category : #'as yet unclassified' }
ASTNumber >> rounded [
	"Answer the integer nearest the receiver."

	^ (self + (self sign / 2)) truncated
]

{ #category : #'as yet unclassified' }
ASTNumber >> sign [
	"Answer 1 if the receiver is greater than 0, -1 if less than 0, else 0."

	self > 0
		ifTrue: [ ^ 1 ].
	self < 0
		ifTrue: [ ^ -1 ].
	^ 0
]

{ #category : #'as yet unclassified' }
ASTNumber >> sin [
	"The receiver represents an angle measured in radians. Answer its sine."

	^ self asFloat sin
]

{ #category : #'as yet unclassified' }
ASTNumber >> sqrt [
	"Answer the square root of the receiver."

	^ self asFloat sqrt
]

{ #category : #'as yet unclassified' }
ASTNumber >> tan [
	"The receiver represents an angle measured in radians. Answer its 
	tangent."

	^ self asFloat tan
]

{ #category : #'as yet unclassified' }
ASTNumber >> to: stop [
	"Answer an Interval from the receiver up to the argument incrementing by 1."

	^ ASTInterval from: self to: stop by: 1
]

{ #category : #'as yet unclassified' }
ASTNumber >> to: stop by: step [
	"Answer an Interval from the receiver up to stop incrementing by step."

	^ ASTInterval from: self to: stop by: step
]

{ #category : #'as yet unclassified' }
ASTNumber >> to: stop by: step do: aBlock [
	"Normally compiled in-line, and therefore not overridable.
	Evaluate aBlock for each element of the interval (self to: stop by: step)."

	| nextValue |
	nextValue := self.
	step < 0
		ifTrue: [ [ stop <= nextValue ]
				whileTrue: [ aBlock value: nextValue.
					nextValue := nextValue + step ] ]
		ifFalse: [ [ stop >= nextValue ]
				whileTrue: [ aBlock value: nextValue.
					nextValue := nextValue + step ] ]
]

{ #category : #'as yet unclassified' }
ASTNumber >> to: stop do: aBlock [
	"Normally compiled in-line, and therefore not overridable.
	Evaluate aBlock for each element of the interval (self to: stop by: 1)."

	| nextValue |
	nextValue := self.
	[ nextValue <= stop ]
		whileTrue: [ aBlock value: nextValue.
			nextValue := nextValue + 1 ]
]

{ #category : #'as yet unclassified' }
ASTNumber >> truncateTo: aNumber [
	"Answer the next multiple of aNumber toward zero that is nearest the 
	receiver."

	^ (self quo: aNumber) * aNumber
]

{ #category : #'as yet unclassified' }
ASTNumber >> truncated [
	"Answer an integer nearest the receiver toward zero."

	^ self quo: 1
]
