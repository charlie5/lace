------------------
Lace Coding Style
------------------


Identifiers
~~~~~~~~~~~
   Length
   ~~~~~~
      - Shorter is preferred when ambiguity or loss of clarity does not result.

   Casing
   ~~~~~~
      - Use uppercase for the first letter of nouns.
      - Use lowercase for the first letter of all other words.
      
      example:

```ada
procedure reverse_Elements (in_Container : in Container);
   

      - Use lowercase when referencing namespace packages.
      example:

     
```ada 
with
     lace.Events,
     ada.Containers;
```


Context Clauses
~~~~~~~~~~~~~~~
   - Group by namespace.
   - Order with most specific groups/packages first, more general ones later.
   
   example:

```ada 
with 
     my_Project.my_Types,
     my_Project.my_Functions,

     other_Project.my_Types,
     other_Project.my_Functions,
	   
     ada.Strings,
     ada.Exceptions;
```


Class Packages
~~~~~~~~~~~~~~

   - ...