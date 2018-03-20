open Incremental_lib
open ReactiveCaml

module Inc = Incremental.Make ()
module Var = Inc.Var

(* tests for ReactiveCaml *)
let x0 = return 7
let x1 = return 8
let x2 = return 9
let x3 = return 1
let x4 = return 2
let sum3 = map3 x0 x1 x2 (fun x y z -> x + y + z)
let sum2 = map2 x3 x4 (fun x y -> x + y)
let result = map2 sum2 sum3 ~f:(fun x y -> x*y)


(* same tests in Incremental *)
let x0_inc = Var.create 7
let x1_inc = Var.create 8
let x2_inc = Var.create 9
let x3_inc = Var.create 1
let x4_inc = Var.create 2
let sum3_inc = Inc.map3 (Var.watch x0_inc) (Var.watch x1_inc) (Var.watch x2_inc) (fun x y z -> x + y + z)
let sum2_inc = Inc.map2 (Var.watch x3_inc) (Var.watch x4_inc) (fun x y -> x + y)
let result_inc = Inc.map2 sum2_inc sum3_inc ~f:(fun x y -> x*y)

let result_obs = Inc.observe result_inc