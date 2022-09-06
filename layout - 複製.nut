///////////////////////////////////////////////////
//
// Attract-Mode Frontend - Grid Game Station Layout
//
///////////////////////////////////////////////////


class Grid extends Conveyor
{
	frame=null;
	name_t=null;
	year_t=null;
	num_t=null;
 	snap_t=null;
 	wheel_t=null;
        history_t=null;
	sel_x=0;
	sel_y=0;

	constructor()
	{
		base.constructor();

		sel_x = cols / 2;
		sel_y = rows / 2;
		fe.add_signal_handler( this, "on_signal" );	

			transition_ms = 1;
	}

	function update_frame()
	{
		local Wheelclick = fe.add_sound("click.mp3")
		      Wheelclick.playing=true

			// Pulsatining Aminamtion for the frame
			   animation.add( PropertyAnimation( frame, 
				{   
					property = "color",
					tween = Tween.Linear, 
					start = {red=255 ,green=200, blue=0},
					end = {red=255, green=255, blue=255},
					pulse = true,
					time = 152,

				} ) );
			// Movement Animation for the frame
			   animation.add( PropertyAnimation( frame, 
				{   
					property = "position",
					tween = Tween.Linear, 
					end = { 
						x = width * sel_x + 54
						y = fe.layout.height / 24 + height * sel_y + 95
					}, 
					time = 40, 
				} ) );
		
		name_t.index_offset = year_t.index_offset = num_t.index_offset = snap_t.index_offset = wheel_t.index_offset = history_t.index_offset = get_sel() - selection_index;	
	}

	function do_correction()
	{
		local corr = get_sel() - selection_index;
		foreach ( o in m_objs )
		{
			local idx = o.m_art.index_offset - corr;
			o.m_art.rawset_index_offset( idx );

		}
	}

	function get_sel()
	{
		return vert_flow ? ( sel_x * rows + sel_y ) : ( sel_y * cols + sel_x );
	}

	function on_signal( sig )
	{
		switch ( sig )	
		{
		case "up":
			if ( vert_flow && ( sel_x > 0 ))
			{
				sel_x--;
				update_frame();
			}
			else if ( !vert_flow && ( sel_y > 0 ) )
			{
				sel_y--;
				update_frame();
			}
			else
			{
				transition_swap_point=1.0;
				do_correction();
				fe.signal( "prev_page" );
			}
			return true;

		case "down":
			if ( vert_flow && ( sel_x < cols - 1 ) )
			{
				sel_x++;
				update_frame();
			}
			else if ( !vert_flow && ( sel_y < rows - 1 ) )
			{
				sel_y++;
				update_frame();
			}
			else
			{
				transition_swap_point=1.0;
				do_correction();
				fe.signal( "next_page" );
			}
			return true;

		case "left":
			if ( vert_flow && ( sel_y > 0 ) )
			{
				sel_y--;
				update_frame();
			}
			else if ( !vert_flow && ( sel_x > 0 ) )
			{
				sel_x--;
				update_frame();
			}
			else
			{
				transition_swap_point=1.0;
				fe.signal( "prev_display" );
			}
			return true;

		case "right":
			if ( vert_flow && ( sel_y < rows - 1 ))
			{
				sel_y++;
				update_frame();
			}
			else if ( !vert_flow && ( sel_x < cols - 1 ) )
			{
				sel_x++;
				update_frame();
			}
			else
			{
				transition_swap_point=1.0;
				fe.signal( "next_display" );
			}
			return true;


		case "exit":
		case "exit_no_menu":
			break;
		case "select":
		default:
			// Correct the list index if it doesn't align with
			// the game our frame is on
			//
			enabled=false; // turn conveyor off for this switch
			local frame_index = get_sel();
			fe.list.index += frame_index - selection_index;

			set_selection( frame_index );
			update_frame();
			enabled=true; // re-enable conveyor
			break;

		}

		return false;
	}

