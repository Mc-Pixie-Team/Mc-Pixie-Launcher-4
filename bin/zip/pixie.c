#include "zip.h"
#include <stdio.h>



typedef void (*CallbackFunction)(const int);
typedef int (*functiontype2)(const char *filename, void *arg);


int zipext(char *zipname, char *outputDir) {

int arg = 2;
return zip_extract(zipname, outputDir, 0, &arg);
}


int fileext(char *zipname, char *innerPath, char *outputPath) {

int sucs = 0;
struct zip_t *zip = zip_open(zipname, 0, 'r'); 
{
    zip_entry_open(zip, innerPath);
    {
    sucs = zip_entry_fread(zip, outputPath);
    }
    zip_entry_close(zip);
}


zip_close(zip);
return sucs;
}

int main() {
    return 0;
}

