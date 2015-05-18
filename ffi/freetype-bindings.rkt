#lang racket/base
(require ffi/unsafe
         ffi/unsafe/define
         racket/draw/private/libs)

(define-runtime-lib freetype-lib
  [(unix) #f] ; todo: get unix runtime path
  [(macosx) (ffi-lib "libfreetype.6.dylib")]
  [(windows) (ffi-lib "libfreetype-6.dll")])

(define-ffi-definer define-freetype freetype-lib #:provide provide)

(define-syntax-rule (define-datatype name)
  (define name (_cpointer 'name)))

(define-datatype FT_Library)
(define-datatype FT_F26Dot6)
(define-datatype FT_UInt)
(define-datatype FT_Vector)

(define FT_Error _int)
(define FT_Long _slong)
(define FT_Short _short)
(define FT_UShort _ushort)
(define FT_Fixed _slong)
(define FT_Pos _slong)
(define FT_String _string)
(define FT_Int _sint)

(define-cstruct _FT_Bitmap_Size
  ([height FT_Short]
   [width FT_Short]
   [size FT_Pos]
   [x_ppem FT_Pos]
   [y_ppem FT_Pos]))

(define Foo _FT_Bitmap_Size-pointer)

(define-cstruct _FT_FaceRec
  ([num_faces FT_Long]
   [face_index FT_Long]
   [face_flag FT_Long]
   [style_flags FT_Long]
   #| [num_glyphs FT_Long]
   [family_name FT_String]
   [style_name FT_String]
   [num_fixed_sizes FT_Int]
     
[available_sizes _FT_Bitmap_Size]
   [num_charmaps FT_Int]
   ; restart here

   [charmaps FT_CharMap]
   [generic FT_Generic]
   [bbox FT_BBox]
   [units_per_EM FT_UShort]
   [ascender FT_Short]
   [descender FT_Short]
   [height FT_Short]
   [max_advance_width FT_Short]
   [max_advance_height FT_Short]
   [underline_position FT_Short]
   [underline_thickness FT_Short]
   [glyph FT_GlyphSlot]
   [size FT_Size]
   [charmap FT_CharMap]
   [driver FT_Driver]
   [memory FT_Memory]
   [stream FT_Stream]
   [sizes_list FT_ListRec]
   [autohint FT_Generic]
   [extensions _void]
   [internal FT_Face_Internal]
|#))

(define FT_Face _FT_FaceRec-pointer)

#;(define FT_CharMap _FT_CharMapRec)

#;(define-cstruct _FT_CharMapRec
  ([face FT_Face]
   [encoding FT_Encoding]
   [platform_id FT_UShort]
   [encoding_id FT_UShort]))



(define-cstruct _FT_Size_Metrics
  ([x_ppem FT_UShort]
   [y_ppem FT_UShort]
   [x_scale FT_Fixed]
   [y_scale FT_Fixed]
   [ascender FT_Pos]
   [descender FT_Pos]
   [height FT_Pos]
   [max_advance FT_Pos]))





(define-freetype FT_Init_FreeType (_fun (ftlp : (_ptr o FT_Library)) -> (err : FT_Error) -> (values ftlp err)))

(define-freetype FT_Done_FreeType (_fun FT_Library ->  (err : FT_Error)))

(define-freetype FT_New_Face (_fun FT_Library _file FT_Long (ftfp : (_ptr o FT_Face)) -> (err : FT_Error) -> (values ftfp err)))

(define-freetype FT_Done_Face (_fun FT_Face -> _void))

;(define-freetype FT_Get_Kerning (_fun FT_Face FT_UInt FT_UInt FT_UInt FT_Vector -> _void))


(define-values (ftlib init-err) (FT_Init_FreeType))
init-err

(define-values (ftface face-err) (FT_New_Face ftlib (string->path "charter.ttf") 0))
ftface
face-err
;(FT_FaceRec->list ftface)
(FT_Done_FreeType ftlib)

