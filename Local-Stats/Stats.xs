#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"


MODULE = Local::Stats		PACKAGE = Local::Stats

void
new(ref)
        SV* ref 
    CODE:
        SV* coderef = get_sv("Local::Stats::coderef", GV_ADD);
        sv_setsv(coderef, ref);
        
void
add(met_name, value)
        SV* met_name
        SV* value
    PROTOTYPE: $ $
    PPCODE:
        SvREFCNT_inc(value);
        HV* stats = get_hv("Local::Stats::stat", GV_ADD);
        char* name = SvPV_nolen(met_name);
        int str_len = SvCUR(met_name);
        bool exist = hv_exists(stats, name, str_len);
        if (!exist) {
            HV* met = newHV();
            SV* conf_ref = newRV_inc((SV*) newAV());
            SV* new_met = get_sv("Local::Stats::coderef", GV_ADD);
            ENTER; SAVETMPS; PUSHMARK(SP);
            XPUSHs(conf_ref);
            call_sv(new_met, G_DISCARD);
            SPAGAIN; FREETMPS; LEAVE;
            char* test = SvPV_nolen(conf_ref);
            hv_store(met, "conf", 4, conf_ref, 0);
            SV* met_ref = newRV((SV*) met);
            hv_store(stats, name, str_len, met_ref, 0);
        }
        SV* met_href = *hv_fetch(stats, name, str_len, 0);
        HV* met_hash = (HV*) SvRV(met_href);
        exist = hv_exists(met_hash, "values", 6);
        if (!exist) {
            AV* values = newAV();
            av_push(values, value);
            SV* values_ref = newRV_inc((SV*) values);
            hv_store(met_hash, "values", 6, values_ref, 0);
        } else {
            SV* values_ref = *hv_fetch(met_hash, "values", 6, 0);
            AV* values = (AV*) SvRV(values_ref);
            SV* val = newSVnv(SvNV(value));
            av_push(values, val);
        }

void
stat()
    PPCODE:
        HV* output = newHV();
        HV* stats = get_hv("Local::Stats::stat", GV_ADD);
        HE* hash;
        
        hv_iterinit(stats);
        while (hash = hv_iternext(stats)) {
            int len;
            const char* key = hv_iterkey(hash, &len);
            HV* met =(HV*) SvRV(*hv_fetch(stats, key, len, 0));
            AV* conf = (AV*) SvRV(*hv_fetch(met, "conf", 4, 0));
            AV* values = (AV*) SvRV(*hv_fetch(met, "values", 6, 0));
            int conf_len = av_len(conf);
            HV* result = newHV();
            
            for (int i = 0; i<=conf_len; i++) {
                char* func = SvPV_nolen(*av_fetch(conf, i, 0));
                char func_name[17] = "Local::Stats::";
                strcat(func_name, func);
                ENTER; SAVETMPS; PUSHMARK(SP);
                XPUSHs(sv_2mortal(newRV((SV*) values)));
                double func_res = call_pv(func_name, G_DISCARD);
                SPAGAIN;
                hv_store(result, func_name, 3, newSVnv(func_res), 0);
            }
            hv_store(output, key, len, newRV_inc((SV*) result), 0);
        }
        stats = newHV();
        PUSHs(newRV((SV*) output));
        
double
sum(values)
        AV* values
    CODE:
        double sum;
        int num = av_len(values);
        sum = 0;
        for (int i = 0; i <= num; i++) {
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
            if (next < min) { min = next; }
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
            if (next > max) { max = next; }
        }
        RETVAL = max;
    OUTPUT:
        RETVAL