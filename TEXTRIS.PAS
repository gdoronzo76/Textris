Program Textris;

Uses Crt,Dos;

type

cord=record
x,y:byte;
end;


tetra_type=array[0..3] of cord;

const

lungoh:tetra_type=((x:0;y:0),
                   (x:1;y:0),
                   (x:2;y:0),
                   (x:3;y:0));

quadro:tetra_type=((x:0;y:0),
                   (x:1;y:0),
                   (x:0;y:1),
                   (x:1;y:1));

zetah :tetra_type=((x:0;y:0),
                   (x:1;y:0),
                   (x:1;y:1),
                   (x:2;y:1));

esseh :tetra_type=((x:1;y:0),
                   (x:2;y:0),
                   (x:0;y:1),
                   (x:1;y:1));
ti180:tetra_type=((x:0;y:0),
                   (x:1;y:0),
                   (x:2;y:0),
                   (x:1;y:1));
j180:tetra_type=((x:0;y:0),
                   (x:1;y:0),
                   (x:2;y:0),
                   (x:2;y:1));
l180:tetra_type=((x:0;y:0),
                   (x:1;y:0),
                   (x:2;y:0),
                   (x:0;y:1));

var
schema:array[0..9,0..19] of boolean;
a:integer;
lines,score,hs,level,ttime:integer;
uni:tetra_type;
gameover:boolean;
lt,tsound:longint;
tet,rot,nex:byte;
levelstr,yes,tc,oc:string;
oldstr:array [0..19] of string;

procedure tetra;forward;


{____________________________________________________________________________}
procedure load_highscore;
var f:file of integer;
begin
 {$I-}
assign(f,'textris.hi');
reset(f);
if IOResult<>0 then hs:=0 else
   begin
   read(f,hs);
   close(f);
   end;
 {$I+}
end;
{____________________________________________________________________________}
procedure save_highscore;
var f:file of integer;
begin
assign(f,'textris.hi');
rewrite(f);
write(f,score);
close(f);
end;
{____________________________________________________________________________}
function playagain:boolean;
var ris:string;
begin
repeat
if (yes='y') or (yes='Y') then
   begin
            gotoxy(24,10);
            write('<!==============================!>');
            gotoxy(24,11);
            write('<!                              !>');
            gotoxy(24,12);
            write('<!  Game Over. Play Again? Y/N  !>');
            gotoxy(24,13);
            write('<!                              !>');
            gotoxy(24,14);
            write('<!==============================!>');
   end
   else
   begin
            gotoxy(24,10);
            write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
            gotoxy(24,11);
            write('³                                ³');
            gotoxy(24,12);
            write('³   Game Over. Play Again? Y/N   ³');
            gotoxy(24,13);
            write('³                                ³');
            gotoxy(24,14);
            write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
   end;
   ris:=readkey;
   until (ris='y') or (ris='Y') or (ris='n') or (ris='N');
   if (ris='y') or (ris='Y') then playagain:=true else playagain:=false;
end;
{____________________________________________________________________________}
Procedure Background;
begin
if (yes='y') or (yes='Y') then
   begin
        tc:='()';
        oc:='[]';
        for a:=0 to 19 do
            begin
            gotoxy(29,a+1);
            write('<! . . . . . . . . . .!>');
            end;
        gotoxy(29,21);
        write('<!====================!>');
        gotoxy(31,22);
        write('\/\/\/\/\/\/\/\/\/\/');
   end
   else
   begin
        tc:='±±';
        oc:='ÛÛ';
        for a:=0 to 19 do
            begin
            gotoxy(30,a+1);
            write('³ . . . . . . . . . .³');
            end;
        gotoxy(30,21);
        write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');

end;
end;
{____________________________________________________________________________}
Procedure CSchema;
var a,b:byte;

begin
for a:=0 to 9 do for b:=0 to 19 do schema[a,b]:=false;
end;


{____________________________________________________________________________}
Procedure RSchema;

var a,b:byte;

begin
for a:=0 to 9 do for b:=0 to 19 do if random(2)=0 then schema[a,b]:=false else schema[a,b]:=true;
end;


{____________________________________________________________________________}
Function line2str(line:byte):string;

var a:byte;
s:string;

begin
s:='';
for a:=0 to 9 do if schema[a,line] then s:=s+oc else
if ((uni[0].x=a) and (uni[0].y=line)) or
   ((uni[1].x=a) and (uni[1].y=line)) or
   ((uni[2].x=a) and (uni[2].y=line)) or
   ((uni[3].x=a) and (uni[3].y=line)) then s:=s+tc else s:=s+' .';
