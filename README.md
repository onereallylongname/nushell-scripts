# nushell-scripts
My custom nushell scripts and utils

## TODO

A simple todo util to quickly keep track of simple tasks
It uses a file (essentially a yaml list) to store quick notes

The last command output is automatically store on the variable '$env.last_todo'

Allows for listing, adding searching and completing tasks

Use the 'help todo' or 'todo \<command\> -h' to learn more

### Configuration

From the shell configure the name of your todo file:

> config env

``` nushell
# config todos
$env.TODO_MAIN_FILE = ([$env.HOME .todo.todo] | path join)
```
Where ".todo.todo" is the desired name for the todo file.

Then add the following to the nushell config:

> config nu

``` nushell
# Config todo
# This loads todos when you launch the shell
use todo.nu 

# This makes sure you have a todo file created
if (not ($env.TODO_MAIN_FILE | path exists)) {
    touch $"($env.TODO_MAIN_FILE)"
}
```

### Usage

For help use. All commands are annotated

> help todo

The tasks have are created with the column "done" as false by default (this can be overwritten with the add command).
The done column is store as a bool, but is replaced with "✅" if completed and "⏳" if not.

### Suggestions
This is an example flow.

#### List todos

> todo list

``` sh
╭───┬─────────────┬─────────────────────────────────────────────────────┬──────────────────────────────────────┬─────────╮
│ # │     id      │                       summary                       │                 date                 │ updated │
├───┼─────────────┼─────────────────────────────────────────────────────┼──────────────────────────────────────┼─────────┤
│ 0 │ 57cd86f02c1 │ Add relations to other todos by id                  │ 2025-03-05 08:31:08.500422466 +00:00 │         │
│ 1 │ bbf1d6644d1 │ Add udpdate task                                    │ 2025-03-05 08:31:32.957327351 +00:00 │         │
│ 2 │ 3c376e03cfa │ Add filter-by to filter using tasks                 │ 2025-03-05 08:32:05.321675195 +00:00 │         │
│ 3 │ 192324f18dd │ Make add and update return the id created/update    │ 2025-03-05 08:32:34.543618700 +00:00 │         │
│ 4 │ 7cfa7ceeb1e │ Make todo id accept the id by sdtin                 │ 2025-03-05 08:33:03.394517681 +00:00 │         │
│ 5 │ 17e2f4c351b │ Add flag for --full (-f) on list to show all fields │ 2025-03-05 08:34:11.440593152 +00:00 │         │
│ 6 │ 22fc5116718 │ Usage examples to readme                            │ 2025-03-05 08:34:36.785379669 +00:00 │         │
╰───┴─────────────┴─────────────────────────────────────────────────────┴──────────────────────────────────────┴─────────╯
```

#### Mark a todo as done

> todo done 17 

``` sh
╭───┬─────────────┬──────┬─────────────────────────────────────────────────────┬──────────────────────────────────────┬────────────────┬────────────────┬────────────────╮
│ # │     id      │ done │                       summary                       │                 date                 │    updated     │     links      │      tags      │
├───┼─────────────┼──────┼─────────────────────────────────────────────────────┼──────────────────────────────────────┼────────────────┼────────────────┼────────────────┤
│ 0 │ 17e2f4c351b │ ✅   │ Add flag for --full (-f) on list to show all fields │ 2025-03-05 08:34:11.440593152 +00:00 │ 15 seconds ago │ [list 0 items] │ [list 0 items] │
╰───┴─────────────┴──────┴─────────────────────────────────────────────────────┴──────────────────────────────────────┴────────────────┴────────────────┴────────────────╯
```

#### Use nushell tables

Commands return nushell tables to play as needed

> todo list -a | sort-by done

``` sh
╭───┬─────────────┬──────┬─────────────────────────────────────────────────────┬──────────────────────────────────────┬──────────────────────────────────────╮
│ # │     id      │ done │                       summary                       │                 date                 │               updated                │
├───┼─────────────┼──────┼─────────────────────────────────────────────────────┼──────────────────────────────────────┼──────────────────────────────────────┤
│ 0 │ 57cd86f02c1 │ ⏳   │ Add relations to other todos by id                  │ 2025-03-05 08:31:08.500422466 +00:00 │                                      │
│ 1 │ bbf1d6644d1 │ ⏳   │ Add udpdate task                                    │ 2025-03-05 08:31:32.957327351 +00:00 │                                      │
│ 2 │ 3c376e03cfa │ ⏳   │ Add filter-by to filter using tasks                 │ 2025-03-05 08:32:05.321675195 +00:00 │                                      │
│ 3 │ 192324f18dd │ ⏳   │ Make add and update return the id created/update    │ 2025-03-05 08:32:34.543618700 +00:00 │                                      │
│ 4 │ 7cfa7ceeb1e │ ⏳   │ Make todo id accept the id by sdtin                 │ 2025-03-05 08:33:03.394517681 +00:00 │                                      │
│ 5 │ 17e2f4c351b │ ✅   │ Add flag for --full (-f) on list to show all fields │ 2025-03-05 08:34:11.440593152 +00:00 │ 2025-03-05 13:34:40.291587148 +00:00 │
│ 6 │ 22fc5116718 │ ⏳   │ Usage examples to readme                            │ 2025-03-05 08:34:36.785379669 +00:00 │                                      │
╰───┴─────────────┴──────┴─────────────────────────────────────────────────────┴──────────────────────────────────────┴──────────────────────────────────────╯
```

