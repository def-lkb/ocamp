OCamp extends unix shells with constructions to express memoization, sharing of computations and reactive programming.
Licensed under CC0.

# OCamp subcommands

## The default operation is to start a command

Just wrap a unix command with "ocamp" to enable the extension:

    $ ocamp bash

This will spawn a new bash session where the following subcommands are enabled.

## hipp

    $ ocamp hipp <command>

Will memoize the output and exit status of `<command>`.
Later calls to the same `<command>` won't lead to actual execution, but just to a duplication of its previous output.
Concurrent calls to `<command>` will just share the same process, the beginning of the output being replayed to later callers.

The identity of a command is defined by its arguments and working directory.

## stir

    $ ocamp stir <command>

Indicate potential changes in the output if `<command>` was rerun.
Later calls to `hipp` will recompute `<command>` as if it was not yet memoized.

## (un)follow

    $ ocamp follow <command>

First, `<command>` is memoized if it was not the case yet.
Then changes to dependencies of `<command>` will trigger a reevaluation.
Use `stir` to notify a change.

(to follow is an hipp/stir reaction).

## pull

    $ ocamp pull <command>

Closely related to `hipp`, but instead of marking dependency on the output of `<command>`, the dependency applies to the "effects" of `<command>`.

Thus, if `stir` is used:
- all pullers will be reevaluated.
- hippers will be reevaluated only if the output is different.

## Summary

    $ ocamp fire <command> - setup a new session alive until <command> exits
            pull <command> - mark dependency on effects of <command>
            hipp <command> - mark dependency on output of <command>
            stir <command> - notify that <command> might have been updated
            follow <command> - eval <command>, and reactively recompute it
                               whenever one of its dependencies change.
            unfollow <command> - stop recomputing <command> when dependencies
                                 change

hipp and pull provide memoization.
stir and follow bring a flavor of reactive programming.

# Examples

## Fibonacci

    $ cat fib.sh
    #!/bin/sh
    ARG="$1"
    if [ "$ARG" -le 1 ]; then
      echo "$ARG"
    else
      A=`ocamp hipp ./fib.sh $((ARG-1))`
      B=`ocamp hipp ./fib.sh $((ARG-2))`
      echo $((A+B))
    fi

    $ time ocamp fire ./fib.sh 50
    12586269025
      real    0m0.391s
    user    0m0.153s
    sys     0m0.060s

## Build-system

`ocamp` provides simple primitives to construct and manage a dependency graph.

This might be a saner foundation to base a build-system on than make(1):
- the command focus on one specific problem
- no dsl is involved; rules can be plain unix commands, including a shell, rather than a make-flavored simulation of shell
- nothing is provided for resolving goals; indeed this is better left to tools specifically built for goal-search.

A quick'n'dirty script building ocamp itself is provided as an example.

# Future

The current release is a proof-of-concept and should be considered alpha quality.

Semantics:
- subcommands should probably be executed in client environment
- `stir` should probably not trigger execution in current context

Features:
- Find a way to make the graph persistent (all data is kept in memory atm)
- Provide an interface to debug and/or observe graph construction.