	function on_transition( ttype, var, ttime )
	{
		switch ( ttype )
		{
		case Transition.StartLayout:
		case Transition.FromGame:
			if ( ttime < transition_ms )
			{
				for ( local i=0; i< m_objs.len(); i++ )
				{
					local r = i % rows;
					local c = i / rows;
					local num = rows + cols - 2;
					if ( num < 1 )
						num = 1;

					local temp = 510 * ( num - r - c ) / num * ttime / transition_ms;
					m_objs[i].set_alpha( ( temp > 255 ) ? 255 : temp );
				}

				frame.alpha = 255 * ttime / transition_ms;
				return true;
			}

			local old_alpha = m_objs[ m_objs.len()-1 ].m_art.alpha;

			foreach ( o in m_objs )
				o.set_alpha( 255 );

			frame.alpha = 255;

			if ( old_alpha != 255 )
				return true;

			break;

		case Transition.ToGame:
		case Transition.EndLayout:
			if ( ttime < transition_ms )
			{
				for ( local i=0; i< m_objs.len(); i++ )
				{
					local r = i % rows;
					local c = i / rows;
					local num = rows + cols - 2;
					if ( num < 1 )
						num = 1;

					local temp = 255 - 510 * ( num - r - c ) / num * ttime / transition_ms;
					m_objs[i].set_alpha( ( temp < 0 ) ? 0 : temp );
				}
				frame.alpha = 255 - 255 * ttime / transition_ms;
				return true;
			}

			local old_alpha = m_objs[ m_objs.len()-1 ].m_art.alpha;

			foreach ( o in m_objs )
				o.set_alpha( 0 );

			frame.alpha = 0;

			if ( old_alpha != 0 )
				return true;

			break;
		case Transition.FromOldSelection:
		case Transition.ToNewList:

			foreach ( o in m_objs )
			break;
		}

		return base.on_transition( ttype, var, ttime );
	}
}

::gridc <- Grid();

class MySlot extends ConveyorSlot
{
	m_num = 0;
	m_shifted = false;
	m_art = null;
	favorite = null; 

	constructor( num )
	{
		m_num = num;
		m_art = fe.add_artwork( "flyer", 0, 0,
				width - 4.5*PAD, height - 5.5*PAD );
		m_art.alpha = 0;

			
	//load the favorite
		local fav = fe.add_image(fe.script_dir + "favourite.png");
		fav.visible = false;
		fav.preserve_aspect_ratio = true;			
		favorite = fav;
			
	// ensures favorite icon is turn on/off during transition
		fe.add_transition_callback( this, "favorite_setting" );
		base.constructor();
	}

	function on_progress( progress, var )
	{
		if ( var == 0 )
			m_shifted = false;

			local r = m_num / cols;
			local c = m_num % cols;
		
				m_art.x = c * width + PAD + 59;
				m_art.y = fe.layout.height / 24 + r * height + PAD + 100;

				favorite.x = c * width + PAD + 59;
				favorite.y = fe.layout.height / 24 + r * height + PAD + 100;
	}

// turn on/off the favorite icon
	function set_favorite()
	{

		local m = fe.game_info(Info.Favourite, m_art.index_offset);
		
		if (m == "1")
			favorite.visible  = true;
		else
			favorite.visible  = false;
	}
	
	// set favorite icon during after game transition
	function favorite_setting(ttype, var, ttime)
	{
		switch ( ttype )
		{
			case Transition.ToNewList:
			case Transition.StartLayout:
			case Transition.FromOldSelection: // set the favorite icon
			{
				this.set_favorite();
			}
		}
			
		return false;
	}


	function swap( other )
	{
		m_art.swap( other.m_art );

	}

	function set_index_offset( io )
	{
		m_art.index_offset = io;

	}

	function reset_index_offset()
	{
		m_art.rawset_index_offset( m_base_io ); 

	}

	function set_alpha( alpha )
	{
		m_art.alpha = alpha; 

	}
}


