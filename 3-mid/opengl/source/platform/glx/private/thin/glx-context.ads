with
     glx.Pointers;


package glx.Context
is
   subtype Item is Pointers.ContextRec_pointer;

   type Pointer         is access all Item;
   type Pointer_pointer is access all Pointer;

   type Items    is array (C.size_t range <>) of aliased Item;
   type Pointers is array (C.size_t range <>) of aliased Pointer;


end glx.Context;
