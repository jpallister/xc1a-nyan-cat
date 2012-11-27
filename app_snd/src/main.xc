#include <xs1.h>
#include <platform.h>
#include <stdio.h>
#include <print.h>

#define CMD_KILL 0
#define CMD_NOTE 1

buffered out port:32 p_spk = PORT_SPEAKER;

#define NOTE_COUNT 24
int note_delay[NOTE_COUNT]= {955, 901, 851, 803, 758, 715, 675, 637, 602, 568, 536, 506, 478, 451, 425, 402, 379, 358, 338, 319, 301, 284, 268, 253, 239};

/* -1 = rest
// 0 = F#
// 1 = G
// 2 = G#
// 3 = A
// 4 = A#
// 5 = B
// 6 = C
// 7 = C#
// 8 = D
// 9 = D#
//10 = E
//11 = F
//12 = F#
//13 = G
//14 = G#  */

// Translated from http://www.scribd.com/doc/54736376/Nyan-Cat-Sheet-Music

int note_seq[] = {
// Bar one
12, 14, 9, 9, -1, 5, 8, 7, 5, -1, 5, 7,
// Bar two
8, 8, 7, 5, 7, 9, 12, 14, 9, 12, 7, 9, 5, 7, 5,
// Bar three
9, 12, 14, 9, 12, 7, 9, 5, 8, 9, 8, 7, 5, 7,
// Bar four
8, 5, 7, 9, 12, 7, 9, 7, 5, 7, 5, 7,

// Bar 5
5, 0, 2, 5, 0, 2, 5, 7, 9, 5, 10,9,10,12,
// Bar 6
5, 5, 0, 2, 5, 0, 10, 9, 7, 5, 0, 0, 0, 0,  // TODO add extra notes at the bottom (cant count)
// Bar 7
5, 0, 2, 5, 0, 2, 5, 5, 7, 9, 5, 0, 2, 0,
// Bar 8
5, 5, 4, 5, 0, 2, 5, 10, 9, 10, 12, 5, 4, 

// Bar 5
5, 0, 2, 5, 0, 2, 5, 7, 9, 5, 10,9,10,12,
// Bar 6
5, 5, 0, 2, 5, 0, 10, 9, 7, 5, 0, 0, 0, 0,
// Bar 7
5, 0, 2, 5, 0, 2, 5, 5, 7, 9, 5, 0, 2, 0,
// Bar 9
5, 5, 4, 5, 0, 2, 5, 10, 9, 10, 12, 5, 7, 
};

int note_time[] = {
2,2,1,1,1,1,1,1,1,1,2,2,
2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
2,2,1,1,1,1,1,1,1,1,1,1,1,1,
2,1,1,1,1,1,1,1,1,2,2,2,

2,1,1,2,1,1,1,1,1,1,1,1,1,1,
2,2,1,1,1,1,1,1,1,1,1,1,1,1,
2,1,1,2,1,1,1,1,1,1,1,1,1,1,
2,1,1,1,1,1,1,1,1,1,1,2,2,

2,1,1,2,1,1,1,1,1,1,1,1,1,1,
2,2,1,1,1,1,1,1,1,1,1,1,1,1,
2,1,1,2,1,1,1,1,1,1,1,1,1,1,
2,1,1,1,1,1,1,1,1,1,1,2,2
};

// Copied from XC-1A examples
void doSoundGen(chanend c_snd)
{
  int note = -1, time, spkVal = 0, cmd, loop = 1, ledVal = 0;
  timer t;

  while(loop)
  {
    //p_spk:1 <: spkVal;
    partout(p_spk, 1, spkVal);
    spkVal = !spkVal;
    t :> time;
    select
    {
      case (note!=-1) => t when timerafter(time + note_delay[note]*100) :> int _:
        break;

      case c_snd :> cmd:
        switch(cmd)
        {
          case CMD_KILL:
            loop = 0;
            break;
          case CMD_NOTE:
            c_snd :> note;
            break;
        }
        break;
    }
  }
}

void drive(chanend cmd)
{
    int i;
    timer t;
    unsigned tm;

    t :> tm;
    while(1)
    for(i = 0; i < 161; i += 1)
    {
        cmd <: CMD_NOTE;
        cmd <: note_seq[i];

        t when timerafter(tm + 10000000*note_time[i]) :> tm;
    }
}

int main()
{
    chan cmd;

    par {
        on stdcore[0] : doSoundGen(cmd);
        on stdcore[1] : drive(cmd);
    }
}
