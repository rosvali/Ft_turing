open Types

let display_tape tape head =
  let before = String.sub tape 0 head in
  let current = String.get tape head in
  let after = String.sub tape (head + 1) (String.length tape - head - 1) in
  Spectrum.Simple.sprintf "@{<bold>[%s@{<aqua><%c>@}%s]@}" before current after

let display_transition state symbol to_state write action =
  let direction = match action with LEFT -> "LEFT" | RIGHT -> "RIGHT" in
  Spectrum.Simple.sprintf "(@{<rgb(220,220,170)>%s@}, @{<rgb(192,136,113)>'%c'@}) -> (@{<rgb(220,220,170)>%s@}, @{<rgb(192,136,113)>'%c'@}, @{<rgb(86,156,214)>%s@})" state symbol to_state write direction

let string_of_direction = function
  | LEFT -> "LEFT"
  | RIGHT -> "RIGHT"

let string_of_transition (from_state, read) (to_state, write, action) =
  Spectrum.Simple.printf "\t(@{<rgb(220,220,170)>%s@}, @{<rgb(192,136,113)>'%c'@}) -> (@{<rgb(220,220,170)>%s@}, @{<rgb(192,136,113)>'%c'@}, @{<rgb(86,156,214)>%s@})\n"
    from_state read
    to_state write
    (string_of_direction action)

let string_of_state_transitions (state, transitions) =
  let transition_strings = Core.List.map ~f:(fun transition ->
    string_of_transition (state, transition.read) (transition.to_state, transition.write, transition.direction)
  ) transitions in
  transition_strings

let string_of_transitions transitions =
  transitions
  |> Core.List.map ~f:string_of_state_transitions

let print_transitions transitions =
  string_of_transitions transitions

let print_machine_name name =
   (Spectrum.Simple.printf "@{<bold>############### @{<aqua>%s@} ###############@}\n" name)

let print_alphabets alphabets = 
  Spectrum.Simple.printf "@{<bold>Alphabet@}: [";
  (Core.List.map ~f:(fun alphabet -> (Spectrum.Simple.printf " @{<rgb(192,136,113)>'%c'@} " (alphabet))) alphabets);
  Spectrum.Simple.printf "]\n"

let print_blank blank =
  Spectrum.Simple.printf "@{<bold>Blank@}: @{<rgb(192,136,113)>'%c'@}\n" blank

let print_initial initial =
  Spectrum.Simple.printf "@{<bold>Intial@}: @{<rgb(220,220,170)>%s@}\n" initial

let print_list name_list list =
  Spectrum.Simple.printf "@{<bold>%s@}: [" name_list;
  (Core.List.map ~f:(fun element -> (Spectrum.Simple.printf " @{<rgb(220,220,170)>%s@} " (element))) list);
  Spectrum.Simple.printf "]\n"

let display_json_information machine =
  print_machine_name machine.name;
  print_alphabets machine.alphabet;
  print_blank machine.blank;
  print_list "States" machine.states;
  print_initial machine.initial;
  print_list "Finals" machine.finals;
  Spectrum.Simple.printf "@{<bold>Transitions@}:\n";
  print_transitions machine.transitions;
  ();