//https://stackoverflow.com/questions/48957742/how-to-calculate-bitmap-size/48961473#48961473
//https://stackoverflow.com/questions/50090500/create-simple-bitmap-in-c-without-external-libraries
//https://stackoverflow.com/questions/46856570/how-to-create-bitmap-in-c-and-compile-with-gcc
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <time.h>

extern void multicorn(float r_start, float r_end, float i_start, float
                        i_end, float res, unsigned char* img);

//Reference Sources are in Header
int main(int argc, char** argv ){
    if(argc != 6){
        printf("Usage: %s <real start> <real end> <imaginary start> <imaginary end> <resolution>\n", argv[0]);
        return 1;
    }
    float r_start = atof(argv[1]);
    float r_end = atof(argv[2]);
    float im_start = atof(argv[3]);
    float im_end = atof(argv[4]);
    float res = atof(argv[5]);

    //Check if range is valid, range > 2 or < -2 is unnecessary, because everything up there diverges 
    if(r_start>=r_end || im_start>=im_end || ((r_end-r_start)==0) || ((r_end-r_start)==0
        || r_start<-2 || r_end>2 || im_start<-2 || im_end>2)){
        printf("Invalid range, range has to be between [-2,2]\n");
        return 1;
    }
    
    //Check if res is too high
    if(res>5000){
        printf("Resolution is too big, the resolution has to be less than 5000\n");
        return 1;
    }
    
    //Check if res is zero
    if(res<1){
        printf("Resolution can´t be less than 1\n");
        return 1;
    }

    //Draw the fractal with resolution res
    int width = (r_end-r_start)*res;          //Re range of [-2,1] - [r_start,r_end]
    int height = ((im_end-im_start)*res);       //Im range of [-1,1] - [im_start,im_end]
    int bitCount = 24;                        //<- 24-bit bitmap

    //Padding is required for a 24-bit BMP - See: Pixel Storage - https://en.wikipedia.org/wiki/BMP_file_format
    double pad_ceil = (24*width)/32.0;
    int width_in_bytes = ceil(pad_ceil) * 4;

    //Pixel count with padding
    int pixelNum = width_in_bytes * height;

    //tsizeof(BITMAPINFOHEADER) = 40
    int biSize = 40;

    //Pixel array offset
    int bfOffBits = 54; 

    // FileHeader + InfoHeader + Pixels with Padding
    int totalSize = bfOffBits + pixelNum;

    //Planes = 1
    int planes = 1;

    //Create header:
    unsigned char header[54] = { 0 };
    memcpy(header, "BM", 2);                            //FileType
    memcpy(header + 2 , &totalSize, 4);
    memcpy(header + 10, &bfOffBits, 4);
    memcpy(header + 14, &biSize, 4);
    memcpy(header + 18, &width, 4);
    memcpy(header + 22, &height, 4);
    memcpy(header + 26, &planes, 2);
    memcpy(header + 28, &bitCount, 2);
    memcpy(header + 34, &pixelNum, 4);

    unsigned char* b = malloc(pixelNum);

    struct timespec t1;
    struct timespec t2;

    clock_gettime(CLOCK_MONOTONIC, &t1);
 
    multicorn(r_start,r_end,im_start,im_end,res,b);

    //Benchmarking
    clock_gettime(CLOCK_MONOTONIC, &t2);
    double time = ((t2.tv_sec - t1.tv_sec)+((t2.tv_nsec*1e-9)-(t1.tv_nsec * 1e-9)));

    FILE *fout = fopen("result_asm.bmp", "wb");
    fwrite(header, 1, 54, fout);
    fwrite((char*)b, 1, pixelNum, fout);
    fclose(fout);
    free(b);
    printf("result_asm.bmp created\n");

    printf("Took %f seconds\n", time);

    return 0;
}
