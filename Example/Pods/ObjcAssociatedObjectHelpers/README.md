[![Master Status](https://travis-ci.org/itsthejb/ObjcAssociatedObjectHelpers.png?branch=master)](https://travis-ci.org/itsthejb/ObjcAssociatedObjectHelpers)
[![Develop Status](https://travis-ci.org/itsthejb/ObjcAssociatedObjectHelpers.png?branch=develop)](https://travis-ci.org/itsthejb/ObjcAssociatedObjectHelpers)
[![Pod Status](https://img.shields.io/cocoapods/v/ObjcAssociatedObjectHelpers.svg)](http://www.cocoapods.org/?q=ObjcAssociatedObjectHelpers)
[![Pod License](https://img.shields.io/cocoapods/l/ObjcAssociatedObjectHelpers.svg)](http://www.cocoapods.org/?q=ObjcAssociatedObjectHelpers)
[![Pod Platform](https://img.shields.io/cocoapods/p/ObjcAssociatedObjectHelpers.svg)](http://www.cocoapods.org/?q=ObjcAssociatedObjectHelpers)

ObjcAssociatedObjectHelpers
===========================

Introduction
------------

[Associated Objects, or Associated References](http://developer.apple.com/library/ios/#documentation/cocoa/conceptual/objectivec/Chapters/ocAssociativeReferences.html) were introduced in OS X 10.6 and iOS 4.0. This feature gives class instances a dictionary of sorts within which to store arbitrary objects using the runtime functions `objc_setAssociatedObject()` and `objc_getAssociatedObject()`. This project aims to make their use more convenient in a light-weight and thoroughly tested fashion.

1. **Adding ivars to categories** - An unfortunate drawback of Obj-C categories in the inability to add or synthesize ivars, even though properties can be added. Associated objects can be used to provide storage and overcome this limitation:
		
		@interface NSObject (MyCategory)
		@property (strong) id myCategoryObject;
		@end
		
		@implementation NSObject (MyCategory)
		SYNTHESIZE_ASC_OBJ(myCategoryObject, setMyCategoryObject);
		@end
	
2. **Arbitrary dictionary for NSObject** - The `NSObject` category adds a lazily-initialized `NSMutableDictionary` to `NSObject`, allowing key-value pairs to be more conveniently associated with any `NSObject` subclass instance:

		[self.associatedDictionary setValue:@"value" forKey:@"myKey"];

Notes
-----
1. **getter / setter names** - There is no way to manipulate strings in the preprocessor so that standard getter and setter names can easily be generated from a single token. As such, the read/write macros require both names to be provided manually.
2. **Memory Management** - Works identically under ARC and manually reference counted code.
3. **Property memory management semantics** - Since properties use associated objects for storage, any property setter semantics can be used:

		@property () id myProperty;		
		@property (strong) id myProperty;
		@property (retain) id myProperty;
		@property (assign) id myProperty;
		@property (copy) id myProperty;

    Currently, the macros check at runtime for `NSCopying` protocol compliance and use `OBJC_ASSOCIATION_COPY` if found and `OBJC_ASSOCIATION_RETAIN` otherwise. The test `-[UnitTests testMutableObject]` confirms that a copy is made. I think this is The Right Way™. It's probably best to use normal semantics with these setters, however.
    
4. As of version `2.0.0` weak properties are supported, and behave in the same way as regular `weak` properties.

Usage
-----
Static library provided for the `NSObject` category, or just use the header file for basic usage. Prefered installation by using [CocoaPods](http://cocoapods.org/).

	pod 'ObjcAssociatedObjectHelpers'

Testing
-------
Thorough test cases provided with near 100% coverage.

		
Macros
------
1. `SYNTHESIZE_ASC_OBJ(getterName, setterName)` - The most basic usage. Synthesize a getter and setter for a read/write object property. If you would like to generate a read-only property with a private or protected setter then you can define this in another category:

		@interface MyClass : NSObject
		@property (readonly) id readWriteObject;
		@end
		
		@interface MyClass (PrivateOrProtectedOrAnonymous)
		@property (readwrite) id readWriteObject;
		@end
		
		@implementaton MyClass
		
		- (id) init {
			if ((self = [super init])) {
				self.readWriteObject = @"foo";
			}
			return self;
		}

2. `SYNTHESIZE_ASC_PRIMITIVE(getterName, setterName, type)` - Synthesize for any kind of primitive object. Any type supported by the `@encode()` operator is supported. So that *should* be everything…?
3. `SYNTHESIZE_ASC_OBJ_LAZY(getterName, class)` - Synthesize a read-only object that in initialized lazily. The object's class must be provided so that an object can be initialized (with `alloc/init`) on first access.
4. `SYNTHESIZE_ASC_OBJ_LAZY_EXP(getterName, initExpression)` - Synthesize a read-only object that in initialized lazily, with the provided initialiser Expression. For example;

		SYNTHESIZE_ASC_OBJ_LAZY_EXP(nonDefaultLazyObject, [NSString stringWithFormat:@"foo"])	 
	Uses the expression `[NSString stringWithFormat:@"foo"]` to initialise the object. Note that `SYNTHESIZE_ASC_OBJ_LAZY` uses this macro with `[[class alloc] init]`.
5. All the macros have a `_BLOCK` suffix companion which (to borrow generic programming syntax) takes a block of type `T (^block)(T value)` for the getter, and setter (if available). This allows additional code to be run in the accessors, similar to overriding an accessor. The value passed to the accessor will be the argument. This value can be returned, or a modified value can also be returned. This replaces the syntax used until `v1.2.1`, and I think is clearer. For example:

		SYNTHESIZE_ASC_PRIMITIVE_BLOCK(myProperty,
		                               setMyProperty,
		                               CGSize,
		                               ^(CGSize s){ return CGSizeZero; },
		                               ^(CGSize s){ s.width = 10; return s; })

	Defines a read/write property of type `CGSize`, and overrides the getter and setter to always set `CGSizeZero`, and always get a size with a width of 10.

If you like this, you might also like...
----------------------------------------

* **libextobjc** - The excellent [libextobjc](https://github.com/jspahrsummers/libextobjc) library also has a similar single macro implementation of this concept. However primitives are not supported, as well as the wider range of features provided here. However, for its other features, please check it out ;)
* [FTGPropertyMaestro](https://github.com/onmyway133/FTGPropertyMaestro) is a runtime-based implementation with the same goal.
* [Mattt Thompson has written an article on the subject of associated objects](http://nshipster.com/associated-objects/). He seems to find them a little controversial. Be your own judge.

What's New
----------
 
**v2.0.1** 
 
 * Made ARC a requirement in the podspec, since this is necessary to use the `weak` functionality with Cocoapods.

**v2.0.0**

* New format for the block accessor macros. Values are passed directly and must be returned. This is a breaking change.
* New feature for `weak` properties, using the wrapper method suggested [here](http://nshipster.com/new-years-2015/).
* The `NSObject` category is now prefixed and split into a subspec for Cocoapods. 

**v1.2.1**

* ARC no longer a requirement (it never really was).
* A bit of spring cleaning.

**v1.2.0**

* Now sends KVO notifications for all macros. Oversight on previous releases.

**v1.1.2**

* Improved block macro value handling. See details below.

**v1.1.1**

* Moved the execution order of setter blocks so the block can potential operate on the existing value. In the context of the block, `self.property` will be the existing value, *before* the new value is set.

**v1.1**

* Pass a block to the macros in order to modify setter values or getter return values in some way, as well as other custom code.

**v1.0**

* Static library target for iOS, and framework target for OS X.
* [MIT Licensed](http://jc.mit-license.org/)


Have fun!
---------

[MIT Licensed](http://jc.mit-license.org/) >> [joncrooke@gmail.com](mailto:joncrooke@gmail.com)
		
