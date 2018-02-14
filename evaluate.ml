open Core_bench
open Core_kernel

open Travelling_salesman
let benchmark x = Bench.Test.create ~name:(String.concat ["Travelling salesman: "; (string_of_int x) ;" nodes"])  (fun () -> ignore @@ travelling_salesman @@ generate_graph ~range:10 x)

let () =
    Bench.bench @@ List.init 6 (fun i -> benchmark i)