//Star animation
if ( my_config["enable_stars"] == "yes" )
{
fe.do_nut("star.nut");
local bg = fe.add_image( "bg1.png", 0, 0, fe.layout.width, fe.layout.height );
}

if ( my_config["enable_stars"] == "no" )
{
local bg = fe.add_image( "bg.png", 0, 0, fe.layout.width, fe.layout.height );
}

local whiteLine=fe.add_image( "white.png", 0, 0, fe.layout.width, 39 );
whiteLine.alpha = 30;

local left = fe.add_artwork("left.png",  14, 11, 15, 18);
left.alpha = 160;

local right = fe.add_artwork("right.png",  350, 11, 15, 18);
right.alpha = 160;

local up = fe.add_artwork("up.png",  800, 11, 18, 15);
up.alpha = 160;

local down = fe.add_artwork("down.png",  1100, 11, 18, 15);
down.alpha = 160;

local title = fe.add_text( "[DisplayName] | [FilterName]", 43, 5, 600, 28 );
title.align = Align.Left;
title.alpha = 160;
title.font = "Roboto";

local snapShadow= fe.add_artwork("shadow.png", 1167, 510, 757, 503 );

local clock = fe.add_artwork("clock.png",  1798, 5, 30, 30);
clock.alpha = 160;

local clockText = fe.add_text( "", 1818, 5, 100, 28 );
clockText.align = Align.Right;
clockText.alpha = 160;
clockText.font = "roboto";

function update_clock( ttime ){
  local now = date();
  clockText.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
}
  fe.add_ticks_callback( this, "update_clock" );


// Class to assign the history.dat information
// to a text object called ".currom"

	function get_hisinfo(offset) 
	{ 
		local sys = split( fe.game_info( Info.System,offset ), ";" );
		local rom = fe.game_info( Info.Name,offset );
		local text = ""; 
		local currom = "";

		// 
		// we only go to the trouble of loading the entry if 
		// it is not already currently loaded 
		// 
		
		local alt = fe.game_info( Info.AltRomname,offset );
		local cloneof = fe.game_info( Info.CloneOf,offset );
		local lookup = get_history_offset( sys, rom, alt, cloneof );
		
		if ( lookup >= 0 ) 
		{ 

			text = get_history_entry( lookup, my_config );
 			local index = text.find("- TECHNICAL -");
			if (index >= 0)
			{	
				local tempa = text.slice(0, index);
				text = strip(tempa);
			} 
		
	 
		} else { 
			if ( lookup == -2 ) 
				text = "Index file not found.  Try generating an index from the history.dat plug-in configuration menu.";
			else 
				text = "No Information available for:  " + rom; 
		}  
		return text;
	}


// Game name text. We do this in the layout as the frontend doesn't chop up titles with a forward slash
 function gamename( offset ) {
  local s = split( fe.game_info( Info.Title, offset ), "(/[" );
 	if ( s.len() > 0 ) return s[0];
  return "";
}


// Dynamically change the genre text
	function genre(offset)
	{
		local result = "Unknown";
		local cat = " " + fe.game_info(Info.Category, offset).tolower();
		local supported = {
			//filename : [ match1, match2 ]
			"Action": [ "action" ],
			"Adventure": [ "adventure" ],
			"Fighting": [ "fighting", "fighter", "beat'em up" ],
			"Platformer": [ "platformer", "platform" ],
			"Puzzle": [ "puzzle" ],
			"Racing": [ "racing", "driving" ],
			"Rpg": [ "rpg", "role playing", "role playing game" ],
			"Shooter": [ "shooter", "shmup" ],
			"Sports": [ "sports", "boxing", "golf", "baseball", "football", "soccer" ],
			"Strategy": [ "strategy"]
		}
		
		local matches = [];
		foreach( key, val in supported )
		{
			foreach( nickname in val )
			{
				if ( cat.find(nickname, 0) ) matches.push(key);
			}
		}
		if ( matches.len() > 0 )
			result = matches[0];	

		return result;
	}


