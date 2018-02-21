open Core_bench
open Core_kernel

let benchmark_normal = 
    let open Travelling_salesman in 
    Bench.Test.create_indexed ~name:"Travelling salesman" 
                        (fun x -> Staged.stage @@ fun () -> ignore @@ travelling_salesman @@ generate_graph ~range:10 (x))

let benchmark_incremental = 
    let open Travelling_salesman_incremental in 
    Bench.Test.create_indexed ~name:"Trav_sls incremental"
                        (fun n -> Staged.stage @@ fun () -> Var.set number_of_nodes_v n; ignore @@ result ())

let () = 
(* 
    let open Merkle_tree_inc in
    let vlist = var_list [1;2;3;4;5;6;7;8] in
    let m_tree =  merkle_tree_from_list vlist in
    Merkle_tree_inc.eval (fun () -> merkle_tree (m_tree) ()) ();
    Var.set (List.nth_exn vlist 0) (Leaf (9, hash 9));
    Inc.stabilize ();
    Merkle_tree_inc.eval (fun () -> merkle_tree (m_tree) ()) ()
*)

    let args = [2;4;6;8] in
    let open Travelling_salesman_incremental in
    (* Bench.bench [benchmark_normal ~args:args; benchmark_incremental ~args:args]; 
    print_endline @@ Travelling_salesman.string_of_int_list @@ Travelling_salesman.travelling_salesman Travelling_salesman.graph;*)
    print_endline @@ Travelling_salesman.string_of_int_list @@ Travelling_salesman_incremental.result ();
    Travelling_salesman_incremental.Var.set Travelling_salesman_incremental.number_of_nodes_v 7;
    print_endline @@ Travelling_salesman.string_of_int_list @@ Travelling_salesman_incremental.result ();