---
layout: post

author: Luke Hackett
title:  "Leading by examples: using nested hamcrest matchers"
tags:
  - java
  - junit
  - hamcrest
---

I often refer to Marc Philipp's excellent [Hamcrest Quick Reference](https://www.marcphilipp.de/blog/2013/01/02/hamcrest-quick-reference/) guide when choosing which hamcrest matchers to use when writing my unit and integration tests.

I use nested [hamcrest](http://hamcrest.org/) matchers all the time, often without even releasing, so I thought I would put together some example uses of nested matchers.

<!--excerpt-->

The most obvious use for nested matchers is for asserting null values, but additional matchers can be used to make other test assertions easier to read. 

The example test methods shown below are equivalent test methods, but illustrate how the readability of each test differs.

```java
  @Test
  public void example1() {
    String message = "Hello World";

    assertThat(message, is(not(nullValue())));
    assertThat(message, is(equalToIgnoringCase("hello world")));
  }

  @Test
  public void example2() {
    String message = "Hello World";

    assertThat(message, is(notNullValue())));
    assertThat(message, equalToIgnoringCase("hello world"));
  }
```

Collections provide a number of opportunities for nesting hamcrest expressions. The example below shows a number of examples, such as ensuring the size of a list is at least of a certain value.

```java
  @Test
  public void example() {
    assertThat(names, hasSize(3));
    assertThat(names, hasSize(greaterThan(2)));
    assertThat(names, containsInAnyOrder("sally", "jeff", "andrew"));
    assertThat(names, not(containsInAnyOrder("steve", "daniel")));
}
```

As with Collections, Maps also provide opportunities for using nested hamcrest matchers. The example below, shows how you can nest matchers, even when the data structure itself is nested.

```java
  @Test
  public void example() {
    Map<String, List<String>> favouriteAnimals = new HashMap<>();
    favouriteAnimals.put("jeff", Arrays.asList("dog", "cat"));
    favouriteAnimals.put("sally", Arrays.asList("rabbit", "horse"));
    favouriteAnimals.put("andrew", Arrays.asList("tiger", "lion", "leopard"));

    assertThat(favouriteAnimals, hasEntry(equalTo("jeff"), containsInAnyOrder("dog", "cat")));
    assertThat(favouriteAnimals, hasKey(startsWith("and")));
  }
```

These examples will, hopefully, inspire you to write easy to read unit tests with hamcrest.
