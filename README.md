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

<!-- not sure if this title is needed -->
### Coming up with an approach

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

### Plan what you will need

Now that we have an idea in mind for how we could keep track of a record, next
we have to come up with a how we could make this happen.

Before diving into actual code, let's first write down some of the steps that
we know will be needed for us to implement our approach.

1. We know that we will need to create a history version of whichever table we
want to keep track of
2. The history table will contain a `ref_id` which will be a foreign key linking
the original field with the history version.
3. The insert into the original table needs to be done first and then a second
insert will need be made into the history table. The reason for this is because
the history table row will need the `id` of the original row.

These are the two main things that we will need to try and test the idea for our
approach.

Of course there are other things that will be needed / nice to have. For example
the history table to be created as close to automatically as we can make it.
This would help minimise possible errors and make the set up for a developer
much easier if we need to implement a history version of multiple tables.

However, although this would be a great feature to have, it will not actually
effect whether or not our idea will be viable solution. You can and should keep
track of your ideas like this as you may need them when implementing the idea
'for real', but for a spike we do not need to do this (unless of course you also
need to spike that idea 😉 (spike-ception)).

### Implement a solution

Now we have an idea and we have a plan for what we will need to do. In some
cases, this will be enough for you to estimate and you can end your spike here.
If you have a solid understanding of how your idea will work and you feel
confident that you can accurately estimate then it is completely fine to do so.

We are going to imagine that you are not in this camp though and that we need to
flesh out how the idea will be implemented.

