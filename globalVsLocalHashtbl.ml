open RememberMe
open Core_kernel

let add1 x = x+1
let add2 x = x+2

let add1_local () = memoize LocalHashTbl add1
let add1_global () = memoize GlobalHashTbl add1


let add2_local () = memoize LocalHashTbl add2
let add2_global () = memoize GlobalHashTbl add2

let intList n l = List.init l ~f:(fun _ -> Random.int n);;

let intList_local () = memoize2 LocalHashTbl intList
let intList_global () = memoize2 GlobalHashTbl intList

let testAdd add_f = 
    let add n = ignore @@ add_f () n in
    add 3; add 2; add 2; add 4; add 5; add 5; add 6; add 1; add 4; add 5

let testOverhead ?(nmb_of_calls=1) addFunctions backend = 
    let memoizedFunctions = List.map ~f:(fun f -> memoize backend f) addFunctions in
    List.iter ~f:(fun x -> List.iter ~f:(fun f -> ignore @@ f x) memoizedFunctions) @@ List.range 1 (nmb_of_calls+1)

let measure_memory_footprint f =
    Gc.set { (Gc.get()) with Gc.Control.space_overhead = 90; Gc.Control.major_heap_increment = 1000};
    Gc.full_major (); 
    let start = Gc.major_plus_minor_words () in
    ignore @@ f (); Gc.major_plus_minor_words () - start

let runTest test =
    let memoryUsage = measure_memory_footprint @@ test in
    Printf.printf "Memory usage: %d\n" memoryUsage; (*  Printf.fprintf stdout "Major heap: %d\n" @@ Gc.heap_words ();*)
    if memoryUsage > 1_000_000 then
        (Gc.print_stat stderr; Printf.fprintf stderr "%d\n" Sys.max_array_length)
    else
        ()

(* Test how much overhead is incurred if functions are memoized localy vs globaly and memo tables are empty *)
let test1 () =
    Printf.printf "Test overhead for one call with varying number of functions\n";
    List.iter ~f:(fun n -> 
            let addFunctions = List.map ~f:(fun x y -> x+y) @@ List.range 1 n in 
            Printf.printf "Number of functions: %d\n" n; 
            runTest (fun () -> testOverhead addFunctions LocalHashTbl); 
            runTest (fun () -> testOverhead addFunctions GlobalHashTbl))
        @@ List.range ~stride:5 0 101
    
let test2 () =
    Printf.printf "Test overhead for one function with varying number of calls\n";
    List.iter ~f:(fun n -> 
            let addFunctions = [fun x -> x+1] in 
            Printf.printf "Number of calls: %d\n" n; 
            runTest (fun () -> testOverhead ~nmb_of_calls:n addFunctions LocalHashTbl); 
            runTest (fun () -> testOverhead ~nmb_of_calls:n addFunctions GlobalHashTbl))
        @@ List.range ~stride:100 0 10001