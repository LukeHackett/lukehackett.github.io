---
layout: post

author: Luke Hackett
title:  "Optimising hibernate queries with tuples"
tags:
  - java
  - jpa
  - hibernate
  - sql
  - performance
---

The Java Persistence API (JPA) is a wonderful way of bridging the gap between SQL databases and object-oriented programming. 

My preferred implementation of choice is Hibernate, but often Hibernate will generate long and complex SQL statements, that can cause slow queries to occur quickly. Developers will often "solve" this problem by writing native SQL statements, but it turns out that there is an alternative approach.

<!--excerpt-->

I have many pet peeves when it comes to developing software, and one of them is writing native SQL queries. Writing native queries can lead to simple formatting errors, security vulnerabilities, as well as making the application dependent upon a particular database type, or version.

```java
Query query = entityManager.createNativeQuery("SELECT * FROM Users");
List results = query.getResultList();
```

JPA removes most of the complexity, by providing the `CriteriaBuilder` class that gives us the ability the build SQL queries, without having to write an SQL query, for example:

```java
CriteriaBuilder builder = entityManager.getCriteriaBuilder();
CriteriaQuery<User> query = builder.createQuery(User.class);

Root<User> root = query.from(User.class);
query.select(root);

return entityManager.createQuery(query).getResultList();
```

While for most JPA/Hibernate users, this is a pretty standard piece of code - it will return all users. However, imagine as part of obtaining all User objects, it would require multiple `JOINS` to be performed as part of the query. Furthermore, imagine if you only needed to obtain some values, and thus the many (if not all of the) of the `JOINS` are not required. 

I often see developers write native queries, to get around this problem, for example:

```java
Query query = entityManager.createNativeQuery("SELECT id, username, email FROM Users");
List results = query.getResultList();
```

This is not an ideal solution! What if we rename the username field, or completely remove it? Of course, our tests would fail, but wouldn't it be better to have:

1. Compile-time safely of fields
2. Well formatted queries
3. Ability to support multiple database types (for example h2 for dev & test, and mysql for production)

Unfortunately, hibernate doesn't support selecting specific fields of an object natively, but it can be achieved when using tuple queries in combination with the [Hibernate Metamodel Generator](https://hibernate.org/orm/tooling/) library.

The [Hibernate Metamodel Generator](https://hibernate.org/orm/tooling/) library is an annotation processor automating, the generation of the static metamodel classes needed for type safe Criteria queries as defined by JPA 2. If you are using a spring boot, then you'll need to add the `hibernate-jpamodelgen` dependency, and the spring-boot-maven plugin will automatically setup the annotation processor as part of the maven build lifecycle.


```xml
<dependency>
  <groupId>org.hibernate</groupId>
  <artifactId>hibernate-jpamodelgen</artifactId>
  <scope>provided</scope>
</dependency>
```

Rewriting the previous native SQL using a TupleQuery and the [Hibernate Metamodel Generator](https://hibernate.org/orm/tooling/) yields this:

```java
public List<User> getUsers() {
  CriteriaBuilder builder = entityManager.getCriteriaBuilder();
  CriteriaQuery<Tuple> query = builder.createTupleQuery();
  Root<User> root = query.from(User.class);

  query.multiselect(
    root.get(User_.id),
    root.get(User_.username),
    root.get(User_.email)
  );
  
  List<Tuple> results = entityManager.createQuery(query).getResultList();
  
  // convert Tuple results into List of Users
}
```

The [Hibernate Metamodel Generator](https://hibernate.org/orm/tooling/) library will generate classes (post fixed with a underscore) based upon  `@Entity` annotated model classes. These generated classes will contain static variables that references the table field names. 

This solution is a good start, as allows for the field names to be defined in one location (`@Entity` annotated model classes), and thus if they are updated then a compilation error will be thrown. It also has allowed us to query the fields we are interested in, rather than querying the entire table (and child tables).

The only problem is that the `getResultList()` returns a `List<Tuple>` rather than a `List<User>`. We would want to be dealing with `User` objects in our application code, rather than `Tuple` objects.

We can solve this, by creating a mapping function, that is able to map a list of `Tuple` objects into the model object of choice - in this case a `User` object. The `mapTupleResultsToEntity()` is a wrapper around a generic parent method - `mapTupleListToEntityList()` - that is able to map a `Tuple` (or multiple `Tuple` records) into a concrete model object.

```java
private List<User> mapTupleResultsToEntity(final List<Tuple> results, final Root<User> root) {
  // User supplier
  Supplier<User> supplier = User::new;

  // User identifier function
  Function<Tuple, Long> identifier = (tuple) -> tuple.get(root.get(User_.id));

  // Tuple to User mapping function
  BiFunction<User> mapper = (tuple, user) -> {
    user.setId(tuple.get(root.get(User_.id)));
    user.setUsername(tuple.get(root.get(User_.username)));
    user.setEmail(tuple.get(root.get(User_.email)));
    
    return user;
  };
  
  return mapTupleListToEntityList(results, supplier, identifier, mapper);
}

private <X> List<X> mapTupleListToEntityList(List<Tuple> results, Supplier<X> supplier, Function<Tuple, Long> identity, BiFunction<Tuple, X, X> mapper) {
  // List of entities returned from the database
  Map<Long, X> entities = new LinkedHashMap<>();

  for (Tuple tuple : results) {
    // Obtain the entity if seen already or create a new entity
    X entity = entities.getOrDefault(identity.apply(tuple), supplier.get());
    entity.setId(identity.apply(tuple));

    // Apply the mapper function and put it back into the LinkedHashMap of entities
    entities.put(identity.apply(tuple), mapper.apply(tuple, entity));
  }

  return new ArrayList<>(entities.values());
}
```

We can modify the original `getUsers()`  method to make use of the `mapTupleResultsToEntity()`, method provided above.

```java
public List<User> getUsers() {
  CriteriaBuilder builder = entityManager.getCriteriaBuilder();
  CriteriaQuery<Tuple> query = builder.createTupleQuery();
  Root<User> root = query.from(User.class);

  query.multiselect(
    root.get(User_.id),
    root.get(User_.username),
    root.get(User_.email)
  );
  
  List<Tuple> results = entityManager.createQuery(query).getResultList();
  return mapTupleResultsToEntity(results, root);
}
```

Voila! While I agree that this solution requires more code, and maintenance of a mapper function, it does allow for the continual use of JPA/Hibernate to generate queries, and thus supports multiple database types, as well as providing compile-time safety when referencing fields. 