line2str:=s;
end;
{____________________________________________________________________________}
function tick_time(iv:byte):boolean;
var
tm,a:longint;
void,m1,s1,c1:word;

begin
gettime(void,m1,s1,c1);
a:=m1*6000+s1*100+c1;
tm:=abs(a-lt);
if tm>iv then
           begin
           tick_time:=true;
           lt:=a;
           end else tick_time:=false;
if tsound=0 then
            begin
            sound(3000);
            tsound:=a;
            end else
            if a-tsound>10 then nosound;
end;
{____________________________________________________________________________}
Procedure Paint2;
var
a:byte;
s:string;
begin
gotoxy(8,1);
write(lines);
gotoxy(8,2);
write(score);
gotoxy(8,3);
write(level);
for a:=0 to 19 do
    begin
    s:=line2str(a);
    if not(s=oldstr[a]) then
       begin
       gotoxy(31,a+1);
       write(s);
       oldstr[a]:=s;
       end;
    end;
end;
{____________________________________________________________________________}
Procedure dunit;
var a:byte;
    down:boolean;
begin
down:=true;
for a:=0 to 3 do
    if (schema[uni[a].x,uni[a].y]) and (uni[a].y=0) then begin
                                                          gameover:=true;
                                                          exit;
                                                          end;
for a:=0 to 3 do
    if (uni[a].y>18) then down:=false
    else if (schema[uni[a].x,uni[a].y+1]) then down:=false;

if down then for a:=0 to 3 do uni[a].y:=uni[a].y+1
        else
        begin
        for a:=0 to 3 do schema[uni[a].x,uni[a].y]:=true;
        a:=uni[0].y;
        if a<uni[1].y then a:=uni[1].y;
        if a<uni[2].y then a:=uni[2].y;
        if a<uni[3].y then a:=uni[3].y;
        score:=score+19-a+(level+1)*3;
        tetra;
        end;
end;
{____________________________________________________________________________}
procedure up(l:byte);
var a,b:byte;
begin
inc(lines);
for a:=l downto 1 do
for b:=0 to 9 do
schema[b,a]:=schema[b,a-1];
for b:=0 to 9 do schema[b,0]:=false;
end;
{____________________________________________________________________________}
Procedure Checkline;
var a,b:byte;
    upped:boolean;
begin
a:=19;
repeat
    upped:=true;
    for b:=0 to 9 do if not(schema[b,a]) then upped:=false;
    if upped then up(a) else dec(a);
 until (a=0);
end;
{____________________________________________________________________________}
procedure init_unit(t:tetra_type);
begin
uni:=t;
uni[0].x:=uni[0].x+4;
uni[1].x:=uni[1].x+4;
uni[2].x:=uni[2].x+4;
uni[3].x:=uni[3].x+4;
end;
{____________________________________________________________________________}
procedure shownext(t:tetra_type);
const xx=20;yy=11;
var a:byte;
begin
gotoxy(xx,yy);write('        ');
gotoxy(xx,yy+1);write('        ');
for a:=0 to 3 do
        begin
        gotoxy(xx+t[a].x*2,yy+t[a].y);
        write(tc);
        end;
end;
{____________________________________________________________________________}
procedure tetra;
var ch:char;
begin
while keypressed do
ch:=readkey;

if nex=8 then nex:=random(7);
tet:=nex;
rot:=0;
case tet of
 0:init_unit(lungoh);
 1:init_unit(quadro);
 2:init_unit(zetah);
 3:init_unit(esseh);
 4:init_unit(ti180);
 5:init_unit(j180);
 6:init_unit(l180);
end;
nex:=random(7);
case nex of
 0:shownext(lungoh);
 1:shownext(quadro);
 2:shownext(zetah);
 3:shownext(esseh);
 4:shownext(ti180);
 5:shownext(j180);
 6:shownext(l180);
