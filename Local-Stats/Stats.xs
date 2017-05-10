#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"


MODULE = Local::Stats		PACKAGE = Local::Stats		

double
sum(values)
        AV* values
    CODE:
        double sum;
        int num = av_len(values);
        sum = 0;
        for (int i = 0; i <= num; i++){
            sum = sum + (double)SvNV(*av_fetch(values, i, 0));
        }
        RETVAL = sum;
    OUTPUT:
        RETVAL

double
avg(values)
        AV* values
    CODE:
        double sum;
        int num = av_len(values);
        sum = 0;
        for (int i = 0; i <= num; i++){
            sum = sum + (double)SvNV(*av_fetch(values, i, 0));
        }
        RETVAL = sum / num;
    OUTPUT:
        RETVAL

double
cnt(values)
        AV* values
    CODE:
        RETVAL = av_len(values)+1;
    OUTPUT:
        RETVAL

double
min(values)
        AV* values
    CODE:
        double min = (double)SvNV(*av_fetch(values, 0, 0));
        int num = av_len(values);
        for (int i = 1; i <= num; i++){
            double next = (double)SvNV(*av_fetch(values, i, 0));
            if (next < min) {min = next;}
        }
        RETVAL = min;
    OUTPUT:
        RETVAL

double
max(values)
        AV* values
    CODE:
        double max = (double)SvNV(*av_fetch(values, 0, 0));
        int num = av_len(values);
        for (int i = 1; i <= num; i++){
            double next = (double)SvNV(*av_fetch(values, i, 0));
            if (next > max) {max = next;}
        }
        RETVAL = max;
    OUTPUT:
        RETVAL