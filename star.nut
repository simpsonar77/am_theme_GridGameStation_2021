//Animated Stars

local flx = fe.layout.width;
local fly = fe.layout.height;

class Zone
{
	int_x=0;
	int_y=0;
	int_w=0;
	int_h=0;

	function set( in_x, in_y, in_w, in_h )
	{   int_x=in_x;
        int_y=in_y;
        int_w=in_w;
        int_h=in_h;
	}

	function x(){return(int_x);}
	function y(){return(int_y);}
	function h(){return(int_h);}
	function w(){return(int_w);}

}

// create a class for each star
class Star
{
    id=0;
	img=null;
	pos_x = flx/2;
	pos_y = fly/2;
	pos_z = 100;
	speed = 4;
	BlackZones=null;
	BlackZones_nb=0;

	function init ( n  )
	{
	    // init random position and speed, far (z=100)
	    id = n;
		pos_x = (rand()*flx/RAND_MAX);
		pos_y = (rand()*fly/RAND_MAX);
		pos_z = 100;
		speed = (rand()*4/RAND_MAX)+1;
		// create the star object for x & y 2d projection
		img = fe.add_image( "star.png", ((( pos_x-350) * 100 ) / pos_z ) +320, ((( pos_y-240) * 100 ) / pos_z ) +240 );
        BlackZones = {};
	}

	function move()
	{
        // move z with speed
	    pos_z -= speed;
	    // if star is too near (z<=0) then randomize its coord and send it back (z=100)
        if( pos_z <=0 ) {
            pos_z = 100;
            pos_x = (rand()*flx/RAND_MAX);
            pos_y = (rand()*fly/RAND_MAX);
            speed = (rand()*4/RAND_MAX)+1;
        }
        // change image coord with the news one calculated with a 3d -> 2d projection
        local tmp_x = ((( pos_x-350) * 100 ) / pos_z ) +960;
        local tmp_y = ((( pos_y-240) * 100 ) / pos_z ) +540;

        img.visible = true;
         for(local j=0;j<BlackZones_nb;j++){
           // if point is in a black zone : just hide it
           if(((tmp_x>=BlackZones[j].x())&&(tmp_x<=BlackZones[j].x()+BlackZones[j].w()))&&((tmp_y>=BlackZones[j].y())&&(tmp_y<=BlackZones[j].y()+BlackZones[j].h()))){
                img.visible = false;
           }
        }
        img.x = tmp_x;
        img.y = tmp_y;
	}
	function add_blackzone( in_x, in_y, in_w, in_h )
	{
	    BlackZones[BlackZones_nb] <- Zone();
	    BlackZones[BlackZones_nb].set(in_x, in_y, in_w, in_h);
        BlackZones_nb++;
	}
}


      // add a "each frame" callback
    fe.add_ticks_callback( "tick" );

  
    // create an array of star(s) objects
    ::Stars <- {};
    for ( local i=0; i<150; i++ ){
        // create new object
        ::Stars[i] <- Star();
        // init it
        ::Stars[i].init(i);
        // add the black zone (artowrk background)
        ::Stars[i].add_blackzone(348, 120, 256, 262 );
        ::Stars[i].add_blackzone(348, 16, 256, 80 );
    }


function tick( ttime )
{
    for ( local i=0; i<150; i++ ){
        ::Stars[i].move();
    }
}


