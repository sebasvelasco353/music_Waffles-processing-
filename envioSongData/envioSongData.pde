//imports 4Audio
import ddf.minim.analysis.*;
import ddf.minim.*;

//imports 4networking
import oscP5.*;
import netP5.*;

//Audio stuff
Minim minim;  
AudioPlayer techno;
AudioPlayer rock;
AudioPlayer tropical;
FFT fftLin;
FFT fftLog;
ArrayList<AudioPlayer>misCanciones = new ArrayList <AudioPlayer>();
int sonando = 2;
float height23;
float spectrumScale = 20;
boolean pausado;


//network stuff
OscP5 oscP5; 
// "/array" is an arbitrary header/filter that the message will be delivered with.
NetAddress myBroadcastLocation;
OscMessage arrayMsg = new OscMessage("/array"); 

//shit imma send
final int nX=60; //array length at X
PVector [] myArray=new PVector[nX];

String lastSent;


void setup() {
  size(512, 480);
  height23 = 2*height/3;

  minim = new Minim(this);
  techno = minim.loadFile("Dubfire & Oliver Huntemann - Humano (Victor Ruiz Remix).mp3", 1024);
  rock = minim.loadFile("Silversun Pickups - Lazy Eye.mp3", 1024);
  tropical = minim.loadFile("Quantic & Nidia Góngora - Que Me Duele_.mp3", 1024);

  misCanciones.add(techno);
  misCanciones.add(rock);
  misCanciones.add(tropical);


  //network stuff again
  //broadcast to port 6881 and receive at 6882 
  oscP5 = new OscP5(this, 6882); 
  myBroadcastLocation = new NetAddress("localhost", 3005);

  // loop the file
  misCanciones.get(sonando).loop();

  // create an FFT object that has a time-domain buffer the same size as techno's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
  fftLin = new FFT( misCanciones.get(sonando).bufferSize(), misCanciones.get(sonando).sampleRate() );

  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin.linAverages( 30 );

  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( misCanciones.get(sonando).bufferSize(), misCanciones.get(sonando).sampleRate() );

  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages( 22, 3 );

  rectMode(CORNERS);
  //font = loadFont("ArialMT-12.vlw");
}

void draw() {
  background(0);
  textSize( 9 );

  String toSend=""; //create a new string to assemble the message

  arrayMsg=new OscMessage("/array");

  // perform a forward FFT on the samples in techno's mix buffer
  // note that if techno were a MONO file, this would be the same as using techno.left or techno.right
  fftLin.forward( misCanciones.get(sonando).mix );
  fftLog.forward( misCanciones.get(sonando).mix );

  // draw the linear averages
  {
    // since linear averages group equal numbers of adjacent frequency bands
    // we can simply precalculate how many pixel wide each average's 
    // rectangle should be.
    int w = int( width/fftLin.avgSize() );
    for (int i = 0; i < fftLin.avgSize (); i++)
    {
      fill(255);
      // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
      rect(i*w, height23, i*w + w, height23 - fftLin.getAvg(i)*spectrumScale);

      //fill the array with the data from soundwave
      myArray[i]=new PVector((i*w), (height23 - fftLin.getAvg(i)*spectrumScale));
      //print it so i know what i just added
      //println((i*w)+ "  " + (height23 - fftLin.getAvg(i)*spectrumScale));

      //now assemble the message to send in a string
      toSend+="{"; 
      toSend+=myArray[i].x + ",";
      toSend+=myArray[i].y + "}";
      //this assembles "{x,y}" : a "Grasshopper ready" point
      switch(sonando){
       case 0: 
       text("Techno", 10, 50);
       break;
       
       case 1: 
       text("Rock", 10, 50);
       break;
       
       case 2: 
       text("Tropical", 10, 50);
       break;
      }
      //println(toSend);

      arrayMsg.add(toSend); //this loads the string to the message container prior to sending
      oscP5.send(arrayMsg, myBroadcastLocation); //this is the actual command that sends the message

      if (pausado) {
        arrayMsg.add(lastSent); //this loads the string to the message container prior to sending
        oscP5.send(arrayMsg, myBroadcastLocation); //this is the actual command that sends the message
      }

      lastSent = toSend;
      //println("sent");
    }
  }
}

void keyPressed () {
  if (key == CODED) {
    if (keyCode == UP) {
      misCanciones.get(sonando).pause();
      pausado = true;
      println("pause");
      arrayMsg.add(lastSent); //this loads the string to the message container prior to sending
      oscP5.send(arrayMsg, myBroadcastLocation); //this is the actual command that sends the message
    } else if (keyCode == DOWN) {
      misCanciones.get(sonando).play();
    } else if (keyCode == LEFT) {
      if (sonando > 0) {
        misCanciones.get(sonando).pause();
        sonando -= 1;
        println("left");
      } else {
        misCanciones.get(sonando).pause();
        sonando = (misCanciones.size()-1);
        println("left and turn");
      }
      misCanciones.get(sonando).play();
    } else if (keyCode == RIGHT) {
      if (sonando < (misCanciones.size()-1)) {
        misCanciones.get(sonando).pause();
        sonando += 1;
        println("right");
      } else {
        misCanciones.get(sonando).pause();
        sonando = 0;
        println("right and turn");
      }
    }
  }
}

void mousePressed() {
}