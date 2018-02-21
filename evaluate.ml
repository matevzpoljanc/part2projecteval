open Core_bench
open Core_kernel

let benchmark_normal = 
    let open Travelling_salesman in 
    Bench.Test.create_indexed ~name:"Travelling salesman" 
                        (fun x -> Staged.stage @@ fun () -> ignore @@ travelling_salesman @@ generate_graph ~range:10 (x))

let benchmark_incremental = 
    let open Travelling_salesman_incremental in 
    Bench.Test.create_indexed ~name:"Trav_sls inc"
                        (fun n -> Staged.stage @@ fun () -> Var.set number_of_nodes_v n; increment (); ignore @@ result ())

let benchmark_incremental_memo = 
    let open Trvl_sls_inc_memo in
    Bench.Test.create_indexed ~name:"Trav_sls inc memo"
                        (fun n -> Staged.stage @@ fun () -> Var.set number_of_nodes_v n; increment (); ignore @@ result ())


let benchmark_permutation = 
    Bench.Test.create_indexed ~name:"Permutation" (fun n -> Staged.stage @@ fun () -> Travelling_salesman.permutations @@ List.range 0 n)

let benchmark_permutation_memo = 
    let open Memoize in
    Bench.Test.create_indexed ~name:"Permutation memo" (fun n -> Staged.stage @@ fun () -> memoize Travelling_salesman.permutations @@ List.range 0 n)

let running_time n =
    let open Travelling_salesman_incremental in
    let start_t = Sys.time () in
    Var.set number_of_nodes_v n;
    print_endline @@ Travelling_salesman.string_of_int_list @@ result (); print_endline (string_of_float (Sys.time () -. start_t))

let timeit f =
    let start_t = Sys.time () in
    ignore @@ f (); Sys.time () -. start_t

let benchmark_function ~f ~args =
    let number_of_iterations = 5 in
    let test_scores =  List.map args ~f:(fun n -> List.init number_of_iterations ~f:(fun x -> timeit @@ fun () -> f n)) in (* Replicate the test multiple times *)
    let average_run_time = 
        List.map ~f:(fun x -> x /. float_of_int number_of_iterations) @@ (* Average results *)
            List.map ~f:(fun el -> List.fold ~init:0.0 ~f:(+.) el) test_scores in (* Add all test results for one parameter *)
    let std_dev = 
        List.map2_exn test_scores average_run_time ~f:(fun scores mean -> List.fold scores ~init:0.0 ~f:(fun acc el -> acc +. (el -. mean) ** 2.)) in
    ignore @@ List.map2 ~f:(fun mean dev -> print_endline @@ string_of_float mean ^ " " ^ string_of_float dev) average_run_time std_dev

let () =
    let test_travel_sls = false in
    let test_merkle_tree = false in
    let test_memoization = true in
    if test_memoization then
        (* For some reason benchmarking doesn't work as the memory is wiped every time *)
        let args = [8] in
        Bench.bench ~run_config:(Bench.Run_config.create ~fork_each_benchmark:false ()) [benchmark_permutation ~args:args; benchmark_permutation_memo ~args:args]

        (* let args = [8] in
        benchmark_function ~f:Travelling_salesman.permutations ~args:(List.map args ~f:(fun n -> List.range 0 n));
        benchmark_function ~f:(Memoize.memoize Travelling_salesman.permutations) ~args:(List.map args ~f:(fun n -> List.range 0 n))    *)
    else
        ();
    if test_merkle_tree then
        let open Merkle_tree_inc in
        let vlist = var_list [1;2;3;4;5;6;7;8] in
        let m_tree =  merkle_tree_from_list vlist in
        Merkle_tree_inc.eval (fun () -> merkle_tree (m_tree) ()) ();
        Var.set (List.nth_exn vlist 0) (Leaf (9, hash 9));
        Inc.stabilize ();
        Merkle_tree_inc.eval (fun () -> merkle_tree (m_tree) ()) ()
    else 
        ();
    if test_travel_sls then
        let args = [8] in
        let open Travelling_salesman_incremental in
        Bench.bench ~run_config:(Bench.Run_config.create ~fork_each_benchmark:false ()) [benchmark_normal ~args:args; benchmark_incremental ~args:args; benchmark_incremental_memo ~args:args]
    else
        ()