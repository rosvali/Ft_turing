(* main.ml *)

open Yojson.Basic.Util
open Yojson.Basic
open Types
open Parsing
open Turing
open Display


let () =
  let machine = Parsing.parse(); in
	Display.display_json_information machine;
  ignore (Turing.execute(machine))