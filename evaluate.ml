open Core_bench
open Core_kernel
open RememberMe

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
    Bench.Test.create_indexed ~name:"Permutation memo" (fun n -> Staged.stage @@ fun () -> memoize GlobalHashTbl Travelling_salesman.permutations @@ List.range 0 n)

let running_time n =
    let open Travelling_salesman_incremental in
    let start_t = Sys.time () in
    Var.set number_of_nodes_v n;
    print_endline @@ Travelling_salesman.string_of_int_list @@ result (); print_endline (string_of_float (Sys.time () -. start_t))

let timeit f =
    let start_t = Sys.time () in
    ignore @@ f (); Sys.time () -. start_t

let benchmark_function ~f ~args =
    let number_of_iterations = 100 in
    let test_scores =  List.map args ~f:(fun n -> List.init number_of_iterations ~f:(fun x -> timeit @@ fun () -> f n)) in (* Replicate the test multiple times *)
    let average_run_time = 
        List.map ~f:(fun x -> x /. float_of_int number_of_iterations) @@ (* Average results *)
            List.map ~f:(fun el -> List.fold ~init:0.0 ~f:(+.) el) test_scores in (* Add all test results for one parameter *)
    let std_dev = 
        List.map2_exn test_scores average_run_time ~f:(fun scores mean -> List.fold scores ~init:0.0 ~f:(fun acc el -> acc +. (el -. mean) ** 2.)) in
    let max_run_time = List.map ~f:(fun x -> match x with | Some y -> y | None -> -1.0) @@ List.map test_scores ~f:(List.max_elt ~cmp:(fun x y -> if x>y then 1 else if x=y then 0 else -1)) in
    let min_run_time =  List.map ~f:(fun x -> match x with | Some y -> y | None -> -1.0) @@ List.map test_scores ~f:(List.min_elt ~cmp:(fun x y -> if x>y then 1 else if x=y then 0 else -1)) in
    ignore @@ List.map3 
        ~f:(fun mean dev (max,min) -> print_endline @@ "mean: " ^ string_of_float mean ^ " stdev: " ^ string_of_float dev ^ " max: " ^ string_of_float max ^ " min: " ^ string_of_float min) 
        average_run_time std_dev (List.map2_exn max_run_time min_run_time ~f:(fun x y -> (x,y)))

let () =
    let test_travel_sls = false in
    let test_merkle_tree = false in
    let test_memoization = false in
    let test_rCamlVsInc = true in
    if test_memoization then
        (* For some reason benchmarking doesn't work as the memory is wiped every time *)
        let args = [8] in
        Bench.bench ~run_config:(Bench.Run_config.create ~fork_each_benchmark:false ()) [benchmark_permutation ~args:args; benchmark_permutation_memo ~args:args];
        benchmark_function ~f:Travelling_salesman.permutations ~args:(List.map args ~f:(fun n -> List.range 0 n));
        benchmark_function ~f:(memoize GlobalHashTbl Travelling_salesman.permutations) ~args:(List.map args ~f:(fun n -> List.range 0 n))
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
        benchmark_function ~f:(fun n -> Var.set number_of_nodes_v n; increment (); ignore @@ result ()) ~args:args;
        (* Bench.bench ~run_config:(Bench.Run_config.create ~fork_each_benchmark:false ()) [benchmark_normal ~args:args; benchmark_incremental ~args:args; benchmark_incremental_memo ~args:args]; *)
        let open Trvl_sls_inc_memo in
        benchmark_function ~f:(fun n -> update_graph (); ignore @@ result ()) ~args:args;
        let open Trvl_sls_inc_memo_irmin in
        benchmark_function ~f:(fun n -> update_graph (); ignore @@ result ()) ~args:args;
    else
        ();
    (* Update one variable 100, 200, ..., 1000 times and examine the performance *)
    if test_rCamlVsInc then
        let open RCamlVsInc in
        let args = List.init 10 ~f:(fun x -> List.init (100*(x+1)) ~f:(fun _ -> Random.int 1000)) in
        print_endline "ReactiveCaml";
        benchmark_function ~f:(fun n -> List.iter n ~f:(ReactiveCaml.set_value x0)) ~args;
        print_endline "Inc observe every cycle";
        benchmark_function ~f:(fun n -> 
            List.iter n 
                ~f:(fun v -> Var.set x0_inc v; Inc.stabilize (); ignore @@ Inc.Observer.value_exn result_obs )) ~args;
        print_endline "Inc observe at the end";
            benchmark_function ~f:(fun n -> 
                List.iter n ~f:(fun v -> Var.set x0_inc v); Inc.stabilize (); ignore @@ Inc.Observer.value_exn result_obs ) ~args
    else
        ()