We are going to do our 'fleshing out' in elixir. As we want to get an example
going as quickly as possible we will be using Phoenix generators. If you want to
learn more about generators then follow
[this link](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Html.html#content)

#### Steps needed

- Create a new phoenix application called app
```
mix phx.new app
```
- Create an animal schema with HTML forms:
```
mix phx.gen.html Animals Animal animals name:string species:string
```
- Create the animals_history table/schema using the mix phx.gen.schema command:
```
mix phx.gen.schema AnimalHistory animals_history ref_id:int name:string species:string
```

This will handle all of the basic setup for us. You will need to follow a few
commands that will be printed in your terminal after each of the above but they
are very clear on what to do.

Now that that's done, we have an application with a form that can be used to
insert into the `animals` table and an `animals_history` table. All that's left
for us to do is make sure that the `animals_history` table is inserted into when
the `animals` table is inserted into or updated in some way.

Let's try and do this test first (TDD). In your text editor, navigate to
`test/app/animals/animals_test.exs`.

Near the top of the file (under the `use App.DataCase`) add the following...
```ex
alias App.{AnimalHistory, Repo}
```

Underneath the last test add the following code.

```ex
test "create_animal/1 with valid data also creates animal_history" do
  assert {:ok, %Animal{} = animal} = Animals.create_animal(@valid_attrs)
  assert animal.name == "some name"
  animal_history = Repo.get_by(AnimalHistory, ref_id: animal.id)
  refute is_nil(animal_history)
end

test "update_animal/2 with valid data inserts new address into animal_history" do
  animal = animal_fixture()
  assert {:ok, %Animal{} = animal} = Animals.update_animal(animal, @update_attrs)
  assert animal.animal_name == "some updated name"
  assert length(Repo.all(Animal)) == 1
  assert length(Repo.all(AnimalHistory)) == 2
end
```

The alias line is for convenience. The part we are going to look at in a little
more detail is the 2 tests.

The first test checks that `create_animal/1` (a function that the generator made
for us) inserts a row into `animal_history`. It inserts an animal into the
`animals` table and then tries to retrieve an `animal_history` using that
`animal_id`. This will fail now as we have not built the logic yet.

The second test checks that `update_animal/2` (another function that the
generator made for us =D) inserts a row into `animal_history`. It first inserts
an animal into the `animals` table with the `animal_fixture/0` function, then it
updates said animal. The test checks to see that there is one animal in the
`animals` table (as we only inserted one), but 2 animals in the
`animals_history` table (the original and the update). This will also fail for
now.

We can see these tests fail my running the tests with the command `mix test`. We
should have 2 tests fail.

Now that we have tests in place, let's move on to writing the logic. Our first
goal is to make sure that an initial insert into `animals` inserts into both
tables, so let's start there. We know that `create_animal/1` handles the logic for inserting new animals so let's go to where this function is defined,
`lib/app/animals.ex`, and find the function definition.

It should look something like this...
```ex
def create_animal(attrs \\ %{}) do
  %Animal{}
  |> Animal.changeset(attrs)
  |> Repo.insert()
end
```

It takes some attributes, passes them to a `changeset` function and then calls
`Repo.insert/2` with that changeset. This is all pretty standard practice in
Phoenix so I am not going to touch on this too much. If you would like to learn
more about it though follow
[this link](https://github.com/dwyl/learn-phoenix-framework).

As we mentioned, the history table will need to contain the `id` of the original
row in the `ref_id` column. Let's create a function that will insert a record
into the `animals_history` for us.

Our function will need to take an `animal` struct and insert into the history
table. Insert the following function underneath `create_animal/1`
```ex
def create_animal_history(animal) do
   params = animal |> Map.from_struct() |> Map.put(:ref_id, animal.id)

   %App.AnimalHistory{}
   |> App.AnimalHistory.changeset(params)
   |> Repo.insert!()
end
```
As you can see, this function is very similar to the `create_animal/1` function.
The main difference is that it takes an `animal` struct and converts this into
a map that can be used as parameters in the `AnimalHistory.changeset/2`
function.

Now that we have a function that can insert into the history table, let's update
the `create_animal` function so that it uses it. In the **plan what you will
need** section we mentioned that we will need to insert the animal first. If
that animal is inserted successfully, we then get the `id` and will use it when
inserting into our `animals_history` table.

This sounds like the perfect time to use an elixir `with` statement.

Update the `create_animal` function to look like this...
```ex
def create_animal(attrs \\ %{}) do
  changeset = Animal.changeset(%Animal{}, attrs)

  with {:ok, animal} <- Repo.insert(changeset),
       _animal_history <- create_animal_history(animal)
  do
    {:ok, animal}
  end
end
```

This looks a little different now but it works in almost the exact same way as
it did previously. It first defines the changeset as a variable. Then the `with`
statement checks to see if the `Repo.insert` function call responds with an
`{:ok, animal}`. If it does it then goes onto the next step and passes that
`animal` to our newly created function `create_animal_history`, else it returns
the error. `create_animal_history` will then handle inserting the data we need
into the history table.

Let's run our tests and see if we have fixed one of the failures. If everything
has been done as instructed, you should only have 1 test failing now so let's
fix that.

The remaining failing test is for the `update_animal/2` function so let's work
on this next. In the same file, find the `update_animal` function. It should
look like this...
```ex
def update_animal(%Animal{} = animal, attrs) do
  animal
  |> Animal.changeset(attrs)
  |> Repo.update()
end
```

You can see that this is **VERY** similar to how our `create_animal` function
looked before, only it calls `Repo.update` instead. Since these are so similar,
the solution we used for insert should also work here.

Update the function to look like so...
```ex
def update_animal(%Animal{} = animal, attrs) do
  with changeset <- Animal.changeset(animal, attrs),
       {:ok, animal} <- Repo.update(changeset),
       _animal_history <- create_animal_history(animal)
  do
    {:ok, address}
  end
end
```

This now takes the animal to be updated and if the update happens successfully
then calls our `create_animal_history` function to insert a new row into the
history table.

If we run the tests again we should see that all the tests pass 🎉🎉🎉.

## Summary

We have achieved what we set out to do. We now know how we could go about
implementing the story/issue we were given and based the experience we had
during the spike, we can now much more accurately estimate how long it will take
to complete. 