#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <string>
#include <iostream>

extern "C" {
#include "builtin.h"
}

using namespace cv;
using namespace std;

/* How to link opencv:
 * 1. Install opencv lib: sudo apt install libopencv-dev (Linux)
 * 2. Compile IR code with opencv: (possible additional opencv libs)
 *      clang++ -lopencv_core -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -o a.out ircode.ll ./lib/lib.a
 */

extern "C" struct img* readimg(char path[]) {
    Mat image = imread(path, CV_LOAD_IMAGE_COLOR);
    struct img *res = malloc_img(image.rows, image.cols);

    for (int i = 0; i < image.rows; i++) {
        const uchar* cur = image.ptr<uchar>(i);

        for (int j = 0; j < image.cols; j++) {
            for (int k = 0; k < 3; k++)
                res->data[i][j][k] = cur[3*j + k];
        }
    }

    return res;
}
