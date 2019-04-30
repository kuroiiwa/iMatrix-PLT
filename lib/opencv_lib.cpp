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

    // copy whole image
    memcpy(res->data, image.data, image.rows * image.cols * 3);

    return res;
}

extern "C" void saveimg(char path[], struct img* image) {
    assert(image != NULL);
    Mat tmp(image->row, image->col, CV_8UC3, image->data);
    imwrite(path, tmp);
}

extern "C" void showimg(struct img* image) {
    Mat tmp(image->row, image->col, CV_8UC3, image->data);
    cout << "call showimg" << endl;
    namedWindow("Display", WINDOW_AUTOSIZE);
    imshow("Display", tmp);
    waitKey(0);
}
