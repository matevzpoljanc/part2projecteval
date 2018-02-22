open Incremental_lib
open Memoize

module Inc = Incremental.Make ()
module Var = Inc.Var

let number_of_nodes_v = Var.create 8
let number_of_nodes = ref 7
let max_distance = 3
let count_v = Var.create 0
let increment () = Var.set count_v ((Var.value count_v) + 1) 
let graph_v = Var.create @@ Travelling_salesman.generate_graph ~range:3 (!number_of_nodes)

let update_graph () = 
    let graph = Var.value graph_v in
    Var.set graph_v @@ Array.map (fun node -> Array.map (fun d -> if Random.int 2 = 1 then (d + Random.int max_distance) mod max_distance else d) node) graph

let print_graph graph_inc = 
    let graph () = Inc.Observer.value_exn @@ (fun x -> Inc.stabilize (); x) @@ Inc.observe graph_inc in
    String.concat "\n" @@ Array.to_list @@ Array.map (fun a -> String.concat ";" @@ Array.to_list @@ Array.map string_of_int a) @@ graph ()

let generate_paths g =
    let open Core_kernel in
    (memoize Travelling_salesman.permutations) @@ (memoize2 List.range) 0 @@ Array.length g
let generate_paths graph_inc = Inc.map graph_inc ~f:(generate_paths) 

let path_length graph path = Travelling_salesman.path_length graph path
let travelling_salesman_v graph_inc paths = Inc.map2 graph_inc paths ~f:(memoize2 @@ fun g p -> List.fold_left 
            (fun (x,sp) p -> 
                let p_length = path_length g p in
                if p_length < x then (p_length,p) else (x,sp))  (* function to fold *) 
            ((Int32.to_int Int32.max_int), []) (* init value*)
            p)

let result_obs = Inc.observe @@  travelling_salesman_v (Var.watch graph_v) (generate_paths (Var.watch graph_v))

let result () = Inc.stabilize ();
                match Inc.Observer.value_exn result_obs with
                | (_, path) -> path