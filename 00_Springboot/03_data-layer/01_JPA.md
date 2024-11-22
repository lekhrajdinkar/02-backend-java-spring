- Reference
  - all topics: https://www.baeldung.com/learn-jpa-hibernate
  - inheritance : https://www.baeldung.com/hibernate-inheritance
---
# JPA
## A Intro
- JPA Specification --> **ORM** layer (focus)
- interact with a **relational** database without any SQL.
- eg: Hibernate framework
- first/Second level Cache.
- **Entity**
  - lifecycle state : New/Transient > managed > detached > removed/Deleted(markedForDelete).
  - Transient - POJO which has no representation in the PC.
- **relationships** 
- **inheritance** 
- (**EntityManager** / EntityManagerFactory) or  (**Session** / sessionFactory in Hibernate)
  - heap(object) <==> **PC**(managed entity) <==> Database
  - provide API to interact with PC. more on PC [02_presistence-context.md](02_presistence-context.md)
    - session.persist : mark for save
    - session.merge : move to pc
    - session.refresh : sync with DB
    - session.remove : marked for delete
    - session.detach : remove from pc
    - session.flush
- key components/bean to build for develop:
  - **SessionFactory**
    - heavy, Created at startup in SB project
    - rename bean : @Bean(name = "entityManagerFactory") LocalSessionFactoryBean m(){...}
  - **TransactionManager** 
    - `PlatformTransactionManager` --impl--> HibernateTransactionManager, JpaTransactionManager
  - **Datasource** 
    - database connections pool
    - eg: hikari, javax.sql.DataSource, etc
    - use DataSourceBuilder
---
## B JPA Entity - Lifecycle Events
- create **MyListener.class**
- add method/s and annotate with :
  - @PrePersist m(), @PostPersist m(),
  - @PreRemove m(), @PostRemove m(),
  - @PreUpdate m(), @PostUpdate m(),
  - @PostLoad m()
- go to @Entity MyEntity
  - annotate entity class with `@EntityListeners`(**MyListener.class**) 
- fact : 
  - @GeneratedValue - expect key to available in @PostPersist.
---
## C Relationship
- owner owns the foreign key and defines @JoinColumn(name="newName")
- uni-directional or bi-directional : both has references of each other.

### `1-2-1`
- any class can be owner
- other class : mapperBy=propertyName mentioned in owner-class.

### `C1:1-2-M and C2:M-2-1(owner : many side)`
- C1:mapperBy=propertyName mentioned in owner-class
- more anno:
  - `@fetch(FetchMode.SELECT/JOIN/SUBSELECT)` + @OneToMany(fetch = **FetchType.LAZY/EAGER**)
  - `@order` + `@BatchSize` + @OneToMany
  - **@fetch()** :
    - defines `how` the associated entities are fetched from the database. meaning `SQS queries`.
    - from Hibernate :point_left:
    - @Fetch(FetchMode.SELECT/JOIN/SUBSELECT)
      - **SELECT**: Specifies that associated entities should be fetched lazily, using a separate SELECT statement.
      - **JOIN**: Specifies that associated entities should be fetched eagerly using a single JOIN query.
      - **SUBSELECT**: Specifies that associated entities should be fetched lazily using a single SELECT query with a subselect.
      
### `C1:M-2-M and C2:M-2-M`
- no one is owner.
- create @JoinTable.
- use this to filter data : `@WhereJoinTable` 
- can check: https://www.baeldung.com/hibernate-wherejointable
- use @order, @BatchSize, @fetch here as well
```
    @WhereJoinTable(clause = "col of join table" = "value-1")   <<<
    
    @ManyToMany
    @JoinTable(
      name = "student_course",
      joinColumns = @JoinColumn(name = "student_id"),
      inverseJoinColumns = @JoinColumn(name = "course_id")
    )
```
- **Cascade operation** in relationship : ALL ,PERSIST, MERGE, REMOVE, REFRESH, DETACH
  - https://www.baeldung.com/jpa-cascade-types
  - @OneToMany( Cascade operation )
---
## D Inheritance
- let's have : `parent-Entity (2 col,2 record) / Child-1-Entity(2 col, 2 record), child-2-Entity (2 col, 2 record)`
- Strategies:
  1. `Single table` (6 col) : for all 3 entities with `discrminator` column / lots of null /
  2. `table per class` :
     - parent class table - 2 col
     - Child-1/2 class table - 4 col
  3. `Joined` :
     - meaning Joined subclass. child joined to parent
     - Like table per class, but child table will have only prop defined in entity, not from parent.
       - parent class table - 2 col
       - Child-1/2 class table - 2 col + FK to parent table.
  4. `MappedSuperclass` – the parent classes, can’t be entities.

- **Polymorphic queries**. 
  - https://chatgpt.com/c/1375c062-4b67-437d-860b-e065a2980f57
  - implicit : query for parent-entity, automatically includes ALL child records --> 6 records.
  - explicit : use **Treat**, to change this behaviour.

```
List<Vehicle> vehicles = session.createQuery("FROM Vehicle", Vehicle.class).getResultList();
// Implicit polymorphism: vehicles list will contain instances of both Car and Bike

List<Car> cars = session.createQuery("FROM Car", Car.class).getResultList();
// Explicit polymorphism: cars list will contain only instances of Car

List<Vehicle> vehicles = session.createQuery("FROM Vehicle v WHERE TREAT(v AS Car).numberOfDoors > 3", Vehicle.class) .getResultList();  <<<
```