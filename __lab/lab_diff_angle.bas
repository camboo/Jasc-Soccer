#include "fbgfx.bi"
'this is the language I use
Using FB
#define CIRCLE_RADIUS 10
#define LINE_LENGHT 30
#define PL_MOVE_STEP 10
#define PL_RDS_STEP 0.15
#define SCREEN_W 640
#define SCREEN_H 480
#define B_WIDTH 5
#define PI 3.14159
#define PI_2 PI/2

#macro _abtp (x1,y1,x2,y2)
    -Atan2(y2-y1,x2-x1)
#endmacro

#macro _dbtp (x1,y1,x2,y2)
    sqr((y2-y1)^2+(x2-x1)^2)
#endmacro

declare sub update_input()
declare sub draw_pl()
declare sub draw_diff()
declare sub init_ball()
declare sub update_ball()
declare sub draw_ball()
declare function calc_ball_spin(alfa as single, beta as single) as single
declare function calc_ball_alfa(alfa as single, beta as single) as single

type pl_proto
	speed as single
	x as single
	y as single
	rds as single
	rds_spin as single
	spin as single
end type

dim shared ball as pl_proto
dim shared pl as pl_proto
dim shared ball_rec(100) as pl_proto
dim shared as integer workpage, c,a
dim shared as single get_time

pl.x = SCREEN_W \ 2
pl.y = SCREEN_H \ 2
pl.rds = 0
pl.rds_spin = pl.rds

c = 0
a = 0
workpage = 0

ScreenRes SCREEN_W,SCREEN_H,24' Sets the graphic mode
SCREENSET 1, 0
CLS

init_ball()
do
	update_input()
	update_ball()
	'GRAPHIC STATEMENTS
	screenlock ' Lock the screen
	screenset workpage, workpage xor 1 ' Swap work pages.
	cls
	screensync
	draw_pl()
	draw_ball()
	draw_diff()
	
	screenunlock
	SLEEP 20, 1

LOOP UNTIL MULTIKEY(SC_ESCAPE)

END 0

sub update_input()
	if multikey(SC_UP) then
		pl.x = pl.x + cos(pl.rds)*PL_MOVE_STEP
		pl.y = pl.y + -sin(pl.rds)*PL_MOVE_STEP
	end if
	if multikey(SC_DOWN) then
		pl.x = pl.x - cos(pl.rds)*PL_MOVE_STEP
		pl.y = pl.y - -sin(pl.rds)*PL_MOVE_STEP
	end if
	if multikey(SC_RIGHT) then pl.rds -= PL_RDS_STEP
	if multikey(SC_LEFT) then pl.rds += PL_RDS_STEP
	if multikey(SC_A) then pl.rds_spin += PL_RDS_STEP
	if multikey(SC_D) then pl.rds_spin -= PL_RDS_STEP
end sub

sub draw_pl()
	circle (pl.x, pl.y), CIRCLE_RADIUS
	'dir line
	line 	(pl.x,pl.y)-_
			(pl.x+cos(pl.rds)*LINE_LENGHT, pl.y + -sin(pl.rds)*LINE_LENGHT)
	line 	(pl.x+(cos(pl.rds-PI_2))*LINE_LENGHT, _
			pl.y +(-sin(pl.rds-PI_2))*LINE_LENGHT)-_
			(pl.x+(cos(pl.rds+PI_2))*LINE_LENGHT, _
			pl.y +(-sin(pl.rds+PI_2))*LINE_LENGHT),_
			&hAF0022
	line 	(pl.x,pl.y)-_
			(pl.x+cos(pl.rds_spin)*LINE_LENGHT, pl.y + -sin(pl.rds_spin)*LINE_LENGHT),_
			&hFF00FF
end sub

sub draw_diff()
	locate 10,10 : print "SPIN "; calc_ball_spin(pl.rds, pl.rds_spin)
	locate 11,10 : print "ALFA "; calc_ball_alfa(pl.rds, pl.rds_spin)
end sub

sub init_ball()
	c = 0
	ball.x = pl.x
	ball.y = pl.y
	ball.speed = 20
'	speed = (SCREEN_H - cur_y)/25 
	'spin = -cos(_abtp(x,y,cur_x,cur_y)) '(SCREEN_W \ 2 - cur_x ) / 1000'rnd*(PI / 64 - PI /32)
	ball.rds = pl.rds
	ball.spin = -calc_ball_spin(pl.rds, pl.rds_spin)
	get_time = timer
end sub

sub draw_ball()
	Circle (ball.x,ball.y), B_WIDTH, , , , , F
    c+=1
	ball_rec(c).x = ball.x
	ball_rec(c).y = ball.y
	if c > 99 then
		c = 0
		init_ball()
	end if
	
	for a = 0 to c
		if a > 1 then
			line	(ball_rec(a).x, ball_rec(a).y)-_
					(ball_rec(a-1).x, ball_rec(a-1).y),&h552255
			if a mod 3 = 0 then
				circle	(ball_rec(a).x, ball_rec(a).y),2
			end if
		end if
	next a
end sub

SUB update_ball()
    'limit check
    if 	ball.speed < 0.5 or ball.x < 0 or ball.x > SCREEN_W or _
		ball.y < 0 or ball.y > SCREEN_H then
		init_ball()
	end if
    'spin effect
	if Timer - get_time > 0.15 and abs(ball.spin) > 0.1 then
		if abs(ball.spin) > 0.1 and ball.speed > 2 then
			ball.spin *= 0.995
		else
			ball.spin = 0.0f
		end if
		ball.rds += ball.spin/20
	end if
    'move ball
	ball.x += cos(ball.rds)*ball.speed
	ball.y += -sin(ball.rds)*ball.speed
	ball.speed *= 0.98

'    ball.z += (ball.z_speed - GRAVITY * M_PIXEL) * Dt
'    ball.z_speed -= GRAVITY * M_PIXEL
'    if (ball.z < 0) then
'        ball.z_speed_init *= 0.75 'bounce ratio_
'        ball.z_speed = ball.z_speed_init
'        ball.z = 0
'    end if
'    if ball.z < 0.5 then
'        ball.z = 0
'        ball.speed *= 0.95 ' friction ratio
'    else
'        ball.speed = ball.speed * FRICTION_AIR
'    end if
END SUB

function calc_ball_spin(alfa as single, beta as single) as single
    if alfa <> beta then
        return cos(alfa-beta-PI_2)
    else
        return 0
    end if
end function

function calc_ball_alfa(alfa as single, beta as single) as single
    if alfa <> beta and sin(alfa-beta-PI_2) > 0 then
        return sin(alfa-beta-PI_2)
    else
        return 0
    end if
end function
