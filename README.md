# nushell-scripts
My custom nushell scripts and utils

## TODO

A simple todo util to quickly keep track of simple tasks

### Configuration

From the shell configure the name of your todo file:

> config env

``` nushell
# config todos
$env.TODO_MAIN_FILE = ".todo.todo"
```
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