end;
end;
{____________________________________________________________________________}
Procedure Left;
var a:byte;
begin
if (uni[0].x>0) then if (schema[uni[0].x-1,uni[0].y]=false) then
if (uni[1].x>0) then if (schema[uni[1].x-1,uni[1].y]=false) then
if (uni[2].x>0) then if (schema[uni[2].x-1,uni[2].y]=false) then
if (uni[3].x>0) then if (schema[uni[3].x-1,uni[3].y]=false) then
for a:=0 to 3 do dec(uni[a].x);
Paint2;
end;
{____________________________________________________________________________}
Procedure Right;
var a:byte;
begin
if (uni[0].x<9) then if (schema[uni[0].x+1,uni[0].y]=false) then
if (uni[1].x<9) then if (schema[uni[1].x+1,uni[1].y]=false) then
if (uni[2].x<9) then if (schema[uni[2].x+1,uni[2].y]=false) then
if (uni[3].x<9) then if (schema[uni[3].x+1,uni[3].y]=false) then
for a:=0 to 3 do inc(uni[a].x);
Paint2;
end;
{____________________________________________________________________________}
Procedure Down;
var a:byte;
begin
if (uni[0].y<19) then if (schema[uni[0].x,uni[0].y+1]=false) then
if (uni[1].y<19) then if (schema[uni[1].x,uni[1].y+1]=false) then
if (uni[2].y<19) then if (schema[uni[2].x,uni[2].y+1]=false) then
if (uni[3].y<19) then if (schema[uni[3].x,uni[3].y+1]=false) then
for a:=0 to 3 do inc(uni[a].y);
Paint2;
end;
{____________________________________________________________________________}
Procedure Rotate;
begin
case tet of

 0: if rot=0 then
        begin
        if (uni[0].x<9) and (uni[0].y<19) then
           if not(schema[uni[0].x+1,uni[0].y+1]) then
           if (uni[2].x>1) and (uni[2].y>1) then
           if not(schema[uni[2].x-1,uni[2].y-1]) then
           if (uni[3].x>0) and (uni[3].y>0) then
           if not(schema[uni[3].x-2,uni[3].y-2]) then
           begin
           rot:=1;
           uni[0].x:=uni[0].x+1;
           uni[0].y:=uni[0].y+1;
           uni[2].x:=uni[2].x-1;
           uni[2].y:=uni[2].y-1;
           uni[3].x:=uni[3].x-2;
           uni[3].y:=uni[3].y-2;
           end;
        end else
        begin
        if (uni[0].x>0) and (uni[0].y>0) then
           if not(schema[uni[0].x-1,uni[0].y-1]) then
           if (uni[2].x<9) and (uni[2].y<19) then
           if not(schema[uni[2].x+1,uni[2].y+1]) then
           if (uni[3].x<8) and (uni[3].y<18) then
           if not(schema[uni[3].x+2,uni[3].y+2]) then
           begin
           rot:=0;
           uni[0].x:=uni[0].x-1;
           uni[0].y:=uni[0].y-1;
           uni[2].x:=uni[2].x+1;
           uni[2].y:=uni[2].y+1;
           uni[3].x:=uni[3].x+2;
           uni[3].y:=uni[3].y+2;
           end;
           end;

 1:exit;

 2:if rot=0 then
        begin
        if (uni[0].x<8) and (uni[1].y<18) then
           if not(schema[uni[0].x+2,uni[0].y]) then
           if not(schema[uni[1].x,uni[1].y+2]) then
           begin
           rot:=1;
           uni[0].x:=uni[0].x+2;
           uni[1].y:=uni[1].y+2;
           end;
        end else
        begin
        if (uni[0].x>1) and (uni[1].y>1) then
           if not(schema[uni[0].x-2,uni[0].y]) then
           if not(schema[uni[1].x,uni[1].y-2]) then
           begin
           rot:=0;
           uni[0].x:=uni[0].x-2;
           uni[1].y:=uni[1].y-2;
           end;
           end;

 3:if rot=0 then
        begin
        if (uni[0].y<18) and (uni[1].x>1) then
           if not(schema[uni[0].x,uni[0].y+2]) then
           if not(schema[uni[1].x-2,uni[1].y]) then
           begin
           rot:=1;
           uni[0].y:=uni[0].y+2;
           uni[1].x:=uni[1].x-2;
           end;
        end else
        begin
        if (uni[0].y>1) and (uni[1].x<8) then
           if not(schema[uni[0].x,uni[0].y-2]) then
           if not(schema[uni[1].x+2,uni[1].y]) then
           begin
           rot:=0;
           uni[0].y:=uni[0].y-2;
           uni[1].x:=uni[1].x+2;
           end;
           end;

 4:case rot of
      0:begin
        if (uni[2].x>0) and (uni[2].y>0) then
           if not(schema[uni[2].x-1,uni[2].y-1]) then
           begin
           rot:=1;
           uni[2].x:=uni[2].x-1;
           uni[2].y:=uni[2].y-1;
           end;
        end;
      1:begin
        if (uni[3].x<9) and (uni[3].y>0) then
           if not(schema[uni[3].x-1,uni[3].y-1]) then
           begin
           rot:=2;
           uni[3].x:=uni[3].x+1;
           uni[3].y:=uni[3].y-1;
           end;
        end;
      2:begin
        if (uni[0].x<9) and (uni[0].y<19) then
           if not(schema[uni[0].x+1,uni[0].y+1]) then
           begin
           rot:=3;
           uni[0].x:=uni[0].x+1;
           uni[0].y:=uni[0].y+1;
           end;
        end;
      3:begin
        if (uni[2].x<9) and (uni[2].y<19) then
        if (uni[3].x>0) and (uni[3].y>0) then
        if (uni[0].x>0) and (uni[0].y>0) then
           if not(schema[uni[2].x+1,uni[2].y+1]) then
           if not(schema[uni[3].x-1,uni[3].y+1]) then
           if not(schema[uni[0].x-1,uni[0].y-1]) then
           begin
           rot:=0;
           uni[2].x:=uni[2].x+1;
           uni[2].y:=uni[2].y+1;
           uni[3].x:=uni[3].x-1;
           uni[3].y:=uni[3].y+1;
           uni[0].x:=uni[0].x-1;
           uni[0].y:=uni[0].y-1;
           end;
        end;
      end;

 5:case rot of
      0:begin
        if (uni[0].x<9) and (uni[0].y>0) then
        if (uni[2].x>0) and (uni[2].y<19) then
        if (uni[3].x>1) then
           if not(schema[uni[0].x+1,uni[0].y-1]) then
           if not(schema[uni[2].x-1,uni[2].y+1]) then
           if not(schema[uni[3].x-2,uni[3].y]) then
           begin
           rot:=1;
           uni[0].x:=uni[0].x+1;
           uni[0].y:=uni[0].y-1;
           uni[2].x:=uni[2].x-1;
           uni[2].y:=uni[2].y+1;
           uni[3].x:=uni[3].x-2;
           end;
        end;
      1:begin
        if (uni[0].x>0) and (uni[0].y>0) then
        if (uni[2].x<9) and (uni[2].y<19) then
        if (uni[3].y>1) then
           if not(schema[uni[0].x+1,uni[0].y+1]) then
           if not(schema[uni[2].x-1,uni[2].y-1]) then
           if not(schema[uni[3].x,uni[3].y-2]) then
           begin
           rot:=2;
           uni[0].x:=uni[0].x+1;
           uni[0].y:=uni[0].y+1;
           uni[2].x:=uni[2].x-1;
           uni[2].y:=uni[2].y-1;
           uni[3].y:=uni[3].y-2;
           end;
        end;
      2:begin
        if (uni[0].x>0) and (uni[0].y<19) then
        if (uni[2].x<9) and (uni[2].y>0) then
        if (uni[3].x<8) then
           if not(schema[uni[0].x-1,uni[0].y+1]) then
           if not(schema[uni[2].x+1,uni[2].y-1]) then
           if not(schema[uni[3].x+2,uni[3].y]) then
           begin
           rot:=3;
           uni[0].x:=uni[0].x-1;
           uni[0].y:=uni[0].y+1;
           uni[2].x:=uni[2].x+1;
           uni[2].y:=uni[2].y-1;
           uni[3].x:=uni[3].x+2;
           end;
        end;
      3:begin
        if (uni[0].x>0) and (uni[0].y>0) then
        if (uni[2].x<9) and (uni[2].y<19) then
        if (uni[3].y<18) then
           if not(schema[uni[0].x-1,uni[0].y-1]) then
           if not(schema[uni[2].x+1,uni[2].y+1]) then
           if not(schema[uni[3].x,uni[3].y+2]) then
           begin
           rot:=0;
           uni[0].x:=uni[0].x-1;
           uni[0].y:=uni[0].y-1;
           uni[2].x:=uni[2].x+1;
           uni[2].y:=uni[2].y+1;
           uni[3].y:=uni[3].y+2;
           end;
        end;
      end;

 6:case rot of
      0:begin
        if (uni[0].x<9) and (uni[0].y>0) then
        if (uni[2].x>0) and (uni[2].y<19) then
        if (uni[3].y>1) then
           if not(schema[uni[0].x+1,uni[0].y-1]) then
           if not(schema[uni[2].x-1,uni[2].y+1]) then
           if not(schema[uni[3].x,uni[3].y-2]) then
           begin
           rot:=1;
           uni[0].x:=uni[0].x+1;
           uni[0].y:=uni[0].y-1;
           uni[2].x:=uni[2].x-1;
           uni[2].y:=uni[2].y+1;
           uni[3].y:=uni[3].y-2;
           end;
        end;
      1:begin
        if (uni[0].x>0) and (uni[0].y>0) then
        if (uni[2].x<9) and (uni[2].y<19) then
        if (uni[3].x<8) then
           if not(schema[uni[0].x+1,uni[0].y+1]) then
           if not(schema[uni[2].x-1,uni[2].y-1]) then
           if not(schema[uni[3].x+2,uni[3].y]) then
           begin
           rot:=2;
           uni[0].x:=uni[0].x+1;
           uni[0].y:=uni[0].y+1;
           uni[2].x:=uni[2].x-1;
           uni[2].y:=uni[2].y-1;
           uni[3].x:=uni[3].x+2;
           end;
        end;
      2:begin
        if (uni[0].x>0) and (uni[0].y<19) then
        if (uni[2].x<9) and (uni[2].y>0) then
        if (uni[3].y<18) then
           if not(schema[uni[0].x-1,uni[0].y+1]) then
           if not(schema[uni[2].x+1,uni[2].y-1]) then
           if not(schema[uni[3].x,uni[3].y+2]) then
           begin
           rot:=3;
           uni[0].x:=uni[0].x-1;
           uni[0].y:=uni[0].y+1;
           uni[2].x:=uni[2].x+1;
           uni[2].y:=uni[2].y-1;
           uni[3].y:=uni[3].y+2;
           end;
        end;
      3:begin
        if (uni[0].x>0) and (uni[0].y>0) then
        if (uni[2].x<9) and (uni[2].y<19) then
        if (uni[3].x>1) then
           if not(schema[uni[0].x-1,uni[0].y-1]) then
           if not(schema[uni[2].x+1,uni[2].y+1]) then
           if not(schema[uni[3].x-2,uni[3].y]) then
           begin
           rot:=0;
           uni[0].x:=uni[0].x-1;
           uni[0].y:=uni[0].y-1;
           uni[2].x:=uni[2].x+1;
           uni[2].y:=uni[2].y+1;
           uni[3].x:=uni[3].x-2;
           end;
        end;
      end;
