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
FFT fftLin;
FFT fftLog;
float height23;
float spectrumScale = 4;


//network stuff
OscP5 oscP5; 
  // "/array" is an arbitrary header/filter that the message will be delivered with.
NetAddress myBroadcastLocation;
OscMessage arrayMsg = new OscMessage("/array"); 

//shit imma send
final int nX=6; //array length at X
final int nY=7; //array length at Y
PVector [][] myArray=new PVector[nX][nY]; 


void setup(){
  size(512, 480);
  height23 = 2*height/3;

  minim = new Minim(this);
  techno = minim.loadFile("Dubfire & Oliver Huntemann - Humano (Victor Ruiz Remix).mp3", 1024);
  rock = minim.loadFile("Silversun Pickups - Lazy Eye.mp3", 1024);
  
  //network stuff again
  //broadcast to port 6881 and receive at 6882 
  oscP5 = new OscP5(this, 6882); 
  myBroadcastLocation = new NetAddress("localhost", 6881);
  
  // loop the file
  rock.loop();
  
  // create an FFT object that has a time-domain buffer the same size as techno's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be 1024. 
  // see the online tutorial for more info.
  fftLin = new FFT( rock.bufferSize(), rock.sampleRate() );
  
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin.linAverages( 30 );
  
  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( rock.bufferSize(), rock.sampleRate() );
  
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages( 22, 3 );
  
  rectMode(CORNERS);
  //font = loadFont("ArialMT-12.vlw");
}

void draw(){
  background(0);
  textSize( 18 );
   
  // perform a forward FFT on the samples in techno's mix buffer
  // note that if techno were a MONO file, this would be the same as using techno.left or techno.right
  fftLin.forward( rock.mix );
  fftLog.forward( rock.mix );

  // draw the linear averages
  {
    // since linear averages group equal numbers of adjacent frequency bands
    // we can simply precalculate how many pixel wide each average's 
    // rectangle should be.
    int w = int( width/fftLin.avgSize() );
    for(int i = 0; i < fftLin.avgSize(); i++)
    {
      fill(255);
      // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
      rect(i*w, height23, i*w + w, height23 - fftLin.getAvg(i)*spectrumScale);
    }
  }
}