

-- converter from int to string and vice versa from examples

class A2I {

   c2i(char: String): Int {
      if char = "0" then 0 else
      if char = "1" then 1 else
      if char = "2" then 2 else
      if char = "3" then 3 else
      if char = "4" then 4 else
      if char = "5" then 5 else
      if char = "6" then 6 else
      if char = "7" then 7 else
      if char = "8" then 8 else
      if char = "9" then 9 else
      { abort(); 0; }  -- the 0 is needed to satisfy the typchecker
      fi fi fi fi fi fi fi fi fi fi
   };

   i2c(i: Int): String {
      if i = 0 then "0" else
      if i = 1 then "1" else
      if i = 2 then "2" else
      if i = 3 then "3" else
      if i = 4 then "4" else
      if i = 5 then "5" else
      if i = 6 then "6" else
      if i = 7 then "7" else
      if i = 8 then "8" else
      if i = 9 then "9" else
	   { abort(); ""; }  -- the "" is needed to satisfy the typchecker
      fi fi fi fi fi fi fi fi fi fi
   };

   
   a2i(s: String): Int {
	   if s.length() = 1 then c2i(s) else 
         (let next: String <- s.substr(0, s.length() - 1) in 
            a2i(next) * 10 + c2i(s.substr(s.length() - 1, 1))
         )
      fi
     };


    i2a(i: Int): String {
      if i = 0 then "" else 
         (let next: Int <- i / 10 in
            i2a(next).concat(i2c(i - next * 10))
         )
      fi
    };

};

--implementing linked-list style stack

class Linked_list inherits IO{
   next: Linked_list;
   element: String;
   pop_tmp: String;
   n: Int;

   head(): String{
      element
   };

   get_next(): Linked_list{
      next
   };

   size(): Int{
      n
   };

   push(x: String): Object{
      {
         if n = 0 then{
            next <- new Linked_list;
            element <- x;
         }else{
            next.push(element);
            element <- x;
         }fi;
         n <- n + 1;
      }
   };

   pop(): String{
      {
         pop_tmp <- element;
         if n = 1 then {
            element <- "";
         }else{
            element <- next.head();
            next.pop();
         }fi;
         n <- n-1;
         pop_tmp;
      }
   };

   print(): Object{
         if n = 1 then{
            out_string(element);
            out_string("\n");
         }else{
            out_string(element);
            out_string(" ");
            next.print();
         }fi
   };

};

-- Main class Here


class Main inherits IO {
   
   cycle:Bool;
   atoi_obj:A2I;
   curr:String;
   top:String;
   a1:String;
   a2:String;
   stack:Linked_list;
            
   main():Object{{
      cycle<-true;
      stack<-new Linked_list;
      atoi_obj<-new A2I;
      out_string("Commands: number (Operands) \n + (Add numbers) \n s (Swap numbers) \n e (Evaluate) \n d (Display) \n x (Exit) \n");
      while cycle 
         loop{
            out_string(">");
            curr<-in_string();
            if curr="x" then{
               out_string("\n Done \n");
               cycle<-false;
            }
            else
               if curr = "e" then
                  if not stack.size() = 0 then{
                     top<-stack.pop();
                     if top="+" then{
                           a1<-stack.pop();
                           a2<-stack.pop();
                           stack.push(atoi_obj.i2a(atoi_obj.a2i(a1)+atoi_obj.a2i(a2)));
                        }
                     else 
                        if top="s" then{
                           a1<-stack.pop();
                           a2<-stack.pop();
                           stack.push(a1);
                           stack.push(a2);
                        }
                        else {
                           stack.push(top);
                        }fi
                     fi;
                  } 
                  else 
                     cycle<-true 
                  fi
               else 
                  if curr="d" then 
                     stack.print() 
                  else 
                     stack.push(curr)
                  fi
               fi
            fi;
         }pool;
   }};

};