end;
paint2;
end;
{____________________________________________________________________________}
Procedure Start_Game;
var
ch:char;

begin

repeat
clrscr;
writeln('TEXTRIS');
writeln('Remake of original Tetris on Electronika 60 in 1984');
writeln('Programmed by G. D'+chr(39)+'Oronzo');
writeln;
write('Enter Game Level (0-9): ');
readln(levelstr);
val(levelstr,level,score);
until (level>-1) and (level<10) and (score=0);

repeat
write('Original Charset? (Y/N) ');
readln(yes);
until (yes='Y') or (yes='y') or (yes='N') or (yes='n');

ttime:=100 div (level+1);
score:=0;
randomize;
lines:=0;
lt:=0;
gameover:=false;
load_highscore;
Cschema;
clrscr;
writeln('LINES:');
writeln('SCORE:                                                 LEFT/RIGHT KEY TO MOVE');
writeln('LEVEL:                                                   SPACE BAR TO ROTATE');
writeln('HIGHSCORE:                                              DOWN KEY TO SOFT DROP');
writeln('                                                             ESC TO EXIT');
gotoxy(12,4);write(hs);
background;

tsound:=1;
nex:=8;
tetra;
repeat
if keypressed then
   begin
   nosound;
   tsound:=0;
   ch:=readkey;
   case ch of
        #0: begin
        ch:=readkey;
                 case ch of
                 #75:left;
                 #77:right;
                 #80:down;
                 end;
        end;
        #27: gameover:=true;
        #32: rotate;
        end;
   end
   else
   if tick_time(ttime) then
                        begin
                        dunit;
                        checkline;
                        paint2;
                        end;
until gameover;
if score>hs then save_highscore;
end;




begin
repeat
start_game;
nosound;
until not(playagain);
clrscr;
end.
