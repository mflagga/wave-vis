.SUFFIXES:

CC = nvcc
CFLAGS = -arch=native --expt-relaxed-constexpr
EXEC = main.out
PC = python3
FRMDIR = frames
FPS = $(shell cat fps.dat)

all: wave.mp4

$(EXEC): main.cu header.cuh
	$(CC) main.cu $(CFLAGS) -o $(EXEC)

u.dat misc.dat fps.dat: $(EXEC)
	./$(EXEC)

$(FRMDIR):
	mkdir -p $(FRMDIR)

$(FRMDIR)/.frames_done: misc.dat u.dat anim.py $(FRMDIR)
	rm -f $(FRMDIR)/frame_*.png
	$(PC) anim.py
	@touch $(FRMDIR)/.frames_done

wave.mp4: $(FRMDIR)/.frames_done fps.dat
	ffmpeg -framerate $(FPS) -i frames/frame_%05d.png -y -c:v h264_nvenc -preset p7 -loglevel quiet -crf 18 wave.mp4

clean: 
	rm -f $(EXEC)
	rm -f u.dat misc.dat fps.dat
	rm -f $(FRMDIR)/frame_*.png $(FRMDIR)/.frames_done
	#rm -f wave.mp4

.PHONY: all clean