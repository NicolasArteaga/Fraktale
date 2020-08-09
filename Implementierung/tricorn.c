#include <stdio.h>
#include <math.h>
#include <stdlib.h>

extern int tricorn(float cReal, float cIm, unsigned char* img);

extern void multicorn_c(float r_start, float r_end, float i_start, float i_end, float res, unsigned char* img){
    // La distancia entre un pixel y otro
    float distance = 1/res;
    //To repair the inclination problem you have to cast res (is a float) to int, because it breaks our implementation idea
    //In our implementation we implemented res as a scalar of the width and length of the result image, thats why we won't need a float to make it
    //Padding is required for a 24-bit BMP - See: Pixel Storage - https://en.wikipedia.org/wiki/BMP_file_format
    int width = (r_end-r_start)*res;
    double pad_ceil = (24*width)/32.0;
    int size = ceil(pad_ceil) * 4;
    int row = ((i_end-i_start)*res)-1;;
    int col = 0;
    int unstable = 0;

    for(float i=i_end;i>(i_start+distance);i=i-distance){
        for(float j=r_start;j<r_end;j=j+distance){
            //ir un pixel a la izq
                /* float c[2];
                c[0] = j;
                c[1] = i;

                float z[2];
                z[0] = 0;   //real
                z[1] = 0;   //imaginary */

                unstable = tricorn(j, i, img);

                if(!unstable){
                    //estable
                    img[row * size + col * 3 + 2] = 0;//red                        
                    img[row * size + col * 3 + 1] = 0;//green
                    img[row * size + col * 3 + 0] = 0;//blue
                }else{
                    //inestable
                    img[row * size + col * 3 + 2] = 60+unstable*10;//red
                    img[row * size + col * 3 + 1] = 100+unstable*10;//green
                    img[row * size + col * 3 + 0] = 220-unstable*5;//blue

                    //Escala ayuda: https://www.rapidtables.com/web/color/RGB_Color.html
                }
            col++;
        }
        col = 0;
        row--;
        //ir un pixel hacia abajo
        //j vuelve a ser r_start
    }
}