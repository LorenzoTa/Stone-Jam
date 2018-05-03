#v15
#!/usr/bin/perl
use warnings;
use strict;
use Tk;
use Tk::BrowseEntry;

my $mw  = Tk::MainWindow->new(-title=>'Stone jam');
$mw->optionAdd( '*font',   'Courier 8'  );
my $cont_frame = $mw->Frame(    
                                -borderwidth => 2, 
                                -relief => 'groove'
                            )->pack(    
                                        -side=>'top',
                                        -anchor=>'w',
                                        -pady=>5,
                                        -padx=>5,
                                        -expand=>1,
                                        -fill=>'both'
                            );

my $frame_1 = $cont_frame->Frame()->pack(
                                            -side=>'top',
                                            -anchor=>'w',
                                            -pady=>5
                                    );
$frame_1->Label(
                -text => "Drive the red stone to the upper border.\n".
                         "Click on stones to cycle their moves.",
                -justify=>'left'
                )->pack(
                        -side=>'top',
                        -anchor=>'w',
                        -pady=>2,
                        -expand=>1,
                        -fill=>'both'
                );                       
my $frame_2 = $cont_frame->Frame()->pack(
                                            -side=>'top',
                                            -anchor=>'w',
                                            -pady=>5,
                                            -expand=>1,
                                            -fill=>'both'
                                    );
my $diff = 'easy';
my @games = (1..21);
my $game_num = 1;
my $be = $frame_2->BrowseEntry(
                                -label => 'play game level  ',
                                -variable => \$game_num,
                                -choices => \@games,
                                -width=>5,
                                -browsecmd=> \&draw_game,           
                )->pack(-side => 'left');
my $high_contrast = 0;
$frame_2->Checkbutton(-text => 'b/w', -variable => \$high_contrast)->pack(-side => 'left',);
$frame_2->Button(    
                    -padx=> 5,
                    -text => "exit",
                    -borderwidth => 2, 
                    -command => sub{Tk::exit}
                )->pack(    
                        -side => 'right',
                        -expand => 1,
                        -padx=>5
                );
# main underlying canvas for the game
my $can = $mw->Canvas(
                -height => 300,
                -width  => 300,
                -bg => 'snow4',
                -highlightthickness => 0,                
            )->pack( );
# used to abstract and dump coordinates
my %board;
# used to store stones data
my %stones;
# free tiles
my %free;

# squares for tiles in %board starting at 0,0
my ($sq_x,$sq_y) = (0,0);

# fill the board hash from 1-1 to 6-6
# each tile with topX topY bottomX and bottomY
foreach my $row (1..6){
    foreach my $col (1..6){        
        $board{"$row-$col"} = {    
                                tx=>$sq_x,
                                ty=>$sq_y,
                                bx=>$sq_x+50,
                                by=>$sq_y+50
        };
        # add 50
        $sq_x += 50;          
    }
    # reset x to 0 for new row
    $sq_x = 0;
    # add 50 to y
    $sq_y += 50;
}
# bind to move items tagged as stone
$can->bind('stone', '<1>', sub {&move_stone();});