local my_array = [];
for ( local i=0; i<rows*cols; i++ )
	my_array.push( MySlot( i ) );

gridc.set_slots( my_array, gridc.get_sel() );

gridc.num_t = fe.add_text( "[ListEntry] / [ListSize] GAMES", 768, 5, 384, 28 );
gridc.num_t.align = Align.Centre;
gridc.num_t.alpha = 160;
gridc.num_t.font="roboto";

if ( my_config["style"] == "vertical rectangle" ){
	gridc.frame = fe.add_image( "frame.png", width * 2, height * 2, width, height*0.98 );
}

else if ( my_config["style"] == "horizontal rectangle" ){
	gridc.frame = fe.add_image( "frame2.png", width * 2, height * 2, width, height*0.98 );
}

else if ( my_config["style"] == "square" ){
	gridc.frame = fe.add_image( "frame3.png", width * 2, height * 2, width, height*0.98 );
}

gridc.wheel_t = fe.add_artwork("wheel",  1390, 80, 300, 116);
gridc.wheel_t.trigger = Transition.EndNavigation;

//History.Dat text
gridc.history_t =fe.add_text("[!get_hisinfo]", 1228, 200, 640, 360 );
gridc.history_t.charsize = 20;
gridc.history_t.align = Align.Centre;
gridc.history_t.word_wrap = true;

gridc.snap_t = fe.add_artwork ("snap",  1255, 585, 580, 350 );
gridc.snap_t.trigger = Transition.EndNavigation;

gridc.name_t =  fe.add_text( "[!gamename]", 1230, 968, 650, 33 );
gridc.name_t.align = Align.Right;
gridc.name_t.set_rgb( 134, 30, 29);

gridc.year_t =  fe.add_text( "© [Year] [Manufacturer] | [Players] Player(s) | [!genre]", 1220, 1005, 650, 27 );
gridc.year_t.align = Align.Right;
gridc.year_t.set_rgb( 133, 37, 38);

gridc.update_frame();


//Game List Animation
 ::OBJECTS <- {
mbg = fe.add_image( "black.png", 0, 0, fe.layout.width, fe.layout.height ),
msystem = fe.add_image( "system/[DisplayName]", 480, 180, 960, 540 ),
mredline = fe.add_image( "red.png", 0, 735, fe.layout.width, 60 ),
mfliter = fe.add_text( "[ListSize] games availabe ( [FilterName] )", 460, 740, 1000, 40 ),
}

 local movein_mbg = {
   when =  Transition.ToNewList ,property = "alpha", start = 235, end = 235, time = 700
}

 local moveout_mbg = {
    when = Transition.ToNewList ,property = "alpha", start = 235, end = 0, time = 700, delay = 700
}

 local movein_msysfliter = {
   when =  Transition.ToNewList, property = "alpha", start = 255, end = 255, time = 700
}

 local moveout_msysfliter = {
    when = Transition.ToNewList ,property = "alpha", start = 255, end = 0, time = 700, delay = 700
}

animation.add( PropertyAnimation( OBJECTS.mbg, movein_mbg ) );
animation.add( PropertyAnimation( OBJECTS.mbg, moveout_mbg ) );
animation.add( PropertyAnimation( OBJECTS.msystem, movein_msysfliter ) );
animation.add( PropertyAnimation( OBJECTS.msystem, moveout_msysfliter ) );
animation.add( PropertyAnimation( OBJECTS.mredline,  movein_msysfliter ) );
animation.add( PropertyAnimation( OBJECTS.mredline,  moveout_msysfliter) );
animation.add( PropertyAnimation( OBJECTS.mfliter, movein_msysfliter ) );
animation.add( PropertyAnimation( OBJECTS.mfliter, moveout_msysfliter ) );

OBJECTS.mfliter.align = Align.Centre;
OBJECTS.mfliter.alpha = 0;