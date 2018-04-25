open RememberMe
open Core

let ins_all_positions x l =
  let rec aux prev acc = function
    | [] -> (prev @ [x]) :: acc |> List.rev
    | hd::tl as l -> aux (prev @ [hd]) ((prev @ [x] @ l) :: acc) tl
  in
  aux [] [] l

let rec permutations = function
  | [] -> []
  | x::[] -> [[x]] (* we must specify this edge case *)
  | x::xs -> List.fold_left ~f:(fun acc p -> acc @ ins_all_positions x p ) ~init:[] (permutations xs)

let permutations_1 = permutations

let irmin_permutations () = memoize IrminMem permutations
let irmin_nth_permutation () = memoize2 IrminMem (fun l n -> List.nth (irmin_permutations () l) n)
let irmin_add1 () = memoize IrminMem (fun x -> x + 1)
let irmin_mult2 () = memoize IrminMem (fun x -> 2 * x)

let hash_permutations () = memoize GlobalHashTbl permutations
let irmin_nth_permutation () = memoize2 IrminMem (fun l n -> List.nth (hash_permutations () l) n)
let hash_add1 () = memoize GlobalHashTbl (fun x -> x + 1)
let hash_mult2 () = memoize GlobalHashTbl(fun x -> 2 * x)

let measure_memory_footprint f =
    Gc.full_major (); 
    let start = Gc.major_plus_minor_words () in
    ignore @@ f (); Gc.full_major (); Gc.major_plus_minor_words () - start

let runTest test backend_string=
    let memoryUsage = measure_memory_footprint @@ test in
    Printf.printf "%s memory usage: %d\n" backend_string memoryUsage; (*  Printf.fprintf stdout "Major heap: %d\n" @@ Gc.heap_words ();*)
    if memoryUsage > 1_000_000 then
        (Gc.print_stat stderr)
    else
        ()

let testOverhead ?(nmb_of_calls=1) addFunctions backend ~args = 
    let memoizedFunctions = List.map ~f:(fun f -> memoize backend f) addFunctions in
    List.iter ~f:(fun x -> List.iter ~f:(fun f -> (*Printf.fprintf stdout "Hash: %d\n" @@ Hashtbl.hash @@ Marshal.to_string *)ignore (f x); Gc.full_major ()) memoizedFunctions) @@ args

let test1 () =
    Printf.printf "Test overhead for one call with varying number of functions\n";
    List.iter ~f:(fun n -> 
            Printf.fprintf stdout "\nLength of the list: %d\n" n;
            let functions = [permutations; permutations_1] in
            let args = [ List.range 1 n] in
            runTest (fun () -> testOverhead functions (IrminMem) ~args) "Irmin_mem"; 
            runTest (fun () -> testOverhead functions GlobalHashTbl ~args) "Global_hash" )
        @@ List.range 2 10 