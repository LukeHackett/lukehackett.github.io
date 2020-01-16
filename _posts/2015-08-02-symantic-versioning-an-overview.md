---
layout: post

author: Luke Hackett
title:  "Semantic Versioning: An Overview"
tags:
  - Semantic Versioning
---

Semantic Versioning is a software versioning system that has been 
gaining popularity in recent years. With the rapid growth in software 
development through libraries, applications and web services having a 
standardised way of versioning software releases has never been as 
important.    

<!--excerpt-->

## What is Semantic Versioning?

Semantic Versioning is a relatively straightforward concept that 
contains three important pieces of versioning information. It follows 
the format of **MAJOR.MINOR.PATCH**. Semantic Versioning relies on correctly "bumping" a component (major, 
minor or patch) up at the right time. It is the bumping of a component 
that ensures releasing is simple.

### Major

A major bump is performed when non-backwards compatible changes to the 
application's public API occurs. The change(s) implemented are likely 
to break the existing API, and hence all downstream clients may endure 
some pain when upgrading to the latest version.

### Minor

A minor bump is performed when (new) functionality is added in a 
backwards-compatible manner. This means that downstream clients should 
be able to upgrade to the latest version without causing any headaches 
for the downstream clients.

### Patch

A patch bump is performed when you make backwards-compatible bug fixes.
As with a minor bump, this will not affect downstream clients (unless 
they are incorrectly using the bug).


## Why use Semantic Versioning?

Utilising Semantic Versioning makes sense. The main reason for this is 
that at any point developers know whether or not they are using the 
latest version of a library. 

More importantly it allows them to deduce how difficult it would be to 
upgrade to the latest version of the library. For example upgrading to 
the latest patch version is a simpler task than upgrading to the latest
major version.

It is Semantic Versioning's strict guidelines in versioning software 
that generates information from the version numbers. 

For example Software X currently has a version of 8.51.123. From this 
information alone, we know that it's the 8th major release. There have 
been 51 minor bumps, and 123 patches since that major release. In this 
example 123 patches, could mean that there were many undiscovered bugs 
and hence patches were required to fix them!


## Things to keep in mind

There are a few gotchas to keep in mind when using Semantic Versioning.
I've outlined some of the most common ones below.

### Where to start

Many people start a project at version 0.0.1, which doesn't really make
sense, because you can't (or shouldn't) be starting a new project with
a patch. Ideally you should start your project with a set of features,
hence a minor release with version 0.1.0. 

### Pre-1.0.0

You first production release should be 1.0.0, which means that anything
below this value is probably part of the development rush - i.e. not 
production ready. It is during the development rush that your focus is 
primarily concerned with getting your software developed. Breaking 
things can be forgiven, and you’ll work to ensure that when 1.0.0 is 
reached, it’s stable.

### Pre-releases

Before deploying a major version, I like to perform various End-to-End 
integration tasks that ensure that everything is working as expected. 
It's generally at this point that I would create a pre-release.

Semantic Versioning supports pre-releases, and can be achieved by 
appending a hyphen and an identifier to an existing version. For 
example a pre-release of 1.0.0 would be 1.0.0-rc1, and if another build
is need you could use 1.0.0-rc2 and so on.

### When to release 1.0.0

An important question to ask when building a new piece of software is 
"When should I release the first official major version?"

I generally stick to the following rules:

1. If your software is already being used in production then you 
   should already be at 1.0.0.
2. If your software has users depending upon it, then you should 
   already be at 1.0.0.
3. If you worried about breaking existing functionality then you should
   already be at 1.0.0.

### Handling deprecating functionality

Deprecating functionality is all part and parcel of software 
development. Deprecating part of a public API should ideally follow 
these steps:

1. Update all documentation to ensure downstream users are aware of the 
   deprecation.
2. Issue a minor release with the deprecation in place.
3. Remove the functionality as part of a new major release, ensuring 
   there is at least one minor release that contains the deprecation so
   users can smoothly transition to the new API.


## Final Thoughts

Semantic Versioning is a strict but sensible way of versioning releases.
It is becoming more and more popular, and there really is no legitimate
excuse not to use it on your next (or current) project.

Standardisation is key in our industry, and if we can standardise the 
way in which software is released, it will make our jobs that little 
bit easier.

For more information checkout the official [Semantic Versioning guidelines][semver].


[semver]: http://semver.org/