$mw->bind('<Control-Key-s>' => \&save_board);
# draw the first game level
draw_game(undef,1);
# go!
MainLoop;
######################################################################################
sub save_board{ 
	my $widget = shift;
	my $red = ($can->find('withtag','red') )[0];
	my @stones = $can->find('withtag','stone^red');
	
	my $red_switch = 1;
	foreach my $stone ($red,@stones){
		print 	'create_stone( [qw( ',
				join ' ',@{$stones{$stone}{where}},
				')], ',
				"'$stones{$stone}{dir}', ",
				($red_switch ? "'red'" : 'shift @colors'),
				");\n";
		$red_switch = 0;
	}
	print "\nadd_free (qw(",
			(join ' ', sort keys %free),
			"));\n";	
}
######################################################################################
sub show_victory{    
    $can->delete('stone');
    $can->createText(150,150, 
                    -text => "VICTORY!", 
                    -fill => 'red',
                    -font => 'Arial 20 bold',
                    # tagged as stone to be removed
                    # as a new game level is drawn
                    -tags => ['stone']);    
}
######################################################################################
sub draw_game{
    my $widget = shift; # automatically passed by the BrowserEntry widget
    my $game= shift;
    # deleting all items tagged as 'stone' in the canvas
    $can->delete('stone');
    # freeing containers
    undef %stones;
    undef %free;
    print "\nStarting game number $game\n";
	# select color scheme
    my @colors = $high_contrast ?
				( ('white') x 13) :
				qw( SlateBlue1 DodgerBlue2 aquamarine2 PaleTurquoise3
                SpringGreen1 DeepSkyBlue3 cyan2 CornflowerBlue MediumOrchid3 
                LightSkyBlue MediumTurquoise
				SlateBlue1 DodgerBlue2);
	# configure bg for color scheme
	if ($high_contrast){
		$can->configure(-background=>'black');
	}
	else{$can->configure(-background=>'snow4');}
    # GAMES POSITIONING
	# fake game to trig victory:
	# create_stone( [qw(2-3 3-3)],'v', shift @colors ); # red (winning one) always first
	# add_free(qw( 1-3) );
    # create_stone needs arrayref of tiles, direction and color
	
    if ($game == 1){
        create_stone( [qw( 5-3 6-3 )],'v', 'red' ); # red (winning one) always first
		create_stone( [qw(1-1 1-2 1-3 )],'h', shift @colors );
		create_stone( [qw( 1-4 2-4)],'v', shift @colors );
		create_stone( [qw( 2-5 2-6)],'h', shift @colors );
		create_stone( [qw(4-1 5-1 6-1 )],'v', shift @colors );
		create_stone( [qw(4-2 4-3 4-4 )],'h', shift @colors );
		create_stone( [qw(6-4 6-5 )],'h', shift @colors );
		create_stone( [qw( 4-6 5-6 6-6)],'v', shift @colors );
		
		add_free (qw(1-5 1-6 2-1 2-2 2-3 3-1 3-2 3-3 3-4 3-5 3-6 4-5 5-2 5-4 5-5 6-2 ));
		
    }
    elsif ($game == 2){
        create_stone( [qw(5-3 6-3)],'v', 'red' ); 
        create_stone( [qw(1-1 2-1)],'v', shift @colors  );
        create_stone( [qw(1-2 1-3 1-4)],'h', shift @colors  );
        create_stone( [qw(2-4 3-4 4-4)],'v', shift @colors  );
        create_stone( [qw(2-5 2-6)],'h', shift @colors  );
        create_stone( [qw(3-5 4-5)],'v', shift @colors  );
        create_stone( [qw(5-4 5-5)],'h', shift @colors  );
        create_stone( [qw(4-1 4-2 4-3)],'h', shift @colors  );

        add_free(qw( 1-5 1-6 2-2 2-3 3-1 3-2 3-3 3-6 4-6 5-1 5-2 5-6 6-1 6-2 6-4 6-5 6-6 ));
    }
	elsif ($game == 3){
        create_stone( [qw(3-3 4-3)],'v', 'red' ); 
        create_stone( [qw(2-2 2-3 2-4)],'h', shift @colors  );
        create_stone( [qw(1-5 2-5)],'v', shift @colors  );
        create_stone( [qw(3-1 4-1 5-1)],'v', shift @colors  );
        create_stone( [qw(3-2 4-2 5-2)],'v', shift @colors  );
        create_stone( [qw(3-4 4-4)],'v', shift @colors  );
        create_stone( [qw(3-5 3-6)],'h', shift @colors  );
        create_stone( [qw(5-3 5-4 5-5)],'h', shift @colors  );
		create_stone( [qw(6-1 6-2)],'h', shift @colors  );
		create_stone( [qw(4-6 5-6 6-6)],'v', shift @colors  );
        
		add_free(qw( 1-1 1-2 1-3 1-4 1-6 2-1 2-6 4-5 6-3 6-4 6-5  ));
    }
	elsif ($game == 4){
        create_stone( [qw(4-3 5-3)],'v', 'red' ); 
        create_stone( [qw(1-1 1-2)],'h', shift @colors  );
        create_stone( [qw(1-3 1-4)],'h', shift @colors  );
        create_stone( [qw(2-2 3-2)],'v', shift @colors  );
        create_stone( [qw(2-3 2-4)],'h', shift @colors  );
        create_stone( [qw(2-5 2-6)],'h', shift @colors  );
        create_stone( [qw(3-3 3-4)],'h', shift @colors  );
        create_stone( [qw(3-6 4-6)],'v', shift @colors  );
		create_stone( [qw(4-1 4-2)],'h', shift @colors  );
		create_stone( [qw(5-1 6-1)],'v', shift @colors  );
		create_stone( [qw(6-2 6-3)],'h', shift @colors  );
        create_stone( [qw(5-4 6-4)],'v', shift @colors  );
		create_stone( [qw(5-5 6-5)],'v', shift @colors  );
		create_stone( [qw(5-6 6-6)],'v', shift @colors  );
		
		add_free(qw(1-5 1-6 2-1 3-1 3-5 4-4 4-5 5-2));
    }
	elsif ($game == 5){
        create_stone( [qw(2-3 3-3)],'v', 'red' ); 
        create_stone( [qw(1-1 2-1)],'v', shift @colors  );
        create_stone( [qw(1-2 2-2 3-2)],'v', shift @colors  );
        create_stone( [qw(1-3 1-4)],'h', shift @colors  );
        create_stone( [qw(1-5 1-6)],'h', shift @colors  );
        create_stone( [qw(2-4 2-5)],'h', shift @colors  );
        create_stone( [qw(3-5 4-5)],'v', shift @colors  );
        create_stone( [qw(2-6 3-6 4-6)],'v', shift @colors  );
		create_stone( [qw(4-1 5-1)],'v', shift @colors  );
		create_stone( [qw(4-2 4-3 4-4)],'h', shift @colors  );
		create_stone( [qw(6-1 6-2)],'h', shift @colors  );
        create_stone( [qw(5-4 6-4)],'v', shift @colors  );
		create_stone( [qw(5-5 5-6)],'h', shift @colors  );
		create_stone( [qw(6-5 6-6)],'h', shift @colors  );
		
		add_free(qw(3-1 3-4 5-2 5-3 6-3));
    }
	elsif ($game == 6){
        create_stone( [qw(4-3 5-3)],'v', 'red' ); 
        create_stone( [qw(1-4 2-4)],'v', shift @colors  );
        create_stone( [qw(2-1 2-2 2-3)],'h', shift @colors  );
        create_stone( [qw(3-1 3-2)],'h', shift @colors  );
        create_stone( [qw(3-3 3-4)],'h', shift @colors  );
        create_stone( [qw(3-5 4-5)],'v', shift @colors  );
        create_stone( [qw(2-6 3-6 4-6)],'v', shift @colors  );
        create_stone( [qw(5-1 6-1)],'v', shift @colors  );
		create_stone( [qw(5-5 5-6)],'h', shift @colors  );
		create_stone( [qw(6-3 6-4)],'h', shift @colors  );
		create_stone( [qw(6-5 6-6)],'h', shift @colors  );
        
		add_free(qw(1-1 1-2 1-3 1-5 1-6 2-5 4-1 4-2 4-4 5-2 5-4 6-2));
    }
	elsif ($game == 7){
        create_stone( [qw(5-3 6-3)],'v','red' ); 
        create_stone( [qw(1-1 2-1)],'v', shift @colors  );
        create_stone( [qw(1-2 1-3)],'h', shift @colors  );
        create_stone( [qw(1-4 1-5)],'h', shift @colors  );
        create_stone( [qw(2-4 2-5)],'h', shift @colors  );
        create_stone( [qw(4-1 4-2)],'h', shift @colors  );
        create_stone( [qw(4-3 4-4)],'h', shift @colors  );
        create_stone( [qw(4-5 5-5 6-5)],'v', shift @colors  );
		create_stone( [qw(4-6 5-6 6-6)],'v', shift @colors  );
		
		add_free(qw(1-6 2-2 2-3 2-6 3-1 3-2 3-3 3-4 3-5 3-6 5-1 5-2 5-4 6-1 6-2 6-4));
    }
	elsif ($game == 8){
        create_stone( [qw(5-3 6-3)],'v', 'red' ); 
        create_stone( [qw(1-1 2-1)],'v', shift @colors  );
        create_stone( [qw(1-2 2-2)],'v', shift @colors  );
        create_stone( [qw(1-4 1-5 1-6)],'h', shift @colors  );
        create_stone( [qw(3-1 3-2)],'h', shift @colors  );
        create_stone( [qw(4-1 4-2 4-3)],'h', shift @colors  );
        create_stone( [qw(3-4 4-4 5-4)],'v', shift @colors  );
        create_stone( [qw(3-6 4-6)],'v', shift @colors  );
		create_stone( [qw(5-1 5-2)],'h', shift @colors  );
		create_stone( [qw(6-4 6-5)],'h', shift @colors  );
		create_stone( [qw(5-6 6-6)],'v', shift @colors  );
		add_free(qw(1-3 2-3 2-4 2-5 2-6 3-3 3-5 4-5 5-5 6-1 6-2));
    }
	elsif ($game == 9){
        create_stone( [qw(5-3 6-3)],'v', 'red' ); 
        create_stone( [qw(1-1 1-2)],'h', shift @colors  );
        create_stone( [qw(1-4 2-4)],'v', shift @colors  );
        create_stone( [qw(1-6 2-6)],'v', shift @colors  );
        create_stone( [qw(2-1 2-2 2-3)],'h', shift @colors  );
        create_stone( [qw(3-2 4-2)],'v', shift @colors  );
        create_stone( [qw(3-3 3-4)],'h', shift @colors  );
        create_stone( [qw(4-3 4-4)],'h', shift @colors  );
		create_stone( [qw(3-6 4-6)],'v', shift @colors  );
		create_stone( [qw(5-1 6-1)],'v', shift @colors  );
		create_stone( [qw(5-2 6-2)],'v', shift @colors  );
		create_stone( [qw(5-4 5-5 5-6)],'h', shift @colors  );
		create_stone( [qw(6-4 6-5 6-6)],'h', shift @colors  );
		add_free(qw(1-3 1-5 2-5 3-1 3-5 4-1 4-5));
    }
	elsif ($game == 10){
        create_stone( [qw(4-3 5-3)],'v', 'red' ); 
        create_stone( [qw(1-3 1-4)],'h', shift @colors  );
        create_stone( [qw(1-5 1-6)],'h', shift @colors  );
        create_stone( [qw(2-1 2-2 2-3)],'h', shift @colors  );
        create_stone( [qw(2-4 3-4)],'v', shift @colors  );
        create_stone( [qw(2-5 3-5)],'v', shift @colors  );
        create_stone( [qw(3-6 4-6 5-6)],'v', shift @colors  );
        create_stone( [qw(5-1 6-1)],'v', shift @colors  );
		create_stone( [qw(4-2 5-2 6-2)],'v', shift @colors  );
		create_stone( [qw(4-4 4-5)],'h', shift @colors  );
		create_stone( [qw(6-3 6-4)],'h', shift @colors  );
		create_stone( [qw(6-5 6-6)],'h', shift @colors  );
		add_free(qw(1-1 1-2 2-6 3-1 3-2 3-3 4-1 5-4 5-5));
    }
	elsif ($game == 11){
        create_stone( [qw(2-3 3-3)],'v', 'red' ); 
        create_stone( [qw(1-1 1-2 1-3)],'h', shift @colors  );
        create_stone( [qw(1-5 2-5)],'v', shift @colors  );
        create_stone( [qw(1-6 2-6 3-6)],'v', shift @colors  );
        create_stone( [qw(3-1 4-1 5-1)],'v', shift @colors  );
        create_stone( [qw(3-4 3-5)],'h', shift @colors  );
        create_stone( [qw(4-2 4-3)],'h', shift @colors  );
        create_stone( [qw(4-4 5-4 6-4)],'v', shift @colors  );
		create_stone( [qw(6-1 6-2 6-3)],'h', shift @colors  );
		create_stone( [qw(5-5 5-6)],'h', shift @colors  );
		add_free(qw(1-4 2-1 2-2 2-4 3-2 4-5 4-6 5-2 5-3 6-5 6-6));
    }
	elsif ($game == 12){
        create_stone( [qw(4-3 5-3)],'v', 'red' ); 
        create_stone( [qw(1-2 1-3 1-4)],'h', shift @colors  );
        create_stone( [qw(2-1 3-1)],'v', shift @colors  );
        create_stone( [qw(2-2 2-3 2-4)],'h', shift @colors  );
        create_stone( [qw(4-1 4-2)],'h', shift @colors  );
        create_stone( [qw(3-4 4-4)],'v', shift @colors  );
        create_stone( [qw(3-5 4-5)],'v', shift @colors  );
        create_stone( [qw(2-6 3-6 4-6)],'v', shift @colors  );
		create_stone( [qw(6-2 6-3)],'h', shift @colors  );
		create_stone( [qw(5-4 6-4)],'v', shift @colors  );
		create_stone( [qw(5-5 5-6)],'h', shift @colors  );
		create_stone( [qw(6-5 6-6)],'h', shift @colors  );
		add_free(qw(1-1 1-5 1-6 2-5 3-2 3-3 5-1 5-2 6-1));
    }
	elsif ($game == 13){
        create_stone( [qw(4-3 5-3)],'v', 'red' ); 
        create_stone( [qw(1-1 2-1)],'v', shift @colors  );
        create_stone( [qw(1-2 2-2)],'v', shift @colors  );
        create_stone( [qw(1-3 1-4)],'h', shift @colors  );
        create_stone( [qw(2-3 2-4)],'h', shift @colors  );
        create_stone( [qw(2-6 3-6)],'v', shift @colors  );
        create_stone( [qw(3-1 3-2 3-3)],'h', shift @colors  );
        create_stone( [qw(3-4 4-4)],'v', shift @colors  );
		create_stone( [qw(4-1 4-2)],'h', shift @colors  );
		create_stone( [qw(5-1 6-1)],'v', shift @colors  );
		create_stone( [qw(5-4 5-5 5-6)],'h', shift @colors  );
		add_free(qw(1-5 1-6 2-5 3-5 4-5 4-6 5-2 6-2 6-3 6-4 6-5 6-6));
    }
	elsif ($game == 14){
        create_stone( [qw(3-3 4-3)],'v', 'red' ); 
        create_stone( [qw(1-1 1-2)],'h', shift @colors  );
        create_stone( [qw(2-1 2-2 2-3)],'h', shift @colors  );
        create_stone( [qw(2-5 3-5)],'v', shift @colors  );
        create_stone( [qw(2-6 3-6)],'v', shift @colors  );
        create_stone( [qw(4-1 5-1 6-1)],'v', shift @colors  );
        create_stone( [qw(5-2 6-2)],'v', shift @colors  );
        create_stone( [qw(4-4 4-5)],'h', shift @colors  );
		create_stone( [qw(4-6 5-6)],'v', shift @colors  );
		create_stone( [qw(5-3 5-4 5-5)],'h', shift @colors  );
		create_stone( [qw(6-3 6-4)],'h', shift @colors  );
		create_stone( [qw(6-5 6-6)],'h', shift @colors  );
		add_free(qw(1-3 1-4 1-5 1-6 2-4 3-1 3-2 3-4 4-2));
    }
	elsif ($game == 15){
        create_stone( [qw(5-3 6-3)],'v', 'red' ); 
        create_stone( [qw(1-1 2-1)],'v', shift @colors  );
        create_stone( [qw(1-4 1-5 1-6)],'h', shift @colors  );
        create_stone( [qw(3-1 3-2)],'h', shift @colors  );
        create_stone( [qw(3-3 3-4)],'h', shift @colors  );
        create_stone( [qw(2-6 3-6)],'v', shift @colors  );
        create_stone( [qw(4-1 4-2 4-3)],'h', shift @colors  );
        create_stone( [qw(5-2 6-2)],'v', shift @colors  );
		create_stone( [qw(4-4 5-4 6-4)],'v', shift @colors  );
		create_stone( [qw(4-6 5-6)],'v', shift @colors  );
		create_stone( [qw(6-5 6-6)],'h', shift @colors  );
		add_free(qw(1-2 1-3 2-2 2-3 2-4 2-5 3-5 4-5 5-1 5-5 6-1));
    }
	elsif ($game == 16){
        create_stone( [qw(5-3 6-3)],'v', 'red' ); 
        create_stone( [qw(2-1 2-2)],'h', shift @colors  );
        create_stone( [qw(1-5 2-5)],'v', shift @colors  );
        create_stone( [qw(1-6 2-6 3-6)],'v', shift @colors  );
        create_stone( [qw(3-1 4-1)],'v', shift @colors  );
        create_stone( [qw(3-2 4-2)],'v', shift @colors  );
        create_stone( [qw(3-3 3-4 3-5)],'h', shift @colors  );
        create_stone( [qw(4-3 4-4)],'h', shift @colors  );
		create_stone( [qw(4-5 4-6)],'h', shift @colors  );
		create_stone( [qw(5-1 5-2)],'h', shift @colors  );
		create_stone( [qw(6-4 6-5 6-6)],'h', shift @colors  );
		add_free(qw(1-1 1-2 1-3 1-4 2-3 2-4 5-4 5-5 5-6 6-1 6-2));
    }
	elsif ($game == 17){
        create_stone( [qw(3-3 4-3)],'v', 'red' ); 
        create_stone( [qw(1-1 1-2)],'h', shift @colors  );
        create_stone( [qw(2-1 3-1 4-1)],'v', shift @colors  );
        create_stone( [qw(2-2 2-3 2-4)],'h', shift @colors  );
        create_stone( [qw(1-5 2-5 3-5)],'v', shift @colors  );
        create_stone( [qw(2-6 3-6)],'v', shift @colors  );
        create_stone( [qw(4-4 4-5)],'h', shift @colors  );
        create_stone( [qw(4-6 5-6)],'v', shift @colors  );
		create_stone( [qw(5-1 5-2 5-3)],'h', shift @colors  );
		create_stone( [qw(6-1 6-2 6-3)],'h', shift @colors  );
		create_stone( [qw(5-4 6-4)],'v', shift @colors  );
		add_free(qw(1-3 1-4 1-6 3-2 3-4 4-2 5-5 6-5 6-6));
    }
	elsif ($game == 18){ # non vinto..
        create_stone( [qw(5-3 6-3)],'v', 'red' ); 
        create_stone( [qw(1-2 1-3)],'h', shift @colors  );
        create_stone( [qw(1-4 2-4)],'v', shift @colors  );
        create_stone( [qw(1-5 1-6)],'h', shift @colors  );
        create_stone( [qw(2-1 2-2 2-3)],'h', shift @colors  );
        create_stone( [qw(3-2 4-2)],'v', shift @colors  );
        create_stone( [qw(3-3 3-4)],'h', shift @colors  );
        create_stone( [qw(3-5 4-5)],'v', shift @colors  );
		create_stone( [qw(4-3 4-4)],'h', shift @colors  );
		create_stone( [qw(4-1 5-1 6-1)],'v', shift @colors  );
		create_stone( [qw(5-4 5-5)],'h', shift @colors  );
		add_free(qw(1-1 2-5 2-6 3-1 3-6 4-6 5-2 5-6 6-2 6-4 6-5 6-6));
    }
	elsif ($game == 19){ 
        create_stone( [qw(5-3 6-3)],'v', 'red' ); 
        create_stone( [qw(1-1 1-2 1-3)],'h', shift @colors  );
        create_stone( [qw(1-4 2-4)],'v', shift @colors  );
        create_stone( [qw(3-1 4-1)],'v', shift @colors  );
        create_stone( [qw(3-2 3-3)],'h', shift @colors  );
        create_stone( [qw(3-4 3-5)],'h', shift @colors  );
        create_stone( [qw(3-6 4-6)],'v', shift @colors  );
        create_stone( [qw(4-2 4-3 4-4)],'h', shift @colors  );
		create_stone( [qw(4-5 5-5)],'v', shift @colors  );
		create_stone( [qw(5-1 6-1)],'v', shift @colors  );
		create_stone( [qw(6-5 6-6)],'h', shift @colors  );
		add_free(qw(1-5 1-6 2-1 2-2 2-3 2-5 2-6 5-2 5-4 5-6 6-2 6-4));
    }
	elsif ($game == 20){ 
        create_stone( [qw(2-3 3-3)],'v', 'red' ); 
        create_stone( [qw(1-2 2-2)],'v', shift @colors  );
        create_stone( [qw(1-3 1-4)],'h', shift @colors  );
        create_stone( [qw(1-5 1-6)],'h', shift @colors  );
        create_stone( [qw(3-1 3-2)],'h', shift @colors  );
        create_stone( [qw(4-1 5-1)],'v', shift @colors  );
        create_stone( [qw(4-2 4-3)],'h', shift @colors  );
        create_stone( [qw(4-4 4-5)],'h', shift @colors  );
		create_stone( [qw(3-6 4-6)],'v', shift @colors  );
		create_stone( [qw(5-2 5-3)],'h', shift @colors  );
		create_stone( [qw(5-4 6-4)],'v', shift @colors  );
		create_stone( [qw(5-6 6-6)],'v', shift @colors  );
		create_stone( [qw(6-1 6-2 6-3)],'h', shift @colors  );
		add_free(qw(1-1 2-1 2-4 2-5 2-6 3-4 3-5 5-5 6-5));
    }
	# GAME 21 GENERATED BY CTRL-S 
	elsif ($game == 21){ 
		create_stone( [qw( 4-3 5-3 )],  'v',  'red' );
		create_stone( [qw( 1-2 1-3 )],  'h',  shift @colors );
		create_stone( [qw( 3-4 4-4 )],  'v',  shift @colors );
		create_stone( [qw( 1-4 1-5 )],  'h',  shift @colors );
		create_stone( [qw( 2-2 2-3 2-4 )],  'h',  shift @colors );
		create_stone( [qw( 4-2 5-2 )],  'v',  shift @colors );
		create_stone( [qw( 3-2 3-3 )],  'h',  shift @colors );
		create_stone( [qw( 2-5 3-5 )],  'v',  shift @colors );
		create_stone( [qw( 4-5 4-6 )],  'h',  shift @colors );
		create_stone( [qw( 1-1 2-1 3-1 )],  'v',  shift @colors );
		create_stone( [qw( 5-4 5-5 )],  'h',  shift @colors );

		add_free (qw(1-6 2-6 3-6 4-1 5-1 5-6 6-1 6-2 6-3 6-4 6-5 6-6));
	}
    else{1}
}
######################################################################################
sub add_free{
    # reset all moves for all stones
    map {$stones{$_}{moves} = () } keys %stones;
    print "#### recalculating moves for all stones\n";
    foreach my $tile (@_){
        next unless $tile;
        $free{$tile}++;
        my ($row,$col) = split '-',$tile;
        print "\ttile $row-$col is free\n";
        foreach my $stone (keys %stones){            
            # horizontal moving stones 
            if ($stones{$stone}{dir} eq 'h'){
                my $how_many = @{$stones{$stone}{where}} ;
                unless ( $how_many == grep {/$row\-\d/} @{$stones{$stone}{where}}  ){
                     #print "\tskipping stone $stone because horizontal and not in row $row\n";
                     next;
                }
                my @pos = map{s/\d\-//r} @{$stones{$stone}{where}}; 
                print "\tstone $stone horizontal tiles: @pos\n";
                # negative moves
                my $minpos = ( sort{$a<=>$b} @pos )[0];
                if ($col < $minpos){
                    print "\tminimal pos $minpos\n";
                    # avoid moving of more than one tile..
                    # added later: make everything much simpler..
                    unless (int($minpos - $col) > 1){
                        push @{$stones{$stone}{moves}}, 50 * ($col - $minpos) ;
                        print "\tstone $stone can move horizontally by ",$col - $minpos," tile\n";                    
                    }
                }
                # positive moves
                my $maxpos = ( sort{$b<=>$a} @pos )[0];
                if ($maxpos < $col){
                    print "\tmaximal pos $maxpos\n";
                    unless (int($col - $maxpos) > 1){
                        push @{$stones{$stone}{moves}}, 50 * ($col - $maxpos);
                        print "\tstone can move horizontally by ",$col - $maxpos," tile\n";                                            
                    }                    
                }
            }            
            # vertical moving stones 
            else {
                my $how_many = @{$stones{$stone}{where}} ;
                unless ( $how_many == grep {/\d\-$col/} @{$stones{$stone}{where}}  ){
                     # print "\tskipping stone $stone because vertical and not in column $col\n";
                     next;
                }
                my @pos = map{s/\-\d//r} @{$stones{$stone}{where}}; 
                print "\tstone $stone vertical tiles: @pos\n";
                # negative moves
                my $minpos = ( sort{$a<=>$b} @pos )[0];
                if ($row < $minpos){
                    print "\tminimal pos $minpos\n";
                    # avoid moving of more than one tile..
                    unless (int($minpos - $row) > 1){
                        push @{$stones{$stone}{moves}}, 50 * ($row - $minpos) ;
                        print "\tstone $stone can move vertically by ",$row - $minpos," tile\n";                    
                    }
                }
                # positive moves
                my $maxpos = ( sort{$b<=>$a} @pos )[0];
                if ($maxpos < $row){
                    print "\tmaximal pos $maxpos\n";
                    # avoid moving of more than one tile..
                    unless (int($row - $maxpos) > 1){
                        push @{$stones{$stone}{moves}}, 50 * ($row - $maxpos);
                        print "\tstone can move vertically by ",$row - $maxpos," tile\n";                    
                    }
                }
            }        
        }
        print "\n";    
    }
}
######################################################################################
sub move_stone{
    my $ev = $can->XEvent;
    my ($dx, $dy) = ($ev->x, $ev->y);
    print "CLICKED  $dx  $dy\n";
    my $cur_id = ($can->find('withtag','current'))[0];
    print "current stone number: $cur_id\n";
    my @orig_pos = @{$stones{$cur_id}{where}};
    if (  $stones{$cur_id}{moves}  ){
        unshift @{$stones{$cur_id}{moves}},pop @{$stones{$cur_id}{moves}};
        print "was in @orig_pos and had ".
            ($stones{$cur_id}{dir} eq 'h' ? 'horizontal' : 'vertical').
            " moves: ",(join ' ',map {$_ / 50} grep {defined $_ } @{$stones{$cur_id}{moves}}),"\n";
        my $first_move = shift @{$stones{$cur_id}{moves}} ;
        # horizontal
        if ($stones{$cur_id}{dir} eq 'h'){
            $can->move($cur_id, $first_move, 0);
            my $howmuch = $first_move / 50;
            print "stone moved by $howmuch\n";
            foreach my $pos ( @{$stones{$cur_id}{where}} ){
                    my($row,$col)=split '-',$pos;
                    $col += $howmuch;
                    $pos = "$row-$col";            
            }
            print "after move is in @{$stones{$cur_id}{where}}\n";
            # remove occupied tiles from %free ones
            delete $free{$_} for @{$stones{$cur_id}{where}};
            # negative moves pops
            if ($first_move < 0){
                while ($howmuch != 0){
                    my $free = pop @orig_pos;
                    last unless $free;
                    print "freeing $free (",(join ' ', keys %free),")\n";
                    add_free($free, keys %free);
                    $howmuch++;
                }                
            }
            # positive moves shifts
            else {
                while ($howmuch != 0){
                    my $free = shift @orig_pos;
                    last unless $free;
                    print "freeing $free\n";
                    add_free($free, keys %free);
                    $howmuch--;
                }
            }
        }        
        # vertical
        else {
            $can->move($cur_id, 0, $first_move);
            my $howmuch = $first_move / 50;
            print "stone moved by $howmuch\n";
            foreach my $pos ( @{$stones{$cur_id}{where}} ){
                    my($row,$col)=split '-',$pos;
                    $row += $howmuch;
                    $pos = "$row-$col";            
            }
            print "after move is in @{$stones{$cur_id}{where}}\n";
            # VICTORY CHECK
            if ($cur_id == ($can->find('withtag','red'))[0] and grep { /1\-/ } @{$stones{$cur_id}{where}} ){
                print "VICTORY!!\n";
                $mw->after(2000, \&show_victory);
                return;
            }
            # END VICTORY CHECK
            # remove occupied tiles from %free ones
            delete $free{$_} for @{$stones{$cur_id}{where}};
            # negative moves pops
            if ($first_move < 0){
                while ($howmuch != 0){
                    my $free = pop @orig_pos;
                    last unless $free;
                    print "freeing $free (",(join ' ', keys %free),")\n";
                    add_free($free, keys %free);
                    $howmuch++;
                }                
            }
            # positive moves shifts
            else {
                while ($howmuch != 0){
                    my $free = shift @orig_pos;
                    last unless $free;
                    print "freeing $free\n";
                    add_free($free, keys %free);
                    $howmuch--;
                }
            }
        }        
    }    
}
######################################################################################
sub create_stone{
    my $tiles = shift;
    my $dir    = shift;
    my $color = shift;
    # top left and bottom right (extreme defaults)
    my (%tl,%br);
    $tl{x} = 300;    $tl{y} = 300;
    $br{x} = 0;        $br{y} = 0;
    foreach my $tile (@$tiles){
        $tl{x} = $board{$tile}{tx} if $board{$tile}{tx} < $tl{x};
        $tl{y} = $board{$tile}{ty} if $board{$tile}{ty} < $tl{y};
        $br{x} = $board{$tile}{bx} if $board{$tile}{bx} > $br{x};
        $br{y} = $board{$tile}{by} if $board{$tile}{by} > $br{y};
    }
    my $minus = 5;
    my $stone_id = $can->createRectangle (    
                            $tl{x}+$minus,
                            $tl{y}+$minus,
                            $br{x}-$minus,
                            $br{y}-$minus,
                            -fill =>$color,#'red',
                            -width => 4,
                            # mark the red stone to check victory
                            -tags=> $color eq 'red' ? ['stone', 'red'] : ['stone']    
     );
    $stones{$stone_id}={
        where => $tiles,
        dir    => $dir,
    }
}