(*
  This module defines a trivial kami module that can be used to
  test the IceStorm toolchain.
*)
Require Import Kami.All.
Require Import Kami.Compiler.Compiler.
Require Import Kami.Compiler.Rtl.
Require Import Kami.Compiler.Test.
Require Import Kami.Simulator.NativeTest.
Require Import Kami.Simulator.CoqSim.Simulator.
Require Import Kami.Simulator.CoqSim.HaskellTypes.
Require Import Kami.Simulator.CoqSim.RegisterFile.
Require Import Kami.Simulator.CoqSim.Eval.
Require Import Kami.WfActionT.
Require Import Kami.SignatureMatch.
Require Import List.
Import ListNotations.

Section test.

Open Scope kami_expr.
Open Scope kami_action.

Local Definition Counter := Bit 26.

Local Definition StateInit  := 0.
Local Definition StateWrite := 1.
Local Definition StateRead  := 2.
Local Definition State := Bit 2.

Section ty.
  Variable ty : Kind -> Type.

  Local Definition WriteReq : Kind :=
    STRUCT_TYPE {
      "val"          :: Bit 16;
      "addr"         :: Bit 16;
      "chipEnable"   :: Bool; (* false = enabled *)
      "writeEnable"  :: Bool; (* false = enabled *)
      "outputEnable" :: Bool; (* false = enabled *)
      "lowerByte"    :: Bool; (* false = write lower byte *)
      "upperByte"    :: Bool  (* false = write upper byte *)
    }.

  Local Definition ReadReq : Kind :=
    STRUCT_TYPE {
      "addr"         :: Bit 16;
      "chipEnable"   :: Bool; (* false = enabled *)
      "writeEnable"  :: Bool; (* false = enabled *)
      "outputEnable" :: Bool; (* false = enabled *)
      "lowerByte"    :: Bool; (* false = write lower byte *)
      "upperByte"    :: Bool  (* false = write upper byte *)
    }.

  Local Definition ReadRes : Kind := Bit 16.

  Definition writeMem : ActionT ty Void :=
    LET req : WriteReq <-
      STRUCT {
        "val"          ::= $255;    (* bit 21 *)
        "addr"         ::= $562;    (* bit 5 *)
        "chipEnable"   ::= $$false; (* bit 4 *)
        "writeEnable"  ::= $$false; (* bit 3 *)
        "outputEnable" ::= $$true;  (* bit 2 *)
        "lowerByte"    ::= $$false; (* bit 1 *)
        "upperByte"    ::= $$false  (* bit 0 *)
      };
    Call "memWrite" (pack #req : Bit (size WriteReq));
    Retv.

  Definition readMem : ActionT ty (Bit 16) :=
    LET req : ReadReq <-
      STRUCT {
        "addr"         ::= $562;    (* bit 5 - 20 *)
        "chipEnable"   ::= $$false; (* bit 4 *)
        "writeEnable"  ::= $$true;  (* bit 3 *)
        "outputEnable" ::= $$false; (* bit 2 *)
        "lowerByte"    ::= $$false; (* bit 1 *)
        "upperByte"    ::= $$false  (* bit 0 *)
      };
    Call val : Bit 16 <- "memRead" (pack #req : Bit (size ReadReq));
    Ret #val.

  (* State machine transitions. *)
  Definition toggleState : ActionT ty State :=
    Read state      : State   <- "state";
    Read counter    : Counter <- "counter";
    Write "counter" : Counter <- #counter + $1;
    If #counter == $0
      then
        Write "state" : State <- 
          Switch #state Retn State With {
            ($StateInit  : State @# ty) ::= ($StateWrite : State @# ty);
            ($StateWrite : State @# ty) ::= ($StateRead  : State @# ty);
            ($StateRead  : State @# ty) ::= ($StateRead  : State @# ty)
          };
        Retv;
    Ret #state.

End ty.

Local Definition testBaseModule : BaseModule :=
  MODULE {
    Register "counter" : Counter <- $1%word with
    Register "state" : State <- ConstBit $StateWrite with

    Rule "testRule" :=
      LETA state : State <- toggleState _;
      If #state == $StateWrite
        then
          LETA _ <- writeMem _;
          Call "lightLED1" ();
          Retv;
      If #state == $StateRead
        then
          LETA val : Bit 16 <- readMem _;
          Call "lightLED2" ();
          If #val == $255
            then
              Call "lightLED3" ();
              Retv;
          Retv;
      Retv
  }.

Definition testModule : Mod := Base testBaseModule.

Close Scope kami_action.
Close Scope kami_expr.

End test.

Unset Extraction Optimize.
Separate Extraction
  testModule

  predPack
  orKind
  predPackOr
  createWriteRq
  createWriteRqMask
  pointwiseIntersectionNoMask
  pointwiseIntersectionMask
  pointwiseIntersection
  pointwiseBypass
  getDefaultConstFullKind
  CAS_RulesRf
  Fin_to_list

  getCallsWithSignPerMod
  RtlExpr'
  getRtl

  CompActionSimple
  RmeSimple
  RtlModule
  getRules

  separateModRemove
  separateModHidesNoInline


  testReg
  testAsync
  testSyncIsAddr
  testSyncNotIsAddr
  testNative

  print_Val2
  init_state
  sim_step
  initialize_files_zero
  option_map
  .
