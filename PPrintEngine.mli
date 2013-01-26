(**************************************************************************)
(*  PPrint                                                                *)
(*                                                                        *)
(*  Authors: François Pottier and Nicolas Pouillard,                      *)
(*           INRIA Paris-Rocquencourt                                     *)
(*  Version: 20100311                                                     *)
(*                                                                        *)
(*  The copyright to this code is held by Institut National de Recherche  *)
(*  en Informatique et en Automatique (INRIA). All rights reserved. This  *)
(*  file is distributed under the license CeCILL-C (see file LICENSE).    *)
(*                                                                        *)
(**************************************************************************)

(** Pprint is an adaptation of Daan Leijen's [PPrint] library, which itself is
   based on the ideas developed by Philip Wadler in ``A Prettier Printer''. *)

(* ------------------------------------------------------------------------- *)

(** {4 Basic combinators for building documents.} *)

type document

val empty: document
val hardline: document
val char: char -> document
val substring: string -> int -> int -> document
val fancysubstring : string -> int -> int -> int -> document
val text: string -> document
val blank: int -> document
val (^^): document -> document -> document
val nest: int -> document -> document
val column: (int -> document) -> document
val nesting: (int -> document) -> document
val group: document -> document
val ifflat: document -> document -> document

(* ------------------------------------------------------------------------- *)

(** {4 Low-level combinators for alignment and indentation.} *)

val align: document -> document
val hang: int -> document -> document
val indent: int -> document -> document

(* ------------------------------------------------------------------------- *)

(** {4 High-level combinators for building documents.} *)

(** [break n] Puts [n] spaces in flat mode and a new line otherwise.
   Equivalent to: [ifflat (String.make n ' ') hardline] *)
val break: int -> document

(** [break0] equivalent to [break 0] *)
val break0: document

(** [break1] equivalent to [break 1] *)
val break1: document

val string: string -> document
val fancystring: string -> int -> document
val fancy: (string -> int) -> string -> document
val words: string -> document

val lparen: document
val rparen: document
val langle: document
val rangle: document
val lbrace: document
val rbrace: document
val lbracket: document
val rbracket: document
val squote: document
val dquote: document
val bquote: document
val semi: document
val colon: document
val comma: document
val space: document
val dot: document
val sharp: document
val backslash: document
val equals: document
val qmark: document
val tilde: document
val at: document
val percent: document
val dollar: document
val caret: document
val ampersand: document
val star: document
val plus: document
val minus: document
val underscore: document
val bang: document
val bar: document

val squotes: document -> document
val dquotes: document -> document
val bquotes: document -> document
val braces: document -> document
val parens: document -> document
val angles: document -> document
val brackets: document -> document

