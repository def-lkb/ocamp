(* Abstract presentation of the computation engine *)

module type Spec = sig
  type command
  val compare_command : command -> command -> int
  val print_command : command -> string

  type hint
  type result

  val cached
    :  build:(?hint:hint -> command -> result Lwt.t)
    -> command
    -> result option Lwt.t

  val execute
    :  build:(?hint:hint -> command -> result Lwt.t)
    -> ?cached:result
    -> ?hint:hint
    -> command
    -> result Lwt.t
end

module Make (S : Spec) :
sig
  module CommandMap : Map.S with type key = S.command
  exception Cycle of S.command * S.command list
  val state : unit -> S.result CommandMap.t
  val build : ?hint:S.hint -> S.command -> S.result Lwt.t
end