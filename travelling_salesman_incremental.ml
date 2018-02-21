open Incremental_lib

module Inc = Incremental.Make ()
module Var = Inc.Var

let number_of_nodes_v = Var.create 8 
let graph_v = Inc.map (Var.watch number_of_nodes_v) ~f:(fun x -> Travelling_salesman.generate_graph ~range:9 x)

let print_graph graph_inc = 
    let graph () = Inc.Observer.value_exn @@ (fun x -> Inc.stabilize (); x) @@ Inc.observe graph_inc in
    String.concat "\n" @@ Array.to_list @@ Array.map (fun a -> String.concat ";" @@ Array.to_list @@ Array.map string_of_int a) @@ graph ()

let travelling_salesman_v = Inc.map graph_v ~f:(fun g -> Travelling_salesman.travelling_salesman g)

let result_obs = Inc.observe travelling_salesman_v

let result () = Inc.stabilize (); print_newline (); print_endline @@ print_graph graph_v; print_newline () ; Inc.Observer.value_exn result_obs