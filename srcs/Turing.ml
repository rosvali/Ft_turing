open Types
open Display

(* turing_machine -> string -> string *)
let execute_machine machine tape =
  let tape_length = String.length tape in
  let rec step tape head state =
    if List.mem state machine.finals then tape
    else if head < 0 || head >= tape_length then (
      (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing :tape head went out of bounds\n"; exit(-1))
      tape
    )
    else
      let symbol = tape.[head] in
      let transitions_for_state = List.assoc state machine.transitions in
      let transition = List.find_opt (fun t -> t.read = symbol) transitions_for_state in
      match transition with
      | None -> (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : No transition found for state '%s' with symbol '%c'\n" state symbol; exit(-1))
      | Some { to_state; write; direction } ->
        let tape = Bytes.of_string tape in
        Bytes.set tape head write;
        let new_tape = Bytes.to_string tape in
        let new_head = match direction with
          | LEFT -> head - 1
          | RIGHT -> head + 1
        in
        let transition_str = display_transition state symbol to_state write direction in
        print_endline (display_tape new_tape head ^ " " ^ transition_str);

        step new_tape new_head to_state
  in
  step tape 0 machine.initial

(* turing_machine -> string *)
let execute machine = 
  let input = Sys.argv.(2) ^ "." in
  execute_machine machine input
