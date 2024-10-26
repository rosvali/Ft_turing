(* A set containing characters only, uses Stdlib compare *)
module CharSet = Set.Make (
struct
	type t = char
	let compare = Stdlib.compare
end)

(* A set containing strings only, uses String compare *)
module StringSet = Set.Make (
struct
	type t = string
	let compare = String.compare
end)

type state_index = int
type to_state = string
type read_char = char
type write_char = char

type state = string
type symbol = char
type direction = LEFT | RIGHT

(* A record containing types for a transition *)
type transition = {
  read : symbol;
  to_state : state;
  write : symbol;
  direction : direction;
}

(* A record containing types for a turing_machine *)
type turing_machine = {
  name : string;
  alphabet : symbol list;
  blank : symbol;
  states : state list;
  initial : state;
  finals : state list;
  transitions : (state * transition list) list;
}
