--- via http://stackoverflow.com/questions/3104722/does-lua-make-use-of-64-bit-integers
require "bit"

-- Lua unsigned 64bit emulated bitwises
-- Slow. But it works.

function i64(v)
 local o = {}; o.l = v; o.h = 0; return o;
end -- constructor +assign 32-bit value

function i64_ax(h,l)
 local o = {}; o.l = l; o.h = h; return o;
end -- +assign 64-bit v.as 2 regs

function i64u(x)
 return ( ( (bit.rshift(x,1) * 2) + bit.band(x,1) ) % (0xFFFFFFFF+1));
end -- keeps [1+0..0xFFFFFFFFF]

function i64_clone(x)
 local o = {}; o.l = x.l; o.h = x.h; return o;
end -- +assign regs

-- Type conversions

function i64_toInt(a)
  return (a.l + (a.h * (0xFFFFFFFF+1)));
end -- value=2^53 or even less, so better use a.l value

function i64_toString(a)
  local s1=string.format("%x",a.l);
  local s2=string.format("%x",a.h);
  local s3="0000000000000000";
  s3=string.sub(s3,1,16-string.len(s1))..s1;
  s3=string.sub(s3,1,8-string.len(s2))..s2..string.sub(s3,9);
  return "0x"..string.upper(s3);
end

-- Bitwise operators (the main functionality)

function i64_and(a,b)
 local o = {}; o.l = i64u( bit.band(a.l, b.l) ); o.h = i64u( bit.band(a.h, b.h) ); return o;
end

function i64_or(a,b)
 local o = {}; o.l = i64u( bit.bor(a.l, b.l) ); o.h = i64u( bit.bor(a.h, b.h) ); return o;
end

function i64_xor(a,b)
 local o = {}; o.l = i64u( bit.bxor(a.l, b.l) ); o.h = i64u( bit.bxor(a.h, b.h) ); return o;
end

function i64_not(a)
 local o = {}; o.l = i64u( bit.bnot(a.l) ); o.h = i64u( bit.bnot(a.h) ); return o;
end

function i64_neg(a)
 return i64_add( i64_not(a), i64(1) );
end  -- negative is inverted and incremented by +1

-- Simple Math-functions

-- just to add, not rounded for overflows
function i64_add(a,b)
 local o = {};
 o.l = a.l + b.l;
 local r = o.l - 0xFFFFFFFF;
 o.h = a.h + b.h;
 if( r>0 ) then
   o.h = o.h + 1;
   o.l = r-1;
 end
 return o;
end

-- verify a>=b before usage
function i64_sub(a,b)
  local o = {}
  o.l = a.l - b.l;
  o.h = a.h - b.h;
  if( o.l<0 ) then
    o.h = o.h - 1;
    o.l = o.l + 0xFFFFFFFF+1;
  end
  return o;
end

-- x n-times
function i64_by(a,n)
 local o = {};
 o.l = a.l;
 o.h = a.h;
 for i=2, n, 1 do
   o = i64_add(o,a);
 end
 return o;
end
-- no divisions   

-- Bit-shifting

function i64_lshift(a,n)
 local o = {};
 if(n==0) then
   o.l=a.l; o.h=a.h;
 else
   if(n<32) then
     o.l= i64u( bit.lshift( a.l, n) ); o.h=i64u( bit.lshift( a.h, n) )+ bit.rshift(a.l, (32-n));
   else
     o.l=0; o.h=i64u( bit.lshift( a.l, (n-32)));
   end
  end
  return o;
end

function i64_rshift(a,n)
 local o = {};
 if(n==0) then
   o.l=a.l; o.h=a.h;
 else
   if(n<32) then
     o.l= bit.rshift(a.l, n)+i64u( bit.lshift(a.h, (32-n))); o.h=bit.rshift(a.h, n);
   else
     o.l=bit.rshift(a.h, (n-32)); o.h=0;
   end
  end
  return o;
end

-- Comparisons

function i64_eq(a,b)
 return ((a.h == b.h) and (a.l == b.l));
end

function i64_ne(a,b)
 return ((a.h ~= b.h) or (a.l ~= b.l));
end

function i64_gt(a,b)
 return ((a.h > b.h) or ((a.h == b.h) and (a.l >  b.l)));
end

function i64_ge(a,b)
 return ((a.h > b.h) or ((a.h == b.h) and (a.l >= b.l)));
end

function i64_lt(a,b)
 return ((a.h < b.h) or ((a.h == b.h) and (a.l <  b.l)));
end

function i64_le(a,b)
 return ((a.h < b.h) or ((a.h == b.h) and (a.l <= b.l)));
end


-- samples
a = i64(1);               -- 1
b = i64_ax(0x1,0);        -- 4294967296 = 2^32
a = i64_lshift(a,32);     -- now i64_eq(a,b)==true
print( i64_toInt(b)+1 );  -- 4294967297

X = i64_ax(0x00FFF0FF, 0xFFF0FFFF);
Y = i64_ax(0x00000FF0, 0xFF0000FF);

-- swap algorithm
X = i64_xor(X,Y);
Y = i64_xor(X,Y);
X = i64_xor(X,Y);

print( "X="..i64_toString(X) ); -- 0x00000FF0FF0000FF
print( "Y="..i64_toString(Y) ); -- 0x00FFF0FFFFF0FFFF