val fold: (document -> document -> document) -> document list -> document
val fold1: (document -> document -> document) -> document list -> document
val fold1map: (document -> document -> document) -> ('a -> document) -> 'a list -> document
val sepmap: document -> ('a -> document) -> 'a list -> document

val optional: ('a -> document) -> 'a option -> document

(** [prefix left right]
      Flat layout: [left] [right]
      Otherwise:   [left]
                     [right]
 *)
val prefix: string -> document -> document

(** [infix middle left right]
      Flat layout: [left] [middle] [right]
      Otherwise:   [left] [middle]
                     [right]
 *)
val infix: string -> document -> document -> document

(** [infix_com middle left right]
      Flat layout: [left][middle] [right]
      Otherwise:   [left][middle]
                     [right]
 *)
val infix_com: string -> document -> document -> document

(** [infix_dot middle left right]
      Flat layout: [left][middle][right]
      Otherwise: [left][middle]
                    [right]
 *)
val infix_dot: string -> document -> document -> document

(** [surround nesting break open_doc contents close_doc] *)
val surround: int -> document -> document -> document -> document -> document

(** [surround1 open_txt contents close_txt]
     Flat:      [open_txt][contents][close_txt]
     Otherwise: [open_txt]
                 [contents]
                [close_txt]
 *)
val surround1: string -> document -> string -> document

(** [surround2 open_txt contents close_txt]
     Flat:      [open_txt] [contents] [close_txt]
     Otherwise: [open_txt]
                  [contents]
                [close_txt]
 *)
val surround2: string -> document -> string -> document

(** [soft_surround nesting break open_doc contents close_doc] *)
val soft_surround: int -> document -> document -> document -> document -> document

(** [seq indent break empty_seq open_seq sep_seq close_seq contents] *)
val seq: int -> document -> document -> document -> document -> document ->
         document list -> document 

(** [seq1 open_seq sep_seq close_seq contents]
     Flat layout: [open_seq][contents][sep_seq]...[sep_seq][contents][close_seq]
     Otherwise:   [open_seq]
                   [contents][sep_seq]...[sep_seq][contents]
                  [close_seq]
 *)
val seq1: string -> string -> string -> document list -> document

(** [seq2 open_seq sep_seq close_seq contents]
     Flat layout: [open_seq] [contents][sep_seq]...[sep_seq][contents] [close_seq]
     Otherwise:   [open_seq]
                    [contents][sep_seq]...[sep_seq][contents]
                  [close_seq]
 *)
val seq2: string -> string -> string -> document list -> document

(** [group1 d] equivalent to [group (nest 1 d)] *)
val group1: document -> document

(** [group2 d] equivalent to [group (nest 2 d)] *)
val group2: document -> document

module Operators : sig
  val ( ^^ ) : document -> document -> document
  val ( !^ ) : string -> document
  val ( ^/^ ) : document -> document -> document
  val ( ^//^ ) : document -> document -> document
  val ( ^@^ ) : document -> document -> document
  val ( ^@@^ ) : document -> document -> document
end

(* ------------------------------------------------------------------------- *)

(** {4 Renderers to output channels and to memory buffers.} *)

open PPrintRenderer

module Channel : RENDERER with type channel = out_channel and type document = document

module PpBuffer : RENDERER with type channel = Buffer.t and type document = document

module Formatter : RENDERER with type channel = Format.formatter and type document = document

(* ------------------------------------------------------------------------- *)

type constructor = string
type type_name = string
type record_field = string
type tag = int

(** A signature for value representations.
   This is compatible with the associated Camlp4 generator:
     Camlp4RepresentationGenerator *)

module type REPRESENTATION = sig
  (** The type of value representation *)
  type representation

  (** [variant type_name data_constructor_name tag arguments]
        Given information about the variant and its arguments,
        this function produces a new value representation. *)
  val variant : type_name -> constructor -> tag -> representation list -> representation

  (** [record type_name fields]
        Given a type name and a list of record fields, this function
        produces the value representation of a record. *)
  val record : type_name -> (record_field * representation) list -> representation

  (** [tuple arguments]
        Given a list of value representation this function produces
        a new value representation. *)
  val tuple : representation list -> representation

  (* ------------------------------------------------------------------------- *)

  (** {4 Value representation for primitive types.} *)

  val string : string -> representation
  val int : int -> representation
  val int32 : int32 -> representation
  val int64 : int64 -> representation
  val nativeint : nativeint -> representation
  val float : float -> representation
  val char : char -> representation
  val bool : bool -> representation
  val option : ('a -> representation) -> 'a option -> representation
  val list : ('a -> representation) -> 'a list -> representation
  val array : ('a -> representation) -> 'a array -> representation
  val ref : ('a -> representation) -> 'a ref -> representation

  (** Value representation for any other value. *)
  val unknown : type_name -> 'a -> representation
end

(** A signature for source printers. *)

module type DOCUMENT_REPRESENTATION =
  REPRESENTATION with type representation = document

module ML : DOCUMENT_REPRESENTATION

(** {4 Deprecated} *)
val line: document
val linebreak: document
val softline: document
val softbreak: document