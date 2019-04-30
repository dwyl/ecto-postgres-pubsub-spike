# Ecto Postgres PubSub Spike

## Why

Have you ever wondered about a possible feature to add to an application you are
working on but...
  - you didn't know quite how it might work
  - you weren't sure if it would be more efficient than the current solution
  - you didn't have a good enough understanding of the feature to plan or
  estimate it

This is where a spike comes in.

## What

In agile software development, a spike is a story that cannot be estimated until
a development team runs a time-boxed investigation. The aim of a spike is to be
able to gain a better understanding of the problem/issue so that you will be
able to estimate the original story.

## How

To create a spike you first need a problem that you are trying to solve.

In this example we will be showing steps that could be taken when doing a spike
to solve the following story...

<!-- Please feel free to reword this. -->
> "Keep track of all the changes made to a record in order to be able to track
it's progressions over time"

If you're like me you may not have come across a problem like this before and
may not know what a good solution to this problem is, let alone how long it will
take for you to complete it.

This is where spikes come in. They give you a chance to get better acquainted
with the problem you need to solve. You can look at different technologies,
languages, approaches to solving the issue and even try to write a version of
to code that you think you will end up needing. As stated above, the goal is not
to have a fully completed feature by the end of your spike, but to be able to
estimate the original issue/story and capture your thoughts/learning during the
process.

In order for us to solve the problem outlined above we want some way of keeping
track of history of a record.

Imagine we have a simple table, `animals`, with fields `name`, `species`...

| id | name      | species |
| -- | --------- | ------- |
| 1  | Meowth    | Cat     |
| 2  | Dogbert   | Dog     |
| 3  | Toothless | Dragon  |
| 4  | Gary      | Snail   |

Now let's say that a user wants to change the name of their cat. In a typical
[CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) style when
this happens it will update the `animals` table like so...

| id | name      | species |
| -- | --------- | ------- |
| 1  | Persian   | Cat     |
| 2  | Dogbert   | Dog     |
| 3  | Toothless | Dragon  |
| 4  | Gary      | Snail   |

This is fine in a lot of cases but for us it is no good as we have lost the
previous name forever.

In order to solve this issue you might come up with the idea of creating a
history version of the `animals` table. This table could be used to keep track
of all the changes to a record.

Our history table will need to be very very similar to the original table but
with one key difference. It will need some way of relating to the `id` of the
original item. We could do this by creating an extra column called `ref_id`
which will contain the `id` of the animal that has been updated.

Let's go back to before the user updated their cat's name _(something that we
couldn't do in reality without some form of history)_, but this time let us look
at from the history table point of view.
Let's say that we have created a history table called `animals_history` which
might look something like...

| id | ref_id | name      | species |
| -- | ------ | --------- | ------- |
| 1  | 1      | Meowth    | Cat     |
| 2  | 2      | Dogbert   | Dog     |
| 3  | 3      | Toothless | Dragon  |
| 4  | 4      | Gary      | Snail   |

Now when the user updates the name the original table update will happen as
shown above, however we will also update the `animals_history` table like so...

| id | ref_id | name      | species |
| -- | ------ | --------- | ------- |
| 1  | 1      | Meowth    | Cat     |
| 2  | 2      | Dogbert   | Dog     |
| 3  | 3      | Toothless | Dragon  |
| 4  | 4      | Gary      | Snail   |
| 5  | 1      | Persian   | Cat     |

As you can see, instead of updating the record in the `animals_history` table,
we inserted a new row which still references the `id` from original `animals`
table.

Now, if we ever need to see all the amendments made to `animals id 1`, we will
be able to run a query to get all of the records from the history table.

`select * from animals_history where ref_id = 1;`

| id | ref_id | name      | species |
| -- | ------ | --------- | ------- |
| 1  | 1      | Meowth    | Cat     |
| 5  | 1      | Persian   | Cat     |

Now that we have an idea on how we could go about actually storing the history,
we need to come up with some way of making this happen.