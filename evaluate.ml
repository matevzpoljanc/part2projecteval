
open Core_kernel
open RememberMe

let floatListToString = 
    List.to_string ~f:(Float.to_string)

let running_time n =
    let open Travelling_salesman_incremental in
    let start_t = Sys.time () in
    Var.set number_of_nodes_v n;
    print_endline @@ Travelling_salesman.string_of_int_list @@ result (); print_endline (string_of_float (Sys.time () -. start_t))

let timeit f =
    let start_t = Sys.time () in
    ignore @@ f (); Sys.time () -. start_t

let benchmark_function ~f ~args =
    let number_of_iterations = 10 in
    let test_scores =  List.map args ~f:(fun n -> List.init number_of_iterations ~f:(fun x -> timeit @@ fun () -> f n)) in (* Replicate the test multiple times *)
    let average_run_time = 
        List.map ~f:(fun x -> x /. float_of_int number_of_iterations) @@ (* Average results *)
            List.map ~f:(fun el -> List.fold ~init:0.0 ~f:(+.) el) test_scores in (* Add all test results for one parameter *)
    let std_dev = 
        List.map2_exn test_scores average_run_time ~f:(fun scores mean -> sqrt @@ List.fold scores ~init:0.0 ~f:(fun acc el -> acc +. (el -. mean) ** 2.) /. (float_of_int (number_of_iterations-1))) in
    let max_run_time = List.map ~f:(fun x -> match x with | Some y -> y | None -> -1.0) @@ List.map test_scores ~f:(List.max_elt ~cmp:(fun x y -> if x>y then 1 else if x=y then 0 else -1)) in
    let min_run_time =  List.map ~f:(fun x -> match x with | Some y -> y | None -> -1.0) @@ List.map test_scores ~f:(List.min_elt ~cmp:(fun x y -> if x>y then 1 else if x=y then 0 else -1)) in
    ignore @@ List.map3 
        ~f:(fun mean dev (max,min) -> print_endline @@ "mean: " ^ string_of_float mean ^ " stdev: " ^ string_of_float dev ^ " max: " ^ string_of_float max ^ " min: " ^ string_of_float min) 
        average_run_time std_dev (List.map2_exn max_run_time min_run_time ~f:(fun x y -> (x,y)));
    List.iteri test_scores ~f:(fun n scores ->  Printf.printf "%d %s\n" (n+2) (floatListToString scores))

let () =
    Gc.tune ~major_heap_increment:(1_000_448 * 4) ();
    let test_travel_sls = false in
    let test_merkle_tree = false in
    let test_memoization = false in
    let test_rCamlVsInc = false in
    let test_updateTime = false in
    let test_readEveryNUpdates = false in
    let test_breakRC = false in
    let test_memoOverhead = false in
    let test_IrminVsHash= false in
    let test_IrminFsBackend = false in
    let test_IrminFsOnly = true in
    if test_memoization then
        (* For some reason benchmarking doesn't work as the memory is wiped every time *)
        let args = [8] in
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
        let args = List.init 10 ~f:(fun x -> List.init (100*(x+1)) ~f:(fun _ -> Random.int 1_000_000)) in
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
        ();
    if test_updateTime then 
        let open Merkle_tree_inc in
        let args = List.init 1 ~f:(fun _ -> List.init 5 ~f:(fun _ -> Random.int 1_000_000)) in
        let tree_depth = List.range 2 16 in
        print_endline "Incremental";
        List.iter tree_depth ~f:(fun n ->
                                    node_count := 0;
                                    used := false;
                                    Var.set leaf0_value 100;
                                    let tree_inc = Inc.observe @@ tree n in
                                    Inc.stabilize ();
                                    benchmark_function ~args ~f:(fun l -> List.iter l ~f:(fun n -> Var.set leaf0_value n; Inc.stabilize ())));
                                   
        print_endline "ReactiveCaml";
        List.iter tree_depth ~f:(fun n -> 
                                    node_count := 0;
                                    used_rc := false;
                                    ReactiveCaml.set_value leaf0_rc_value 100;
                                    let tree_caml = tree_rc n in
                                    ignore tree_caml; benchmark_function ~args ~f:(fun l -> List.iter l ~f:(fun n -> ReactiveCaml.set_value leaf0_rc_value n)))
    else
        ();
    if test_readEveryNUpdates then
        let open RCamlVsInc in
        let args = List.range 1 10 in
        let updates = List.init 1000 ~f:(fun _ -> Random.int 1000) in
        print_endline "ReactiveCaml";
        benchmark_function ~args ~f:(fun _ -> List.iter updates ~f:(ReactiveCaml.set_value x0));
        print_endline "Incremental";
        benchmark_function ~args ~f:(fun n -> 
            List.iteri updates 
                ~f:(fun i v -> 
                    if i mod n = 0 then 
                        (Var.set x0_inc v; Inc.stabilize (); ignore @@ Inc.Observer.value_exn result_obs)
                    else
                        Var.set x0_inc v))
    else
        ();
    if test_breakRC then
        let open Break_RC in 
        print_endline @@ string_of_int @@ ReactiveCaml.read_exn n0;
        ReactiveCaml.set_value x 0;
        print_endline @@ string_of_int @@ ReactiveCaml.read_exn n0 
    else
        ();
    if test_memoOverhead then
        let open GlobalVsLocalHashtbl in
        test1 (); test2 ()
    else
        ();
    if test_IrminVsHash then
        let open HashTblVsIrmin in
        test1 ()
    else
        ();
    if test_IrminFsBackend then
        let graphs = 9 in
        let graph_size = Core.List.range graphs (graphs+1) in
        let config_roots = List.map graph_size ~f:(fun n -> let n_str = Int.to_string n in (n, "mham"^n_str, "mtrvl"^n_str, "mboth"^n_str)) in
        List.iter config_roots 
            ~f:(fun (n, ham, trvl, both) -> 
                let ham_test = Hamiltonian_path.test1 ~n in
                let trvl_test = Travelling_salesman.test1 ~n in
                ham_test (Irmin_git.config ~root:ham ()); 
                (*trvl_test (Irmin_git.config ~root:both ()); 
                ham_test (Irmin_git.config ~root:both ()); 
                trvl_test (Irmin_git.config ~root:both ())*)
                )
         
    else
        ();
    if test_IrminFsOnly then
        let open Travelling_salesman in
        let args = List.init 7 ~f:(fun n -> generate_graph ~range:10 (n+2)) in
        let config = Irmin_git.config ~root:"fs_only_test" () in
        let memo_permutations = RememberMe.memoize (RememberMe.IrminFsOnly config) permutations in
        let generatePaths_memo = (RememberMe.memoize2 (RememberMe.IrminFsOnly config) generate_paths) memo_permutations in
        let shortestPath_memo = RememberMe.memoize2 (RememberMe.IrminFsOnly config) shortestPath in
        benchmark_function ~f:(fun graph -> test2 ~graph generatePaths_memo shortestPath_memo) ~args;
        Printf.printf "Run test again\n";
        benchmark_function ~f:(fun graph -> test2 ~graph generatePaths_memo shortestPath_memo) ~args;
    else
        ()