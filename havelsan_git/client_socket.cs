//When AI player stucks at some position onMoveStuck callback is called but it is called every tick.
//However, calling only once is enough for the same stuck location. So, once variable controls that.
$once = true;
//next_path controls the next path to be achieved.
$next_path = 0;
//unused variable
$previous_path = -1;
function PlayerData::onMoveStuck(%this,%obj){
	/*
	When AI stucks at some point it means that AI could not arrived to the next decided path. So, we mark this position as 
	obstacle and send it to the matlab server. Matlab will try to search path from the current point of AI. Target position did not change.
	*/
	if($once){
		echo("stuck at "@ %obj.getPosition());
		echo("box features " @ %obj.getWorldBox());
		Bob.stop();
		%start = Bob.getPosition();
		%end = $save_end;
		MATLABSocket.send("stuck "@ $path[$next_path,0]@" "@$path[$next_path,1]@ " a" @ " " @ %start @ " " @ %end );
		//MATLABSocket.send("stuck " @ %obj.getWorldBox() @ " " @ %start @ " " @ %end @ " " @ Bob.getForwardVector());
		$next_path = 0;
		$previous_path = -1;
		$path = null;
		$once = false;
	}
}
function PlayerData::onReachDestination(%this,%obj){
	/*
		This is called when AI reaches its destination. If current path did not finish, AI starts to move to the next path. Else it sends 
		mission done message to the matlab server and socket stops.
	*/
	if(strcmp($target_comp,$path[$next_path,0]@" "@$path[$next_path,1]) != 0){
			$previous_path = $next_path;
			$next_path++;
			Bob.setMoveDestination($path[$next_path,0]@" "@$path[$next_path,1],false);
			echo("to the next path " @ $path[$next_path,0]@" "@$path[$next_path,1]);
	}
	else{
	echo("achieved the goal!");
	bob.stop();
	MATLABSocket.missionDone();
	}
}

/*
create AI player here
datablock: is necessary to give AI a texture and animations. It is same datablock with player object
position: its start point
moveStuckTolerance: if AI cant make any move more than 20 ticks. onMoveStuck call back is called
mMoveTolarence: instead of reaching the exact destination it defines an acceptance radius to the AI. So, suppose target point is center of a sphere
and mMoveTolarence is the radius of the sphere. If AI enters that sphere it is accepted as reached to the destination. I suggest not to play with this variable.
*/
new AiPlayer(Bob){
	dataBlock = DefaultPlayerData;
	position = "5 33 1";
	moveStuckTolerance = 20;
	mMoveTolerance = 1;
};



function MATLABSocket::onConnected(%this) {
/*
	After connection is set this callback is called just once!
	basically, it just sends AI position as start point and player location as 
	target point.
*/
// Output red text to show we connected
echo("Connected to MATLAB Computing Server");
// Send the request for the file to the server
%start =Bob.getPosition();
$save_start = %start;
%end = LocalClientConnection.player.getPosition();
$save_end = %end;
		%temp = %end;
		%temp = nextToken(%temp,"token"," ");
		%a = %token;
		%temp = nextToken(%temp,"token"," ");
		%b = %token;
		$target_comp = %a @ " " @ %b;
%all ="start " @ %start @ " " @ %end;
%this.send(%all);
echo("sent ",%all);
}

// Procedures on disconnection (NOT Necessary)
function MATLABSocket::onDisconnect(%this) {
// Output red text to show we connected
echo("MATLAB Server's connection is terminated");
%this.delete();
}

function MATLABSocket::onReceive(%this) {
// not used.
echo("get "@ %this.buffer);
}

function MATLABSocket::onConnectFailed(%this)
{
// on connection fail we just delete our created socket
error("Connection Failed: " @ %this.serverAddress);
%this.delete();
}

function MATLABSocket::onLine(%this, %line)
{
	/*
	this function is called when matlab server responds.
	Response is a path array or path not found message.
	If it is an array, the first 2 tokens are size of the path. Then, we create
	path array and set AI's first destination. Remember that first element of path array is also start point of 
	array. It comes to be usefull when start point is marked as an obstacle and matlab needs to find new start point.
	If its not a path but no path message, first token is the string "nopath". If that happens we simply delete the connection.
	*/
	$next_path = 0;
	$previous_path = -1;
%line = nextToken(%line,"token"," ");
%nopath = %token;
if(strcmp(%nopath,"nopath") != 0){
%line = nextToken(%line,"token"," ");
$path_size =  %token;
echo("path size " @ $path_size);
$path = null;
$path = new Array($path_size,2);
echo("path start");
for(%i = 0; %i < $path_size ; %i++){
	if(%i != $path_size-1){
	%line = nextToken(%line,"token"," ");
	$path[%i,0] = %token;
	%line = nextToken(%line,"token"," ");
	$path[%i,1] = %token;
	}
	else{
		%temp = $save_end;
		%temp = nextToken(%temp,"token"," ");
		$path[%i,0] = %token;
		%temp = nextToken(%temp,"token"," ");
		$path[%i,1] = %token;
	}
	echo("path " @%i @ ": x " @ $path[%i,0] @ " y " @ $path[%i,1]);
}
echo("path end");
//echo("array length" @ length($path));
Bob.setMoveDestination($path[$next_path,0]@" "@$path[$next_path,1],false);
echo("to the next path " @ $path[$next_path,0]@" "@$path[$next_path,1]);
$previous_path = $next_path;
$next_path++;
$once = true;
}
else{
	echo("no path found!! Disconnecting...");
	Bob.stop();
	MATLABSocket.missionDone();
}

}
function MATLABSocket::sendData(%this){
	// not used
	%coor = "123.00554 456 -789";
	%this.send(%coor);
	echo("sent ",%coor);
}
function delete_socket(){
	//when socket connection disturbed unexpectedly call this function in torque script command line. Then, call start_socket();
	MATLABSocket.delete();
}
function MATLABSocket::missionDone(%this){
	/*
		Called when AI achieves its mission. Then, connection is deleted.
	*/
	%this.send("done");
	echo("finish request sent");
	%this.delete();
}
function start_socket(){
	/*
		First function to call. It creates TCPobject which is the socket and connects to the matlab server
		remember that ip of matlab server has to be same with the %addr variablees content for exp = "123.123.12.1";
		as a port you can use 12345.
	*/
%t = new TCPObject(MATLABSocket);
%t.lastState = "None";
%addr = "192.168.56.1";
%port = "12345";
%t.connect(%addr@":"@ %port);
}
function p(){
	//short hand function to learn players current position.
	echo(LocalClientConnection.player.getPosition());
}