#### Last command

The last command is store and always accessible

> $env.last_todo | sort-by date | last 3

``` sh
╭───┬─────────────┬──────┬─────────────────────────────────────────────────────┬──────────────────────────────────────┬──────────────────────────────────────╮
│ # │     id      │ done │                       summary                       │                 date                 │               updated                │
├───┼─────────────┼──────┼─────────────────────────────────────────────────────┼──────────────────────────────────────┼──────────────────────────────────────┤
│ 0 │ 7cfa7ceeb1e │ ⏳   │ Make todo id accept the id by sdtin                 │ 2025-03-05 08:33:03.394517681 +00:00 │                                      │
│ 1 │ 17e2f4c351b │ ✅   │ Add flag for --full (-f) on list to show all fields │ 2025-03-05 08:34:11.440593152 +00:00 │ 2025-03-05 13:34:40.291587148 +00:00 │
│ 2 │ 22fc5116718 │ ⏳   │ Usage examples to readme                            │ 2025-03-05 08:34:36.785379669 +00:00 │                                      │
╰───┴─────────────┴──────┴─────────────────────────────────────────────────────┴──────────────────────────────────────┴──────────────────────────────────────╯
```
#### Add a task

Tasks can have links and tags

> todo add -t \[example readme\] -k \["https://github.com/onereallylongname/nushell-scripts"\] This task has it all

``` sh
╭───┬─────────────┬──────────────────────────────────────────────────┬──────────────────────────────────────┬─────────┬────────────────┬────────────────╮
│ # │     id      │                     summary                      │                 date                 │ updated │     links      │      tags      │
├───┼─────────────┼──────────────────────────────────────────────────┼──────────────────────────────────────┼─────────┼────────────────┼────────────────┤
│ 0 │ 57cd86f02c1 │ Add relations to other todos by id               │ 2025-03-05 08:31:08.500422466 +00:00 │         │ [list 0 items] │ [list 0 items] │
│ 1 │ bbf1d6644d1 │ Add udpdate task                                 │ 2025-03-05 08:31:32.957327351 +00:00 │         │ [list 0 items] │ [list 0 items] │
│ 2 │ 3c376e03cfa │ Add filter-by to filter using tasks              │ 2025-03-05 08:32:05.321675195 +00:00 │         │ [list 0 items] │ [list 0 items] │
│ 3 │ 192324f18dd │ Make add and update return the id created/update │ 2025-03-05 08:32:34.543618700 +00:00 │         │ [list 0 items] │ [list 0 items] │
│ 4 │ 7cfa7ceeb1e │ Make todo id accept the id by sdtin              │ 2025-03-05 08:33:03.394517681 +00:00 │         │ [list 0 items] │ [list 0 items] │
│ 5 │ 22fc5116718 │ Usage examples to readme                         │ 2025-03-05 08:34:36.785379669 +00:00 │         │ [list 0 items] │ [list 0 items] │
│ 6 │ 4d3be376a46 │ This task has it all                             │ 2025-03-05 13:52:42.259112745 +00:00 │         │ [list 1 item]  │ [list 2 items] │
╰───┴─────────────┴──────────────────────────────────────────────────┴──────────────────────────────────────┴─────────┴────────────────┴────────────────╯
```

#### Search

> todo fyzzy 4d3

``` sh 
╭───┬─────────────┬──────┬──────────────────────┬──────────────────────────────────────┬─────────┬──────────────────────────────────────────────────────────────┬──────────────────╮
│ # │     id      │ done │       summary        │                 date                 │ updated │                             links                            │       tags       │
├───┼─────────────┼──────┼──────────────────────┼──────────────────────────────────────┼─────────┼──────────────────────────────────────────────────────────────┼──────────────────┤
│   │             │      │                      │                                      │         │ ╭───┬──────────────────────────────────────────────────────╮ │  ╭───┬─────────╮ │
│ 0 │ 4d3be376a46 │ ⏳   │ This task has it all │ 2025-03-05 13:52:42.259112745 +00:00 │         │ │ 0 │ https://github.com/onereallylongname/nushell-scripts │ │  │ 0 │ example │ │
│   │             │      │                      │                                      │         │ ╰───┴──────────────────────────────────────────────────────╯ │  │ 1 │ readme  │ │
│   │             │      │                      │                                      │         │                                                              │  ╰───┴─────────╯ │
╰───┴─────────────┴──────┴──────────────────────┴──────────────────────────────────────┴─────────┴──────────────────────────────────────────────────────────────┴──────────────────╯ 
```

#### Tips

Use links from the console. Open the first link (on the default browser) of the first todo matching the tag example.
_Note_: The links are not validated. The start command also works with files.

> todo by-tag example | get links.0.0 | start $in



