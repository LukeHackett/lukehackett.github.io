---
layout: post

author: Luke Hackett
title: Elasticity vs Scalability
tags:
  - aws
  - elasticity
  - scalability
---

Elasticity and Scalability are two fundamental concepts when designing cloud native applications, however they can be difficult to define. 

<!--excerpt-->

Fundamentally, the two concepts can be boiled down to the definitions.

*Scalability is the ability of a system to accommodate larger loads.* This can be achieved by either horizontally scaling out (adding more nodes) or vertically scaling up (larger hardware profiles).

*Elasticity is the ability scale in (and scale out) infrastructure dynamically based upon current application loads.* This can be a likened to an elastic band, whereby the elastic band can be stretched, and return back to its original size at any point, for any amount of time.

Elasticity is a crucial concept in cloud-native application designs, due to most cloud providers, such as [AWS](https://aws.amazon.com), operating upon a pay-per-use model. Elasticity can often provide a win-win situation, as it allows you to pay for resources you currently need, whilst maintaining the ability to ensure that you can meet rising demand when required.
