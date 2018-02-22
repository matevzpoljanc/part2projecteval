open Incremental_lib

module Inc = Incremental.Make ()
module Var = Inc.Var

let number_of_nodes_v = Var.create 8
let count_v = Var.create 0
let increment () = Var.set count_v ((Var.value count_v) + 1) 
let graph_v = Inc.map2 (Var.watch number_of_nodes_v) (Var.watch count_v) ~f:(fun x y-> Travelling_salesman.generate_graph ~range:9 x)

let print_graph graph_inc = 
    let graph () = Inc.Observer.value_exn @@ (fun x -> Inc.stabilize (); x) @@ Inc.observe graph_inc in
    String.concat "\n" @@ Array.to_list @@ Array.map (fun a -> String.concat ";" @@ Array.to_list @@ Array.map string_of_int a) @@ graph ()

let generate_paths graph_inc = Inc.map graph_inc ~f:(Travelling_salesman.generate_paths) 

let path_length graph path = Travelling_salesman.path_length graph path
let travelling_salesman_v graph_inc paths = Inc.map2 graph_inc paths ~f:(fun g p -> List.fold_left 
            (fun (x,sp) p -> 
                let p_length = path_length g p in
                if p_length < x then (p_length,p) else (x,sp))  (* function to fold *) 
            ((Int32.to_int Int32.max_int), []) (* init value*)
            p)

let result_obs = Inc.observe @@ travelling_salesman_v graph_v (generate_paths graph_v)

let result () = Inc.stabilize ();
                match Inc.Observer.value_exn result_obs with
                | (_, path) -> path