open Types

let direction_of_string = function
  | "LEFT" -> LEFT
  | "RIGHT" -> RIGHT

(*fst = first parce que vasy ce besoin a besoin de faire une economie de 2 fuckings charactere*)
let first_pair_lists list = fst (List.split list)

let rec check_required_key required_keys json_keys detail =
  match required_keys with
  | current_key::other_keys when List.exists (fun _json_key -> String.compare _json_key current_key = 0) json_keys -> check_required_key other_keys json_keys detail
  | current_key::other_keys -> (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : %s %skey messing !\n" current_key detail); exit(-1);
  | [] -> ()

let json_to_list ?(name = "") json = 
  try Yojson.Basic.Util.to_list json with
  | _ -> Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : member %s is not a list\n" name ; exit (-1)

let transition_of_json json =
{
  read = (json |> Yojson.Basic.Util.member "read" |> Yojson.Basic.Util.to_string).[0];  (* Convertir un caractère *)
  to_state = json |> Yojson.Basic.Util.member "to_state" |> Yojson.Basic.Util.to_string;
  write = (json |> Yojson.Basic.Util.member "write" |> Yojson.Basic.Util.to_string).[0];
  direction = json |> Yojson.Basic.Util.member "action" |> Yojson.Basic.Util.to_string |> direction_of_string;
}

(* Convertir une association (clé, liste de transitions JSON) en liste de transitions *)
let transitions_of_json json =
  let state_transitions = Yojson.Basic.Util.to_assoc json in  (* Convertir en une association (clé-valeur) *)
  Core.List.map ~f:(fun (state, transitions_json) ->
    let transitions = transitions_json
      |> Yojson.Basic.Util.to_list
      |> Core.List.map ~f:transition_of_json in
    (state, transitions)
  ) state_transitions

  let rec verifie_chaine_alphabet str alphabet_list =
    let rec appartient a lst =
      match lst with
      | [] -> false
      | x :: xs -> if x = a then true else appartient a xs
    in
    let len = String.length str in
    let rec aux i =
      if i >= len then true
      else if appartient (String.get str i) alphabet_list then aux (i + 1)
      else false
    in
    aux 0

(* Fonction pour vérifier que tous les caractères sont dans l'alphabet *)
let check_transitions_in_alphabet transitions alphabet =
  let reads = List.fold_left (fun acc (state, trans_list) ->
    List.fold_left (fun acc trans ->
      (trans.read :: acc)
    ) acc trans_list
  ) [] transitions in
  let all_in_alphabet = List.for_all (fun c -> List.mem c alphabet) reads in
  all_in_alphabet

let check_states_in_list transitions states =
  let to_states = List.fold_left (fun acc (state, trans_list) ->
    List.fold_left (fun acc trans ->
      trans.to_state :: acc
    ) acc trans_list
  ) [] transitions in
  let all_in_states = List.for_all (fun s -> List.mem s states) to_states in
  all_in_states

let parse () =
  let args = Sys.argv in
  if Array.length args >= 2 then
    if args.(1) = "-h" || args.(1) = "--help" then
      (Spectrum.Simple.printf "usage: ft_turing [-h] jsonfile input\n
positional arguments:\n
  jsonfile\tjson description of the machine\n
  input\tinput of the machine\n
optional arguments:\n
  -h, --help\t show this help message and exit\n"; exit(-1));
  if Array.length args != 3 then
    (Spectrum.Simple.printf "Usage: ./ft_turing <path_to_machine> <input>\n"; exit(-1))
  else
    let json =  try Yojson.Basic.from_file args.(1) with
    | Yojson.Json_error str -> Spectrum.Simple.printf "@{<bold>@{<#f00>[Error]@}@} ft_turing : %s : %s\n" args.(1) str ; exit (-1)
    | Sys_error str ->  Spectrum.Simple.printf "@{<bold>@{<#f00>[Error]@}@} ft_turing : Error %s %s\n" args.(1) str ; exit (-1)
    | _ ->  Spectrum.Simple.printf "@{<bold>@{<#f00>[Error]@}@} ft_turing : %s : Error opening json file\n" args.(1) ; exit (-1)
  in
  let assoc_list = try Yojson.Basic.Util.to_assoc json with
  | Yojson.Basic.Util.Type_error (msg, _) -> (Spectrum.Simple.printf "@{<bold>@{<#f00>[Error]@}@} ft_turing : %s must be a list\n %s\n" args.(1) msg; exit(1))
  in
  let required_keys = ["name";"alphabet"; "blank"; "states"; "initial"; "finals"; "transitions"] in
  let json_keys = first_pair_lists assoc_list in
  check_required_key required_keys json_keys "";
  let key_duplicate = Core.List.find_a_dup ~compare:String.compare json_keys in
  if key_duplicate != None then begin
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : %s key is duplicate\n" (Option.get key_duplicate); exit(-1))
  end;
  let name = json |> Yojson.Basic.Util.member "name" |> Yojson.Basic.Util.to_string in
  let alphabets = json_to_list ~name:"alphabet" (json |> Yojson.Basic.Util.member "alphabet") in
  let alphabets_list = Yojson.Basic.Util.filter_string alphabets in
  let alphabet_duplicate = Core.List.find_a_dup ~compare:String.compare alphabets_list in
  if alphabet_duplicate != None then begin
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : alphabet element '%s' is duplicate\n" (Option.get alphabet_duplicate); exit(-1))
  end;
  Core.List.iter alphabets_list ~f:(fun alphabet ->
    if String.length alphabet = 0 then begin
      (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : alphabet can't be empty\n"; exit(-1))
    end else if String.length alphabet <> 1 then
      (
        Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : '%s' is wrong : alphabets should be 1 character;\n" alphabet;
        exit(-1)
      )
  );
  let blank = json |> Yojson.Basic.Util.member "blank" |> Yojson.Basic.Util.to_string in
  if String.length blank = 0 then begin
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : blank can't be empty\n"; exit(-1))
  end else if String.length blank <> 1 then begin
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : '%s' is wrong : blank should be 1 character;\n" blank; exit(-1));
  end;
  let states_input = json_to_list ~name:"states" (json |> Yojson.Basic.Util.member "states") in
  let states_list = Yojson.Basic.Util.filter_string states_input in
  let states_duplicate = Core.List.find_a_dup ~compare:String.compare states_list in
  if states_duplicate != None then begin
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : states element '%s' is duplicate\n" (Option.get states_duplicate); exit(-1))
  end;
  Core.List.iter states_list ~f:(fun state ->
    if String.length state = 0 then begin
      (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : state can't be empty\n"; exit(-1))
    end;
  );
  let initial = json |> Yojson.Basic.Util.member "initial" |> Yojson.Basic.Util.to_string in
  if not (List.exists (fun state -> state = initial) states_list) then begin
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : %s initial state isn't part of actual states\n") initial; exit(-1);
  end;
  let finals_input = json_to_list ~name:"finals" (json |> Yojson.Basic.Util.member "finals") in
  let finals_list = Yojson.Basic.Util.filter_string finals_input in
  let final_duplicate = Core.List.find_a_dup ~compare:String.compare finals_list in
  if final_duplicate != None then begin
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : final element '%s' is duplicate\n" (Option.get final_duplicate); exit(-1))
  end;
  Core.List.iter finals_list ~f:(fun final ->
    if String.length final = 0 then begin
      (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : final can't be empty\n"; exit(-1))
    end;
    if not (List.exists (fun state -> state = final) states_list) then begin
      (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : %s final state isn't part of actual states\n") final; exit(-1);
    end;
  );
  let transitions_json = Yojson.Basic.Util.member "transitions" json in
  let transitions_pair = try Yojson.Basic.Util.to_assoc transitions_json with
  | Yojson.Basic.Util.Type_error (msg, _) -> (Spectrum.Simple.printf "@{<bold>@{<#f00>[Error]@}@} ft_turing : %s must be a list\n %s\n" args.(1) msg; exit(1))
  in
  let transitions_members = first_pair_lists transitions_pair in
  let transitions_names = Types.StringSet.of_list transitions_members in
  let transition_required_list = Core.List.filter states_list ~f:(fun state ->
    not (Core.List.mem finals_list state ~equal:String.equal)) in
  check_required_key transition_required_list transitions_members "transition ";
  let transitions_name_dup = Core.List.find_a_dup ~compare:String.compare transitions_members in
  if transitions_name_dup != None then begin
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : %s transition key is duplicate\n" (Option.get transitions_name_dup); exit(-1))
  end;
  let transitions = transitions_of_json transitions_json in
  (* Conversion de la liste de strings en liste de caractères *)
  let alphabet_char_list = List.map (fun s -> s.[0]) alphabets_list in
  if ((verifie_chaine_alphabet args.(2) alphabet_char_list) = false) then
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : \"%s\" input is wrong\n" args.(2); exit(-1));
  if ((check_transitions_in_alphabet transitions alphabet_char_list) = false) then
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : transitions write or read isn't on alphabets\n" ; exit(-1));
  if ((check_states_in_list transitions states_list) = false) then
    (Spectrum.Simple.printf "@{<bold>@{<#f00>[ERROR]@}@} ft_turing : transitions states isn't on states machines\n" ; exit(-1));
  let data = {
      name = name;
      alphabet = alphabet_char_list;
      blank = String.get blank 0;
      states = states_list;
      initial = initial;
      finals = finals_list;
      transitions = transitions
    } in data 